#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  java-preflight.sh --repo PATH --base REV --head REV \
    [--java-task PROJECT:TASK] [--windows-full-task PROJECT:TASK] \
    [--windows-mode auto|none|smoke|full] \
    [--git-tool-root PATH] [--evidence-dir PATH]

Runs one generic Moon affected query and maps the resulting capability set to the
Java execution decision and Windows qualification mode.
EOF
}

fail() {
  echo "ERROR: $*" >&2
  exit 2
}

json_escape() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '%s' "$value"
}

repo="."
base=""
head=""
java_task="consumer:java.canonical"
windows_full_task="consumer:java.windows-full"
requested_windows_mode="auto"
git_tool_root=""
evidence_dir=".moon/preflight/java"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) [[ $# -ge 2 ]] || fail "--repo requires a value"; repo="$2"; shift 2 ;;
    --base) [[ $# -ge 2 ]] || fail "--base requires a value"; base="$2"; shift 2 ;;
    --head) [[ $# -ge 2 ]] || fail "--head requires a value"; head="$2"; shift 2 ;;
    --java-task) [[ $# -ge 2 ]] || fail "--java-task requires a value"; java_task="$2"; shift 2 ;;
    --windows-full-task) [[ $# -ge 2 ]] || fail "--windows-full-task requires a value"; windows_full_task="$2"; shift 2 ;;
    --windows-mode) [[ $# -ge 2 ]] || fail "--windows-mode requires a value"; requested_windows_mode="$2"; shift 2 ;;
    --git-tool-root) [[ $# -ge 2 ]] || fail "--git-tool-root requires a value"; git_tool_root="$2"; shift 2 ;;
    --evidence-dir) [[ $# -ge 2 ]] || fail "--evidence-dir requires a value"; evidence_dir="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) fail "Unknown option: $1" ;;
  esac
done

[[ -n "$base" ]] || fail "--base is required"
[[ -n "$head" ]] || fail "--head is required"
case "$requested_windows_mode" in
  auto|none|smoke|full) ;;
  *) fail "windows mode must be auto, none, smoke or full" ;;
esac

repo="$(cd "$repo" && pwd)"
if [[ -z "$git_tool_root" ]]; then
  git_tool_root="$repo/tools/tool.git-project"
fi
git_tool_root="$(cd "$git_tool_root" && pwd)"
[[ -f "$git_tool_root/moon-affected.sh" ]] || fail "tool.git-project moon-affected.sh is unavailable at $git_tool_root"

if [[ "$evidence_dir" != /* ]]; then
  evidence_dir="$repo/$evidence_dir"
fi
mkdir -p "$evidence_dir/affected"

affected_output="$(bash "$git_tool_root/moon-affected.sh" "$java_task" \
  --repo "$repo" \
  --base "$base" \
  --head "$head" \
  --evidence-dir "$evidence_dir/affected")"

case "$affected_output" in
  true|false) java_affected="$affected_output" ;;
  *) fail "Unexpected moon-affected result: $affected_output" ;;
esac

affected_ids="$evidence_dir/affected/affected-task-ids.json"
[[ -f "$affected_ids" ]] || fail "Affected task list was not produced: $affected_ids"

windows_full_affected=false
if grep -Fq "\"$(json_escape "$windows_full_task")\"" "$affected_ids"; then
  windows_full_affected=true
fi

if [[ "$windows_full_affected" == true && "$java_affected" != true ]]; then
  fail "$windows_full_task is affected while $java_task is not; windows-full inputs must be a subset of canonical Java inputs"
fi

resolved_windows_mode=none
if [[ "$java_affected" == true ]]; then
  case "$requested_windows_mode" in
    auto)
      if [[ "$windows_full_affected" == true ]]; then
        resolved_windows_mode=full
      else
        resolved_windows_mode=smoke
      fi
      ;;
    none|smoke|full)
      resolved_windows_mode="$requested_windows_mode"
      ;;
  esac
fi

cat > "$evidence_dir/decision.env" <<EOF
java_affected=$java_affected
windows_full_affected=$windows_full_affected
windows_mode=$resolved_windows_mode
EOF

cat > "$evidence_dir/decision.json" <<EOF
{
  "schema_version": 1,
  "java_task": "$(json_escape "$java_task")",
  "windows_full_task": "$(json_escape "$windows_full_task")",
  "base": "$(json_escape "$base")",
  "head": "$(json_escape "$head")",
  "java_affected": $java_affected,
  "windows_full_affected": $windows_full_affected,
  "requested_windows_mode": "$(json_escape "$requested_windows_mode")",
  "windows_mode": "$(json_escape "$resolved_windows_mode")"
}
EOF

printf 'java_affected=%s windows_full_affected=%s windows_mode=%s\n' \
  "$java_affected" "$windows_full_affected" "$resolved_windows_mode"
