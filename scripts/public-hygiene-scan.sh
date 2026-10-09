#!/usr/bin/env bash
# Public hygiene scan for this repository.
#
# Usage: scripts/public-hygiene-scan.sh [--range <git-range> | --all] [--tree-only]
#
#   --all         (default) scan commit metadata and added lines for every
#                 commit reachable from HEAD; gitleaks runs with --all.
#   --range R     scan only the commits in git range R (for example
#                 BASE_SHA..HEAD_SHA).
#   --tree-only   run only the working-tree scan (useful before committing).
#
# Steps:
#   1. Tree scan: every git-tracked file (plus untracked, non-ignored files, so
#      the scan also works before a commit) against the deny-list.
#   2. Commit metadata: author/committer emails must be GitHub noreply
#      addresses; names and full messages must not match the deny-list.
#   3. Added lines: only `+` lines of the diff for the same range.
#   4. gitleaks over the checkout. Skipped with a message when the binary is
#      absent, unless HYGIENE_REQUIRE_GITLEAKS=1.
#
# Every deny-list pattern uses a bracket character class so this file never
# contains the literal strings it forbids and needs no self-exclusion.
set -euo pipefail

usage() {
  sed -n '4,11p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-2}"
}

mode=all
range=""
tree_only=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --all) mode=all; range=""; shift ;;
    --range)
      [ "$#" -ge 2 ] && [ -n "$2" ] || usage 2
      mode=range; range="$2"; shift 2 ;;
    --range=*)
      range="${1#--range=}"; [ -n "$range" ] || usage 2
      mode=range; shift ;;
    --tree-only) tree_only=1; shift ;;
    -h|--help) usage 0 ;;
    *) echo "public-hygiene-scan: unknown argument: $1" >&2; usage 2 ;;
  esac
done

root="$(git rev-parse --show-toplevel)"
cd "$root"

# Case-insensitive deny-list.
ci_patterns=(
  'sesispl[a]'
  '/hom[e]/bo[x]'
  '/work[s]pace\b'
  'op:/[/][A-Za-z]'
  'git@[A-Za-z0-9.-]+:'
  'ssh:/[/]'
  'sergio-atla[s]-'
)
# Case-sensitive deny-list (private role names).
cs_patterns=(
  '\bHan[d]\b'
  'Grand Maeste[r]'
  'Master of [A-Z][a-z]+'
  '\bMo[P]\b'
  '\bMo[N]\b'
  'King.s Guar[d]'
  'Warde[n]'
  'Small Counci[l]'
  'Grok Bo[t]'
  'grok-bo[t]'
  'APM PR Bo[t]'
  'apm-code-bo[t]'
)

join_alternation() {
  local out="" p
  for p in "$@"; do
    out+="${out:+|}(?:$p)"
  done
  printf '%s' "$out"
}
CI_RE="$(join_alternation "${ci_patterns[@]}")"
CS_RE="$(join_alternation "${cs_patterns[@]}")"

failures=()
fail_section() { failures+=("$1"); echo "$1: FAIL"; }

# Combine two grep exit codes: 0 = hit, 1 = clean, 2 = error.
combine_rc() {
  if [ "$1" -ge 2 ] || [ "$2" -ge 2 ]; then return 2; fi
  if [ "$1" -eq 0 ] || [ "$2" -eq 0 ]; then return 0; fi
  return 1
}

# Print file:line:match for deny-list hits in files.
deny_grep_files() {
  local rc_ci=0 rc_cs=0
  grep -HnoIP -i -e "$CI_RE" -- "$@" || rc_ci=$?
  grep -HnoIP -e "$CS_RE" -- "$@" || rc_cs=$?
  combine_rc "$rc_ci" "$rc_cs"
}

# Print label:line:match for deny-list hits in a text value.
deny_grep_text() {
  local label="$1" text="$2" rc_ci=0 rc_cs=0
  printf '%s\n' "$text" | grep -HnoP -i --label="$label" -e "$CI_RE" - || rc_ci=$?
  printf '%s\n' "$text" | grep -HnoP --label="$label" -e "$CS_RE" - || rc_cs=$?
  combine_rc "$rc_ci" "$rc_cs"
}

# 1. Tree scan ---------------------------------------------------------------
tree_scan() {
  local files=() f rc=0
  while IFS= read -r -d '' f; do
    if [ -f "$f" ] && [ ! -L "$f" ]; then files+=("$f"); fi
  done < <(git ls-files -z --cached --others --exclude-standard | sort -zu)
  if [ "${#files[@]}" -eq 0 ]; then
    echo "tree scan: PASS (no files)"
    return 0
  fi
  deny_grep_files "${files[@]}" || rc=$?
  case "$rc" in
    0) fail_section "tree scan" ;;
    1) echo "tree scan: PASS (${#files[@]} files)" ;;
    *) echo "tree scan: grep error" >&2; fail_section "tree scan" ;;
  esac
}

tree_scan

if [ "$tree_only" -eq 1 ]; then
  if [ "${#failures[@]}" -gt 0 ]; then
    echo "public-hygiene-scan: FAIL (${failures[*]})"
    exit 1
  fi
  echo "public-hygiene-scan: PASS (tree only)"
  exit 0
fi

have_head=1
git rev-parse --verify -q HEAD >/dev/null || have_head=0

if [ "$mode" = range ]; then
  if ! git rev-list "$range" -- >/dev/null 2>&1; then
    echo "public-hygiene-scan: invalid git range: $range" >&2
    exit 2
  fi
  rev_list_args=("$range")
  scope="range $range"
else
  rev_list_args=(HEAD)
  scope="all commits reachable from HEAD"
fi

