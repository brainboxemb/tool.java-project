# Stable local canonical Java action

`tool.java-project` provides the canonical Java lifecycle as a local domain action in addition to its reusable GitHub Actions workflows.

This is the stable boundary for local tooling and repository orchestration. The repository orchestrator decides **whether** the high-level Java capability runs; `tool.java-project` remains responsible for **how** the canonical Java lifecycle executes.

## Command

```bash
bash tools/tool.java-project/java-project.sh canonical \
  --working-directory . \
  --java-version '8.0.504+1' \
  --maven-version '3.9.16' \
  --maven-wrapper-version '3.3.4' \
  --test-report-path 'target/surefire-reports/**' \
  --source-revision "$(git rev-parse HEAD)" \
  --repository 'owner/repository' \
  --publication-root bld/java \
  --publication-artifact target/my-app.jar
```

`--publication-artifact` may be repeated when one canonical lifecycle produces multiple files that belong in the prepared output tree.

## What `canonical` owns

The action:

1. validates the repository Maven Wrapper baseline;
2. records the observed Java and Maven runtime versions;
3. runs exactly one `./mvnw --batch-mode --no-transfer-progress verify`;
4. retains one canonical human-readable Maven execution log;
5. writes toolchain/build provenance;
6. optionally copies selected canonical artifacts into a prepared output tree;
7. copies the raw Surefire evidence from that same Maven run;
8. generates a readable Surefire Markdown summary with a JDK-only helper;
9. writes the logical source revision used for the prepared output;
10. retains the common `brainboxemb.execution-evidence` v1 envelope for the `java.canonical` producer execution;
11. generates an evidence map that explains producer, domain, orchestration/materialization and publication evidence.

The action does **not** publish Git branches, select GitHub runners, configure Moon caching or split Maven phases into new repository-level lifecycles.

## Prepared output

When `--publication-root` is supplied, the generated tree is:

```text
<publication-root>/
  README.md
  source-sha.txt
  artifacts/
    <selected canonical files>
  evidence/
    toolchain-build-provenance.txt
    executions/
      java-canonical/
        execution.json
        execution.log
    tests/
      README.md
      ... raw Surefire XML/TXT ...
```

`evidence/executions/java-canonical/execution.json` is the domain-neutral producer entry point. It records:

- capability `java.canonical`;
- owner `brainboxemb/tool.java-project`;
- action `canonical`;
- the logical Java consumer `source_revision`;
- the exact `tool.java-project` Git `owner_revision` that supplied the canonical action;
- success/exit status and the retained producer log;
- relative links to Java-owned toolchain and Surefire evidence.

The `log` field resolves to the single canonical retained producer log at `evidence/executions/java-canonical/execution.log`. The generated output does not retain a second byte-identical legacy copy merely for navigation.

The exact JDK, Maven, Maven Wrapper, checked-out SHA and other Java-specific details remain in `evidence/toolchain-build-provenance.txt`; T6 does not duplicate that domain evidence into the common envelope.

The generated `README.md` is the human-facing evidence map. It distinguishes:

- artifacts;
- producer execution evidence;
- richer Java/domain evidence;
- orchestration/materialization evidence that a consumer may add later;
- publication context.

This tree is suitable as a declared high-level task output for cache/hydration and as input to a later publication/finalization step.

Publication remains a separate side effect. A cache hit may restore output produced at an earlier input-equivalent revision; later publication/materialization evidence must not rewrite the original producer evidence to pretend the Maven action ran again. Repository orchestration may add current materialization evidence separately, for example under `orchestration/`; that is not produced by `java-project.sh canonical`.

After hydration, the producer `source_revision` may therefore intentionally differ from the current orchestration/materialization source revision. The generated evidence map explains this distinction so it is visible when browsing `prod/bld` or a PR preview.

## Current capability boundary

The initial high-level Java capability remains one canonical lifecycle:

```text
java.canonical
    -> Maven verify
    -> unit-test evidence
    -> canonical artifact(s)
```

A test-only source change therefore invalidates the canonical lifecycle. Separate `java.unit-test`, integration-test or static-analysis capabilities should only be introduced when they gain an independently useful selection/output/lifecycle boundary.

## Reusable workflow

The Linux canonical job in `reusable-java-verify.yml` uses this same action. Windows compatibility verification remains an independent runner-bound check, and the Windows canonical-artifact smoke job still executes the exact Linux-produced artifact.
