#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  finalize-java-publication.sh --publication-root PATH --jobs-json FILE \
    --workflow-run-id ID [--preflight-root PATH] [--captured-at ISO8601]

Adds current-run orchestration evidence to an already prepared Java build tree.
Producer execution evidence is never rewritten.
EOF
}

fail() {
  echo "ERROR: $*" >&2
  exit 2
}

publication_root=""
jobs_json=""
workflow_run_id=""
preflight_root=""
captured_at=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --publication-root) [[ $# -ge 2 ]] || fail "$1 requires a value"; publication_root="$2"; shift 2 ;;
    --jobs-json) [[ $# -ge 2 ]] || fail "$1 requires a value"; jobs_json="$2"; shift 2 ;;
    --workflow-run-id) [[ $# -ge 2 ]] || fail "$1 requires a value"; workflow_run_id="$2"; shift 2 ;;
    --preflight-root) [[ $# -ge 2 ]] || fail "$1 requires a value"; preflight_root="$2"; shift 2 ;;
    --captured-at) [[ $# -ge 2 ]] || fail "$1 requires a value"; captured_at="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) fail "unknown option: $1" ;;
  esac
done

[[ -d "$publication_root" ]] || fail "publication root does not exist: $publication_root"
[[ -f "$publication_root/README.md" ]] || fail "publication README is missing"
[[ -f "$jobs_json" ]] || fail "workflow jobs JSON does not exist: $jobs_json"
[[ "$workflow_run_id" =~ ^[0-9]+$ ]] || fail "workflow run id must be numeric"
[[ -n "$captured_at" ]] || captured_at="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

mkdir -p "$publication_root/orchestration"

preflight_present=false
if [[ -n "$preflight_root" ]]; then
  [[ -d "$preflight_root" ]] || fail "preflight root does not exist: $preflight_root"
  source_root="$preflight_root"
  [[ -d "$preflight_root/java" ]] && source_root="$preflight_root/java"
  rm -rf "$publication_root/orchestration/preflight"
  mkdir -p "$publication_root/orchestration/preflight"
  cp -a "$source_root"/. "$publication_root/orchestration/preflight/"
  test -f "$publication_root/orchestration/preflight/decision.json" \
    || fail "preflight decision.json is missing after staging"
  test -f "$publication_root/orchestration/preflight/preflight.log" \
    || fail "preflight preflight.log is missing after staging"
  preflight_present=true
fi

python3 - "$publication_root" "$jobs_json" "$workflow_run_id" "$captured_at" "$preflight_present" <<'PY'
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

publication = Path(sys.argv[1])
jobs_path = Path(sys.argv[2])
workflow_run_id = int(sys.argv[3])
captured_at = sys.argv[4]
preflight_present = sys.argv[5].lower() == "true"


def parse_time(value):
    if not value:
        return None
    return datetime.fromisoformat(value.replace("Z", "+00:00"))


def seconds_between(start, end):
    if start is None or end is None:
        return None
    return max(0, int((end - start).total_seconds()))

capture_dt = parse_time(captured_at)
if capture_dt is None:
    raise SystemExit("captured-at is invalid")

payload = json.loads(jobs_path.read_text(encoding="utf-8"))
raw_jobs = payload.get("jobs", [])
started_jobs = []
for job in raw_jobs:
    if job.get("runner_id") is None or not job.get("started_at"):
        continue
    started = parse_time(job.get("started_at"))
    completed = parse_time(job.get("completed_at"))
    effective_end = completed or capture_dt
    steps = []
    for step in job.get("steps", []):
        step_started = parse_time(step.get("started_at"))
        step_completed = parse_time(step.get("completed_at"))
        if step_started is None:
            continue
        steps.append({
            "name": step.get("name"),
            "conclusion": step.get("conclusion"),
            "started_at": step.get("started_at"),
            "completed_at": step.get("completed_at"),
            "duration_seconds": seconds_between(step_started, step_completed or capture_dt),
        })
    started_jobs.append({
        "name": job.get("name"),
        "runner": (job.get("labels") or [None])[0],
        "conclusion": job.get("conclusion"),
        "started_at": job.get("started_at"),
        "completed_at": job.get("completed_at"),
        "duration_seconds": seconds_between(started, effective_end),
        "complete": completed is not None,
        "steps": steps,
    })

earliest = min((parse_time(job["started_at"]) for job in started_jobs), default=capture_dt)
completed_runner_seconds = sum(
    job["duration_seconds"] for job in started_jobs if job["complete"] and job["duration_seconds"] is not None
)
runner_seconds_to_capture = sum(job["duration_seconds"] or 0 for job in started_jobs)

windows_mode = None
preflight_duration = None
if preflight_present:
    decision_path = publication / "orchestration/preflight/decision.json"
    decision = json.loads(decision_path.read_text(encoding="utf-8"))
    windows_mode = decision.get("windows_mode")
    preflight_duration = decision.get("duration_seconds")

maven_reported_total_time = None
execution_log = publication / "evidence/executions/java-canonical/execution.log"
if execution_log.is_file():
    for line in execution_log.read_text(encoding="utf-8", errors="replace").splitlines():
        match = re.search(r"\[INFO\]\s+Total time:\s+(.+)$", line)
        if match:
            maven_reported_total_time = match.group(1).strip()

result = {
    "schema_version": 1,
    "workflow_run_id": workflow_run_id,
    "captured_at": captured_at,
    "capture_point": "before-generated-output-push",
    "selected_windows_mode": windows_mode,
    "preflight_decision_duration_seconds": preflight_duration,
    "maven_reported_total_time": maven_reported_total_time,
    "summary": {
        "started_runner_count": len(started_jobs),
        "completed_hosted_runner_seconds": completed_runner_seconds,
        "hosted_runner_seconds_to_capture": runner_seconds_to_capture,
        "wall_clock_seconds_to_capture": seconds_between(earliest, capture_dt),
    },
    "jobs": started_jobs,
}

orchestration = publication / "orchestration"
(orchestration / "timing.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")

lines = [
    "# Java workflow timing",
    "",
    f"- Workflow run: `{workflow_run_id}`",
    f"- Capture point: `{result['capture_point']}`",
    f"- Wall clock to capture: `{result['summary']['wall_clock_seconds_to_capture']} s`",
    f"- Hosted runner time to capture: `{result['summary']['hosted_runner_seconds_to_capture']} s`",
    f"- Started runners: `{result['summary']['started_runner_count']}`",
]
if windows_mode is not None:
    lines.append(f"- Selected Windows mode: `{windows_mode}`")
if preflight_duration is not None:
    lines.append(f"- Java/Moon decision action: `{preflight_duration} s`")
if maven_reported_total_time is not None:
    lines.append(f"- Maven reported total time: `{maven_reported_total_time}`")

lines.extend(["", "## Jobs", "", "| Job | Runner | Result | Duration |", "| --- | --- | --- | ---: |"])
for job in started_jobs:
    lines.append(
        f"| {job['name']} | {job['runner'] or '-'} | {job['conclusion'] or 'running'} | {job['duration_seconds']} s |"
    )

lines.extend(["", "## Steps", ""])
for job in started_jobs:
    lines.append(f"### {job['name']}")
    lines.append("")
    lines.append("| Step | Result | Duration |")
    lines.append("| --- | --- | ---: |")
    for step in job["steps"]:
        lines.append(
            f"| {step['name']} | {step['conclusion'] or 'running'} | {step['duration_seconds']} s |"
        )
    lines.append("")
(orchestration / "timing.md").write_text("\n".join(lines).rstrip() + "\n", encoding="utf-8")

readme_path = publication / "README.md"
readme = readme_path.read_text(encoding="utf-8")
start_marker = "## Orchestration/materialization evidence"
replacement_heading = "## Orchestration evidence"
publication_heading = "## Publication context"
if start_marker in readme and publication_heading in readme:
    before, rest = readme.split(start_marker, 1)
    _, after = rest.split(publication_heading, 1)
    section = [
        replacement_heading,
        "",
        "The publication finalizer adds current-run orchestration evidence without rewriting canonical producer evidence.",
        "",
    ]
    if preflight_present:
        section.extend([
            "- [Preflight decision](orchestration/preflight/decision.json) — exact base/head, affected result and selected Windows mode.",
            "- [Preflight log](orchestration/preflight/preflight.log) — compact readable decision trace.",
            "- `orchestration/preflight/affected/` — detailed generic Moon affected-query evidence.",
        ])
    section.extend([
        "- [Workflow timing](orchestration/timing.md) — readable job/step timing and runner use for the current run.",
        "- [Machine-readable workflow timing](orchestration/timing.json) — durable timing data captured immediately before generated-output push.",
        "",
        publication_heading,
    ])
    readme = before + "\n".join(section) + after
elif replacement_heading not in readme:
    raise SystemExit("generated README does not contain the expected orchestration section")
readme_path.write_text(readme, encoding="utf-8")
PY
