#!/usr/bin/env bash
# Atlas overlay smoke for contributions/atlas-people.
#
# Usage: ATLAS_CLI=<path/to/atlas/scripts/atlas.py> bash scripts/overlay-smoke.sh
#        ATLAS_CLIS="<cli-a> <cli-b>" bash scripts/overlay-smoke.sh
#
# 1. Static check (always): overlay root keys are contract-only
#    (contribution_id, templates), contribution_id is atlas-people, the only
#    type is the new type `person` (no core redeclaration), at most 8 required
#    frontmatter keys, every template file exists. When an Atlas checkout's
#    scripts/atlas_cli/schemas/contribution-v1.schema.json and the Python
#    jsonschema package are available, the overlay is also validated against
#    contribution-v1.
# 2. Live check (only when ATLAS_CLIS or ATLAS_CLI is set): for each Atlas CLI
#    and each store version (1.0, 2.0) in a throwaway store: init, compile,
#    schema install, compile, sample person page (plus a v0.1.2-shaped
#    `type: document` person page) compiles clean, missing
#    person_id is reported by page_contract, reinstall, uninstall, compile.
#
# Prints `deferred: ATLAS_CLI unset` and exits 0 when no CLI is given.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
contrib="$root/contributions/atlas-people"
py="${PYTHON:-python3}"

command -v "$py" >/dev/null || { echo "overlay-smoke: python3 is required" >&2; exit 2; }

fail() { echo "overlay-smoke: FAIL: $*" >&2; exit 1; }

clis=()
if [ -n "${ATLAS_CLIS:-}" ]; then
  read -r -a clis <<< "$ATLAS_CLIS"
elif [ -n "${ATLAS_CLI:-}" ]; then
  clis=("$ATLAS_CLI")
fi

static_check() {
  local schema="${1:-}"
  "$py" - "$contrib" "$schema" <<'PY'
import json
import pathlib
import sys

contrib = pathlib.Path(sys.argv[1])
schema_path = sys.argv[2]
overlay = json.loads((contrib / "SCHEMA.overlay.json").read_text(encoding="utf-8"))

CORE = {"work", "document", "experience", "decision", "lesson", "recipe",
        "protostar", "gist", "frame", "memory", "schema"}
errors = []
extra = set(overlay) - {"contribution_id", "templates"}
if extra:
    errors.append(f"root keys beyond contribution_id/templates: {sorted(extra)}")
if overlay.get("contribution_id") != "atlas-people":
    errors.append("contribution_id is not atlas-people")
by_type = (overlay.get("templates") or {}).get("by_type") or {}
if set(by_type) != {"person"}:
    errors.append(f"types must be exactly ['person'], got {sorted(by_type)}")
clash = set(by_type) & CORE
if clash:
    errors.append(f"redeclares core types: {sorted(clash)}")
for name, spec in by_type.items():
    required = ((spec or {}).get("frontmatter") or {}).get("required") or []
    if len(required) > 8:
        errors.append(f"{name}: {len(required)} required frontmatter keys (max 8)")
    f = (spec or {}).get("file")
    if f and not (contrib / f).is_file():
        errors.append(f"{name}: template file missing: {f}")
if errors:
    sys.exit("static check failed:\n  " + "\n  ".join(errors))

if schema_path and pathlib.Path(schema_path).is_file():
    try:
        import jsonschema
    except ImportError:
        print("static check: contribution-v1 validation skipped (jsonschema not installed)")
    else:
        schema = json.loads(pathlib.Path(schema_path).read_text(encoding="utf-8"))
        jsonschema.Draft202012Validator(schema).validate(overlay)
        print("static check: overlay validates against contribution-v1")
print("static check: ok")
PY
}

if [ "${#clis[@]}" -eq 0 ]; then
  static_check
  echo "deferred: ATLAS_CLI unset"
  exit 0
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

write_sample() {
  local store="$1"
  mkdir -p "$store/people"
  cat > "$store/people/ada-example.md" <<'MD'
---
type: person
title: "Ada Example"
created: "2026-10-09"
updated: "2026-10-09"
origin: agent
sensitivity: restricted
person_contract: v1
person_id: "ada-example"
names:
  - "Ada Example"
aliases: []
---

# Ada Example

## Bio

Ada Example is a fictional engineer used only to check that the person
overlay compiles cleanly on a throwaway Atlas store.
MD
  cat > "$store/people/index.md" <<'MD'
---
type: document
title: "People"
created: "2026-10-09"
---

# People

Person pages for the overlay smoke live in this folder.

- [Ada Example](ada-example.md)
MD
}

