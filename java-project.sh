#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage:
  java-project.sh canonical [options]

Canonical options:
  --working-directory PATH       Java project directory (default: .)
  --java-version VERSION         Configured Java baseline for provenance
  --maven-version VERSION        Expected Maven version
  --maven-wrapper-version VER    Expected Maven Wrapper version
  --test-report-path GLOB        Surefire report glob (default: **/target/surefire-reports/**)
  --source-revision REV          Logical source revision (default: checked-out HEAD)
  --repository NAME              Repository identity (default: GitHub context or git remote)
  --publication-root PATH        Prepare a deterministic publication/output tree
  --publication-artifact PATH    File to copy into publication artifacts/; repeatable

The canonical action owns Maven Wrapper validation, one `mvn verify` execution,
canonical build provenance, retained execution logging and optional preparation of
the generated build-output tree. Publication side effects remain separate.
EOF
}

fail() {
  echo "ERROR: $*" >&2
  exit 2
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

json_escape() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  value="${value//$'\r'/\\r}"
  value="${value//$'\t'/\\t}"
  printf '%s' "$value"
}

repo_identity() {
  if [[ -n "${GITHUB_REPOSITORY:-}" ]]; then
    printf '%s' "$GITHUB_REPOSITORY"
    return
  fi
  local remote
  remote="$(git config --get remote.origin.url 2>/dev/null || true)"
  if [[ "$remote" =~ github\.com[:/]([^/]+/[^/.]+)(\.git)?$ ]]; then
    printf '%s' "${BASH_REMATCH[1]}"
  else
    printf '%s' "${remote:-local-worktree}"
  fi
}

canonical() {
  local working_directory="."
  local java_version=""
  local maven_version=""
  local wrapper_version=""
  local test_report_path='**/target/surefire-reports/**'
  local source_revision=""
  local repository=""
  local publication_root=""
  local -a publication_artifacts=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --working-directory) [[ $# -ge 2 ]] || fail "missing value for $1"; working_directory="$2"; shift 2 ;;
      --java-version) [[ $# -ge 2 ]] || fail "missing value for $1"; java_version="$2"; shift 2 ;;
      --maven-version) [[ $# -ge 2 ]] || fail "missing value for $1"; maven_version="$2"; shift 2 ;;
      --maven-wrapper-version) [[ $# -ge 2 ]] || fail "missing value for $1"; wrapper_version="$2"; shift 2 ;;
      --test-report-path) [[ $# -ge 2 ]] || fail "missing value for $1"; test_report_path="$2"; shift 2 ;;
      --source-revision) [[ $# -ge 2 ]] || fail "missing value for $1"; source_revision="$2"; shift 2 ;;
      --repository) [[ $# -ge 2 ]] || fail "missing value for $1"; repository="$2"; shift 2 ;;
      --publication-root) [[ $# -ge 2 ]] || fail "missing value for $1"; publication_root="$2"; shift 2 ;;
      --publication-artifact) [[ $# -ge 2 ]] || fail "missing value for $1"; publication_artifacts+=("$2"); shift 2 ;;
      -h|--help) usage; return 0 ;;
      *) fail "unknown canonical option: $1" ;;
    esac
  done

  [[ -d "$working_directory" ]] || fail "working directory does not exist: $working_directory"
  working_directory="$(cd "$working_directory" && pwd)"

  pushd "$working_directory" >/dev/null
  test -f ./mvnw || fail "Maven Wrapper launcher is missing: $working_directory/mvnw"
  test -x ./mvnw || fail "Maven Wrapper launcher is not executable: $working_directory/mvnw"
  test -f .mvn/wrapper/maven-wrapper.properties || fail "maven-wrapper.properties is missing"

  if [[ -n "$wrapper_version" ]]; then
    grep -Fq "wrapperVersion=${wrapper_version}" .mvn/wrapper/maven-wrapper.properties \
      || fail "Maven Wrapper version does not match expected ${wrapper_version}"
  fi

  local maven_runtime java_runtime
  maven_runtime="$(./mvnw --version | head -n 1)"
  java_runtime="$(java -version 2>&1 | head -n 1)"
  if [[ -n "$maven_version" && "$maven_runtime" != *"Apache Maven ${maven_version}"* ]]; then
    fail "Maven runtime does not match expected ${maven_version}: ${maven_runtime}"
  fi

  if [[ -z "$source_revision" ]]; then
    source_revision="$(git rev-parse HEAD 2>/dev/null || true)"
  fi
  [[ -n "$source_revision" ]] || source_revision="unknown"
  [[ -n "$repository" ]] || repository="$(repo_identity)"

  local checked_out_sha tool_revision tool_version
  checked_out_sha="$(git rev-parse HEAD 2>/dev/null || true)"
  [[ -n "$checked_out_sha" ]] || checked_out_sha="unknown"
  tool_revision="$(git -C "$SCRIPT_DIR" rev-parse HEAD 2>/dev/null || true)"
  [[ -n "$tool_revision" ]] || tool_revision="unknown"
  tool_version="$(cat "$SCRIPT_DIR/VERSION" 2>/dev/null || true)"
  [[ -n "$tool_version" ]] || tool_version="unknown"

  mkdir -p target
  local execution_log
  execution_log="$(mktemp)"

  set +e
  (
    set -o pipefail
    echo "Java canonical verify"
    echo "repository=${repository}"
    echo "source_revision=${source_revision}"
    echo "checked_out_sha=${checked_out_sha}"
    echo "tool_java_project_revision=${tool_revision}"
    echo "tool_java_project_version=${tool_version}"
    echo
    echo "> java -version"
    java -version
    echo
    echo "> ./mvnw --version"
    ./mvnw --version
    echo
    echo "> ./mvnw --batch-mode --no-transfer-progress verify"
    ./mvnw --batch-mode --no-transfer-progress verify
  ) 2>&1 | tee "$execution_log"
  local verify_status=${PIPESTATUS[0]}
  set -e

  cp "$execution_log" target/java-canonical-execution.log

  {
    echo "toolchain_contract=2"
    echo "repository=${repository}"
    echo "source_revision=${source_revision}"
    echo "checked_out_sha=${checked_out_sha}"
    echo "tool_java_project_version=${tool_version}"
    echo "tool_java_project_revision=${tool_revision}"
    echo "java_baseline=${java_version}"
    echo "maven_baseline=${maven_version}"
    echo "maven_wrapper_baseline=${wrapper_version}"
    echo "java_runtime=${java_runtime}"
    echo "maven_runtime=${maven_runtime}"
    [[ -n "${GITHUB_EVENT_NAME:-}" ]] && echo "event_name=${GITHUB_EVENT_NAME}"
    [[ -n "${GITHUB_REF:-}" ]] && echo "source_ref=${GITHUB_REF}"
    [[ -n "${GITHUB_WORKFLOW_REF:-}" ]] && echo "workflow_ref=${GITHUB_WORKFLOW_REF}"
    [[ -n "${RUNNER_OS:-}" ]] && echo "runner_os=${RUNNER_OS}"
    [[ -n "${RUNNER_ARCH:-}" ]] && echo "runner_arch=${RUNNER_ARCH}"
  } > target/toolchain-build-provenance.txt

  if [[ "$verify_status" -ne 0 ]]; then
    echo "Canonical Maven verify failed with status ${verify_status}." >&2
    rm -f "$execution_log"
    popd >/dev/null
    return "$verify_status"
  fi

  if [[ -n "$publication_root" ]]; then
    [[ ${#publication_artifacts[@]} -gt 0 ]] \
      || fail "--publication-root requires at least one --publication-artifact"

    if [[ "$publication_root" != /* ]]; then
      publication_root="$working_directory/$publication_root"
    fi
    rm -rf "$publication_root"
    mkdir -p \
      "$publication_root/artifacts" \
      "$publication_root/evidence/tests" \
      "$publication_root/evidence/executions/java-canonical"

    local configured_path resolved target_name copied=0
    for configured_path in "${publication_artifacts[@]}"; do
      configured_path="$(trim "$configured_path")"
      [[ -n "$configured_path" ]] || continue
      resolved="$configured_path"
      [[ "$resolved" == /* ]] || resolved="$working_directory/$resolved"
      [[ -f "$resolved" ]] || fail "publication artifact does not exist: $configured_path"
      target_name="$(basename "$resolved")"
      [[ ! -e "$publication_root/artifacts/$target_name" ]] \
        || fail "duplicate publication artifact basename: $target_name"
      cp "$resolved" "$publication_root/artifacts/$target_name"
      copied=$((copied + 1))
    done
    [[ "$copied" -gt 0 ]] || fail "no publication artifacts were selected"

    cp target/toolchain-build-provenance.txt "$publication_root/evidence/toolchain-build-provenance.txt"
    cp target/java-canonical-execution.log \
      "$publication_root/evidence/executions/java-canonical/execution.log"

    cat > "$publication_root/evidence/executions/java-canonical/execution.json" <<EOF
{
  "schema": "brainboxemb.execution-evidence",
  "schema_version": 1,
  "capability": "java.canonical",
  "owner": "brainboxemb/tool.java-project",
  "action": "canonical",
  "source_revision": "$(json_escape "$source_revision")",
  "owner_revision": "$(json_escape "$tool_revision")",
  "status": "success",
  "exit_code": 0,
  "log": "execution.log",
  "domain_evidence": [
    "../../toolchain-build-provenance.txt",
    "../../tests/README.md"
  ],
  "tool_java_project_version": "$(json_escape "$tool_version")"
}
EOF

    shopt -s globstar nullglob
    local report relative destination
    while IFS= read -r report; do
      [[ -f "$report" ]] || continue
      relative="${report#./}"
      destination="$publication_root/evidence/tests/$relative"
      mkdir -p "$(dirname "$destination")"
      cp "$report" "$destination"
    done < <(compgen -G "$test_report_path" || true)

    local summary_classes
    summary_classes="$(mktemp -d)"
    javac -source 8 -target 8 -d "$summary_classes" "$SCRIPT_DIR/support/SurefireSummary.java"
    java -cp "$summary_classes" SurefireSummary \
      "$publication_root/evidence/tests" \
      "$publication_root/evidence/tests/README.md"
    rm -rf "$summary_classes"

    printf '%s\n' "$source_revision" > "$publication_root/source-sha.txt"
    {
      echo "# Java build output"
      echo
      echo "Generated by \`tool.java-project\` from the canonical Maven verify action."
      echo
      echo "- Repository: \`${repository}\`"
      echo "- Producer source revision: \`${source_revision}\`"
      echo "- Canonical checked-out SHA: \`${checked_out_sha}\`"
      echo "- tool.java-project: \`${tool_version}\` (\`${tool_revision}\`)"
      echo "- Java baseline: \`${java_version}\`"
      echo "- Maven baseline: \`${maven_version}\`"
      echo "- Maven Wrapper baseline: \`${wrapper_version}\`"
      echo
      echo "## Artifacts"
      echo
      local artifact
      for artifact in "$publication_root"/artifacts/*; do
        echo "- \`artifacts/$(basename "$artifact")\`"
      done
      echo
      echo "## Producer execution evidence"
      echo
      echo "This records the Java producer execution that actually created the retained output."
      echo "It stays unchanged when an equivalent result is later hydrated from cache."
      echo
      echo "- [Machine-readable canonical execution](evidence/executions/java-canonical/execution.json) — capability, producer source revision, exact owner revision and result."
      echo "- [Canonical execution log](evidence/executions/java-canonical/execution.log) — human-readable Java/Maven log from that producer run."
      echo
      echo "## Domain evidence"
      echo
      echo "These files answer Java-specific build and test questions; they are richer domain evidence, not alternate producer logs."
      echo
      echo "- \`evidence/toolchain-build-provenance.txt\` — configured/runtime Java, Maven, Maven Wrapper and owner-tool provenance."
      echo "- [Readable Surefire summary](evidence/tests/README.md) — aggregate test result with retained raw Surefire reports below \`evidence/tests/\`."
      echo
      echo "## Orchestration/materialization evidence"
      echo
      echo "When a consumer runs this output through Moon, the publication layer may add:"
      echo
      echo "- \`orchestration/materialization.json\` — the current source revision/context for which Moon executed or hydrated this output."
      echo "- \`orchestration/moon.log\` — the human-readable execute/cache/hydrate decision for the current invocation."
      echo
      echo "After cache hydration, the producer source revision above may intentionally differ from the current materialization source revision."
      echo "That difference means the producer did not run again; it is not stale or conflicting provenance."
      echo
      echo "## Publication context"
      echo
      echo "This tree is generated build output. Publication/finalization is a separate side effect that consumes prepared output and must not rewrite producer evidence."
    } > "$publication_root/README.md"
  fi

  rm -f "$execution_log"
  popd >/dev/null
}

if [[ $# -lt 1 ]]; then
  usage >&2
  exit 2
fi

action="$1"
shift
case "$action" in
  canonical) canonical "$@" ;;
  -h|--help|help) usage ;;
  *) fail "unknown action: $action" ;;
esac
