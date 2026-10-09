#!/usr/bin/env bash
# Run every smoke in references/scenarios/*.yaml from the package root.
# Each smoke's `check:` block runs with `bash -euo pipefail -c`. Prints
# PASS/FAIL per smoke id and exits non-zero if any smoke fails. Smokes that
# record a deferral (for example an unset operator environment variable) pass.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

command -v python3 >/dev/null || { echo "run-scenarios: python3 is required" >&2; exit 2; }
command -v rg >/dev/null || { echo "run-scenarios: ripgrep (rg) is required" >&2; exit 2; }
python3 -c 'import yaml' 2>/dev/null || { echo "run-scenarios: PyYAML is required (pip install pyyaml)" >&2; exit 2; }

records="$(mktemp)"
trap 'rm -f "$records"' EXIT

# Emit NUL-separated records: <file> <id> <check> for every smoke.
python3 - "$records" <<'PY'
import pathlib
import sys

import yaml

out = pathlib.Path(sys.argv[1])
files = sorted(pathlib.Path("references/scenarios").glob("*.yaml"))
if not files:
    sys.exit("run-scenarios: no scenario files under references/scenarios/")
chunks = []
errors = []
for f in files:
    data = yaml.safe_load(f.read_text(encoding="utf-8"))
    smokes = (data or {}).get("smokes") or []
    if not smokes:
        errors.append(f"{f}: no smokes")
    for i, smoke in enumerate(smokes):
        sid = (smoke or {}).get("id")
        check = (smoke or {}).get("check")
        if not sid or not isinstance(check, str) or not check.strip():
            errors.append(f"{f}: smoke #{i} missing id or check")
            continue
        chunks += [str(f), str(sid), check]
if errors:
    sys.exit("run-scenarios: invalid scenarios:\n  " + "\n  ".join(errors))
out.write_bytes(b"".join(c.encode("utf-8") + b"\0" for c in chunks))
PY

total=0
failed=0
failed_ids=()
while IFS= read -r -d '' file && IFS= read -r -d '' sid && IFS= read -r -d '' check; do
  total=$((total + 1))
  rc=0
  output="$(bash -euo pipefail -c "$check" 2>&1 </dev/null)" || rc=$?
  if [ "$rc" -eq 0 ]; then
    deferral="$(printf '%s\n' "$output" | grep -m1 '^deferred:' || true)"
    if [ -n "$deferral" ]; then
      echo "PASS $sid ($deferral)"
    else
      echo "PASS $sid"
    fi
  else
    failed=$((failed + 1))
    failed_ids+=("$sid")
    echo "FAIL $sid ($file, exit $rc)"
    if [ -n "$output" ]; then
      printf '%s\n' "$output" | sed 's/^/    /'
    fi
  fi
done < "$records"

echo "---"
if [ "$failed" -gt 0 ]; then
  echo "run-scenarios: $failed of $total smokes failed: ${failed_ids[*]}"
  exit 1
fi
echo "run-scenarios: all $total smokes passed"