write_legacy() {
  local store="$1"
  # v0.1.2 shape (type document + person_contract v1) must stay valid.
  cat > "$store/people/bea-legacy.md" <<'MD'
---
type: document
title: "Bea Legacy"
created: "2026-10-05"
updated: "2026-10-05"
origin: agent
sensitivity: restricted
person_contract: v1
person_id: "bea-legacy"
names:
  - "Bea Legacy"
aliases: []
---

# Bea Legacy

## Bio

Bea Legacy is a fictional person page written in the v0.1.2 shape, kept to
check that older pages still compile once the overlay is mounted.
MD
  printf -- '- [Bea Legacy](bea-legacy.md)\n' >> "$store/people/index.md"
}

# run <label> <expected-exit> <cmd...>; output lands in $out.
out=""
run() {
  local label="$1" want="$2" rc=0
  shift 2
  out="$("$@" 2>&1)" || rc=$?
  if [ "$rc" -ne "$want" ]; then
    printf '%s\n' "$out" | sed 's/^/    /' >&2
    fail "$label: exit $rc (expected $want)"
  fi
}

n=0
for cli in "${clis[@]}"; do
  [ -f "$cli" ] || fail "Atlas CLI not found: $cli"
  static_check "$(dirname "$cli")/atlas_cli/schemas/contribution-v1.schema.json"
  ver="$("$py" "$cli" --version 2>&1 | tail -n 1)"
  for sv in 1.0 2.0; do
    n=$((n + 1))
    store="$tmp/store-$n"
    label="[$ver, store $sv]"

    run "$label init" 0 "$py" "$cli" init --root "$store" --schema-version "$sv"
    run "$label compile (fresh)" 0 "$py" "$cli" compile --root "$store"

    run "$label schema install" 0 "$py" "$cli" schema install "$contrib" --root "$store"
    "$py" - "$store/schema.d/atlas-people.receipt.json" <<'PY' || fail "$label: receipt check"
import json
import sys

r = json.load(open(sys.argv[1], encoding="utf-8"))
assert r.get("id") == "atlas-people", r
assert "templates/person.md" in r.get("written", []), r
assert "person" in r.get("added_types", []), r
PY
    [ -f "$store/templates/person.md" ] || fail "$label: templates/person.md not installed"
    run "$label compile (overlay)" 0 "$py" "$cli" compile --root "$store"

    write_sample "$store"
    run "$label compile (sample page)" 0 "$py" "$cli" compile --root "$store"
    printf '%s\n' "$out" | grep -Fq 'no issues' || { printf '%s\n' "$out" >&2; fail "$label: sample page compile reported issues"; }

    write_legacy "$store"
    run "$label compile (legacy v0.1.2 page)" 0 "$py" "$cli" compile --root "$store"
    if printf '%s\n' "$out" | grep -Eq '^(WARNINGS|CRITICAL)'; then
      printf '%s\n' "$out" >&2
      fail "$label: legacy person page raised warnings"
    fi

    page="$store/people/ada-example.md"
    cp "$page" "$tmp/page.bak"
    sed -i.sed '/^person_id:/d' "$page" && rm -f "$page.sed"
    run "$label compile (missing person_id)" 1 "$py" "$cli" compile --root "$store"
    printf '%s\n' "$out" | grep -Fq "[page_contract] people/ada-example.md: type person missing required frontmatter 'person_id'" \
      || { printf '%s\n' "$out" >&2; fail "$label: missing person_id not reported"; }
    cp "$tmp/page.bak" "$page"
    run "$label compile (restored)" 0 "$py" "$cli" compile --root "$store"

    rc=0
    out="$("$py" "$cli" schema install "$contrib" --root "$store" 2>&1)" || rc=$?
    if [ "$rc" -eq 2 ]; then
      run "$label schema install --force" 0 "$py" "$cli" schema install "$contrib" --root "$store" --force
    elif [ "$rc" -ne 0 ]; then
      printf '%s\n' "$out" >&2
      fail "$label: reinstall exit $rc"
    fi
    [ -f "$store/schema.d/atlas-people.json" ] || fail "$label: overlay missing after reinstall"

    run "$label schema uninstall" 0 "$py" "$cli" schema uninstall atlas-people --root "$store"
    [ ! -e "$store/schema.d/atlas-people.json" ] || fail "$label: schema.d/atlas-people.json still present"
    [ -f "$page" ] || fail "$label: uninstall deleted a person page"
    run "$label compile (after uninstall)" 0 "$py" "$cli" compile --root "$store"

    echo "PASS $label"
  done
done
echo "overlay-smoke: all $n store runs passed"