# 2. Commit metadata scan -------------------------------------------------------
email_ok() {
  local e="${1,,}"
  case "$e" in
    *@users.noreply.github.com | noreply@github.com) return 0 ;;
    *) return 1 ;;
  esac
}

metadata_scan() {
  local sha an ae cn ce msg bad=0 count=0 rc short
  if [ "$have_head" -eq 0 ]; then
    echo "commit metadata: PASS (no commits)"
    return 0
  fi
  while IFS= read -r sha; do
    count=$((count + 1))
    short="${sha:0:12}"
    an="$(git show -s --format=%an "$sha")"
    ae="$(git show -s --format=%ae "$sha")"
    cn="$(git show -s --format=%cn "$sha")"
    ce="$(git show -s --format=%ce "$sha")"
    msg="$(git show -s --format=%B "$sha")"
    if ! email_ok "$ae"; then echo "commit $short: author email is not a GitHub noreply address"; bad=1; fi
    if ! email_ok "$ce"; then echo "commit $short: committer email is not a GitHub noreply address"; bad=1; fi
    rc=0; deny_grep_text "commit $short author name" "$an" || rc=$?
    [ "$rc" -eq 1 ] || bad=1
    rc=0; deny_grep_text "commit $short committer name" "$cn" || rc=$?
    [ "$rc" -eq 1 ] || bad=1
    rc=0; deny_grep_text "commit $short message" "$msg" || rc=$?
    [ "$rc" -eq 1 ] || bad=1
  done < <(git rev-list "${rev_list_args[@]}" --)
  if [ "$bad" -ne 0 ]; then
    fail_section "commit metadata"
  else
    echo "commit metadata: PASS ($count commits, $scope)"
  fi
}

# 3. Added-lines scan -----------------------------------------------------------
# Emits "<path>\t<line>\t<content>" for each added line of a unified diff
# (prefixed with a short commit id when the stream comes from `git log -p`).
added_lines() {
  awk '
    /^commit [0-9a-f]+$/ && old <= 0 && new <= 0 { c = substr($2, 1, 12) ":"; next }
    /^diff --git / && old <= 0 && new <= 0 { path = ""; next }
    /^\+\+\+ / && old <= 0 && new <= 0 {
      p = substr($0, 5); if (p ~ /^b\//) p = substr(p, 3); path = p; next
    }
    /^@@ / {
      old = 1; new = 1
      if (match($0, /-[0-9]+(,[0-9]+)?/)) {
        n = split(substr($0, RSTART + 1, RLENGTH - 1), a, ","); if (n > 1) old = a[2] + 0
      }
      if (match($0, /\+[0-9]+(,[0-9]+)?/)) {
        n = split(substr($0, RSTART + 1, RLENGTH - 1), a, ","); ln = a[1] + 0; if (n > 1) new = a[2] + 0
      }
      next
    }
    old > 0 || new > 0 {
      ch = substr($0, 1, 1)
      if (ch == "+") { print c path "\t" ln "\t" substr($0, 2); ln++; new-- }
      else if (ch == "-") { old-- }
      else if (ch == " " || $0 == "") { ln++; new--; old-- }
      next
    }
  '
}

added_scan() {
  local stream hits path ln content match
  if [ "$have_head" -eq 0 ]; then
    echo "added lines: PASS (no commits)"
    return 0
  fi
  if [ "$mode" = range ]; then
    stream="$(git -c core.quotePath=false diff --no-color --no-ext-diff "$range" | added_lines)"
  else
    stream="$(git -c core.quotePath=false log -p --no-color --no-ext-diff --format='commit %H' HEAD | added_lines)"
  fi
  hits="$(
    {
      printf '%s\n' "$stream" | grep -P -i -e "^[^\t]*\t[0-9]+\t.*(?:$CI_RE)" || [ "$?" -eq 1 ]
      printf '%s\n' "$stream" | grep -P -e "^[^\t]*\t[0-9]+\t.*(?:$CS_RE)" || [ "$?" -eq 1 ]
    } | sort -u
  )"
  if [ -n "$hits" ]; then
    while IFS=$'\t' read -r path ln content; do
      match="$( { printf '%s\n' "$content" | grep -oP -i -e "$CI_RE"; printf '%s\n' "$content" | grep -oP -e "$CS_RE"; } | head -n 1 || true)"
      echo "$path:$ln:$match"
    done <<< "$hits"
    fail_section "added lines"
  else
    echo "added lines: PASS ($scope)"
  fi
}

# 4. gitleaks -------------------------------------------------------------------
gitleaks_scan() {
  local log_opts
  if ! command -v gitleaks >/dev/null 2>&1; then
    if [ "${HYGIENE_REQUIRE_GITLEAKS:-0}" = 1 ]; then
      echo "gitleaks: binary not found and HYGIENE_REQUIRE_GITLEAKS=1"
      fail_section "gitleaks"
    else
      echo "gitleaks: SKIP (binary not found; set HYGIENE_REQUIRE_GITLEAKS=1 to require it)"
    fi
    return 0
  fi
  if [ "$have_head" -eq 0 ]; then
    echo "gitleaks: SKIP (no commits)"
    return 0
  fi
  if [ "$mode" = range ]; then log_opts="$range"; else log_opts="--all"; fi
  if gitleaks detect --source . --log-opts="$log_opts" --redact --no-banner; then
    echo "gitleaks: PASS ($scope)"
  else
    fail_section "gitleaks"
  fi
}

metadata_scan
added_scan
gitleaks_scan

if [ "${#failures[@]}" -gt 0 ]; then
  echo "public-hygiene-scan: FAIL (${failures[*]})"
  exit 1
fi
echo "public-hygiene-scan: PASS ($scope)"
