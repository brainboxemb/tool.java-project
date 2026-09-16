# tool.java-project

Reusable Java/Maven engineering tooling for reproducible Linux/Windows builds, testing, CI workflows, artifacts, build provenance, and generated build-output publication.

Release history: [`CHANGELOG.md`](CHANGELOG.md)

## Purpose

This repository owns generic Java-project engineering behaviour that can be reused by product repositories. It deliberately does **not** own product/domain behaviour.

The Java tool sits on top of the generic Git-project bootstrap layer:

```text
consumer repository
  bootstrap.ps1 / bootstrap.sh
        ↓
  tools/tool.git-project   pinned gitlink
        ↓
  project.yml              generic repository/dependency configuration
        ↓
  project.java.yml         Java-specific configuration
        ↓
  tool.java-project local action / reusable CI
        ↓
  Maven Wrapper / Java verification
```

The Java baseline proves:

```text
clean checkout
    ↓
pinned Java 8 baseline
    ↓
repository Maven Wrapper
    ↓
verify + tests
    ↓
canonical Linux artifact
    ↓
provenance + retained execution evidence/log
    ↓
Windows compatibility execution of that exact artifact
```

Consumers may additionally opt in to generated build publication:

```text
canonical Linux action
    ↓
prepared publication/output tree
    ↓
PR      → dev/pr-N/bld
main    → prod/bld
release → rel/vX.Y.Z/bld
```

The Java tool owns preparation of the `bld` tree. Generic branch selection/materialization is delegated to the released `tool.git-project` publisher. Publication reuses the canonical build; it does not run a second Maven build merely to populate a generated branch.

## Stable local canonical action

The canonical Java lifecycle is available as a local domain action:

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

The reusable Linux canonical workflow calls this same action. Local development, CI and repository-level orchestration therefore share one implementation of the canonical Maven lifecycle rather than carrying separate Maven/provenance/publication-preparation scripts.

See [`docs/local-canonical-action.md`](docs/local-canonical-action.md) for the action contract and prepared-output model.

## Shared Java production lifecycle

The v0.3.0 line adds the Migration-006 repository execution lifecycle around that unchanged canonical Maven producer:

```text
exact base -> head preflight
        ↓
one generic affected query
        ↓
Java impact + Windows-mode classification
        ├─ unrelated      -> stop before JDK/Maven/Windows
        ├─ normal Java    -> Linux canonical + Windows smoke
        └─ build/tooling  -> Linux canonical + full Windows verify + smoke
        ↓
finalize prepared bld output
        ↓
generic generated-output publication
```

`windows-mode` is `auto|none|smoke|full`. In `auto`, ordinary affected Java changes use the exact Linux-produced runnable artifact for Windows smoke without a second Maven build; build/toolchain-sensitive changes select full native Windows Maven verification in addition to that exact-artifact smoke. Release qualification uses the full path.

Preflight, Linux execution, full Windows execution and retained provenance use the same resolved exact source revision. Publication/finalization consumes the already-prepared canonical output and never reruns Maven merely to publish `bld`.

The generic base/head affected query and repository publication mechanics remain owned by released `tool.git-project`. `tool.java-project` owns Java impact mapping, canonical Maven execution, Java evidence, selective Windows qualification and Java-output finalization. Engineering-documentation assembly remains outside this Java lifecycle.

See [`docs/execution-lifecycle.md`](docs/execution-lifecycle.md) for the detailed owner boundary and execution flow.

## Tool release baseline

`VERSION` is the source-controlled release version of `tool.java-project`; it is independent of the Maven version used by any product or fixture. A release tag is `v<VERSION>`.

The v0.3.0 release adds the shared Migration-006 execution lifecycle while retaining the producer-evidence layout established by v0.2.0:

```text
tool.java-project   v0.3.0
Java CI baseline    Eclipse Temurin 8.0.504+1
Maven               3.9.16
Maven Wrapper       3.3.4
tool.git-project    v0.2.8 / 7c43f37e7b07cfb57638a1d1dad2501de09ba7eb
```

One producer execution has one canonical retained execution log at `evidence/executions/java-canonical/execution.log`. The generated README is the navigation/evidence map, so the byte-identical legacy `evidence/execution.log` path remains removed. The `brainboxemb.execution-evidence` schema remains version 1; v0.3.0 changes repository execution/orchestration rather than the canonical producer-envelope fields.

A consumer should express the semantic Java-tool release in its project dependency configuration while reusable GitHub workflow callers remain pinned to a deliberate released interface. This gives people a readable version while keeping cross-repository workflow composition controlled.

Generic repository-lifecycle workflows are consumed from their own released owner. Java affected querying, release-request/tag orchestration, generated-output publication and PR-preview cleanup therefore build on released `tool.git-project v0.2.8` contracts rather than copying Git/Moon/runtime, tag, branch-selection, push or deletion mechanics into this repository. `tool.git-project v0.2.8` also owns the normative `brainboxemb.execution-evidence` v1 schema; Java remains responsible for emitting that envelope at the real canonical producer boundary.

The intended external-consumer model mirrors the SCAD project family:

```text
tool.java-project
    reusable project workflow and conventions

template.java-project
    canonical minimal external reference consumer

real Java repositories
    product-specific implementation and realistic integration evidence
```

The internal fixture in this repository remains the fast first-line tooling test. The separate `template.java-project` reference consumer proves that the released contract can actually be consumed from a clean independent repository; real products then provide additional realistic evidence.

## Initial toolchain baseline

- Java: Eclipse Temurin 8u504-b01 for hosted Linux/Windows CI;
- Java language/API/bytecode baseline: Java SE 8;
- Maven: 3.9.16 through Maven Wrapper;
- Maven Wrapper: 3.3.4 scripts;
- canonical artifact producer: GitHub-hosted Linux;
- compatibility environment: GitHub-hosted Windows;
- Docker: not required for normal compile/unit-test paths.

The baseline values are also recorded in `project.java.yml`. The reusable workflows continue to take explicit inputs in this revision; consumers retain their own Maven/POM/module layout and product tests.

## Local checkout and bootstrap

A normal checkout does not need `--recurse-submodules`.

On Windows:

```powershell
git clone https://github.com/brainboxemb/tool.java-project.git
cd tool.java-project
.\bootstrap.ps1
```

On Linux/POSIX shell:

```bash
git clone https://github.com/brainboxemb/tool.java-project.git
cd tool.java-project
./bootstrap.sh
```

The root launcher restores the exact committed `tools/tool.git-project` gitlink and delegates generic dependency handling to it. `update-repo.ps1` / `update-repo.sh` perform the controlled generic dependency-update pass after bootstrap.

The v0.3.0 line pins that bootstrap gitlink to the exact `tool.git-project v0.2.8` release commit. This provides the released generic bootstrap, Moon affected-query/runtime portability, preview cleanup, stale-safe generated-output publication, release-request/tag lifecycle, and execution-evidence schema used by Java CI.

For this repository `project.yml` currently has no additional managed externals; it exists to establish the shared generic/project-profile structure and to prove the same local flow consumers will use.

## Repository structure

```text
.github/workflows/
  reusable-java-verify.yml                   reusable canonical build/test workflow
  reusable-java-production.yml               shared affected/preflight production lifecycle
  reusable-java-windows-compatibility.yml    selective Windows smoke/full qualification
  reusable-java-publish.yml                  thin bld wrapper around generic Git publisher
  affected-policy-test.yml                   affected/Windows classification regression proof
  pr-cleanup.yml                             thin caller of tagged generic Git cleanup
  local-action-test.yml                      direct stable-action fixture proof
  self-test.yml                              local-bootstrap + Java fixture/release proof
  release.yml                                thin caller of generic repository release lifecycle
docs/
  consumer-usage.md                          workflow contract, pinning and evidence model
  execution-lifecycle.md                     Migration-006 execution and ownership contract
  local-canonical-action.md                  stable local domain-action contract

fixture/
  minimal-java-app/                          generic runnable Java 8 test fixture

support/
  SurefireSummary.java                       JDK-only readable Surefire report generator

tools/
  tool.git-project/                          pinned bootstrap submodule

java-preflight.sh                            Java impact / Windows-mode classification
java-project.sh                              stable local Java domain action
VERSION                                      tool.java-project release version
project.yml                                  generic repository/profile declaration
project.java.yml                             Java-specific baseline
bootstrap.ps1 / bootstrap.sh
update-repo.ps1 / update-repo.sh
AGENTS.md
CHANGELOG.md
README.md
```

## Consumer direction

A consumer repository keeps its own `pom.xml`, source/tests and Maven Wrapper. It can use the same generic Git bootstrap pattern locally, call the stable local Java action, and/or call the reusable workflows from this repository using a deliberate pinned reference.

See [`docs/consumer-usage.md`](docs/consumer-usage.md) for the complete CI contract and example caller workflow, [`docs/execution-lifecycle.md`](docs/execution-lifecycle.md) for repository production, and [`docs/local-canonical-action.md`](docs/local-canonical-action.md) for the local/orchestration-facing producer action.

The reusable Java workflows provide generic behaviour such as:

- exact source/base preflight before Java runtime allocation;
- one generic affected query through released `tool.git-project`;
- explicit Java provisioning only for affected Java work;
- invocation of the stable canonical local action on Linux;
- Maven Wrapper version/use validation;
- Linux canonical verification and artifact production;
- test-report/artifact collection;
- one retained canonical producer execution log, common execution evidence and build provenance;
- a generated evidence map that explains producer/domain/orchestration/publication roles;
- selective Windows `none|smoke|full` qualification;
- exact Linux-canonical-artifact execution on Windows for smoke/full modes;
- native Windows Maven verification only for full mode;
- optional staging/finalization of selected canonical build files for generated publication without a duplicate Maven build.

The Java publication wrapper passes that prepared bundle to the released generic Git publisher with suffix `bld`. The resulting lifecycle is:

- `dev/pr-<PR-number>/bld` for a same-repository pull request;
- `prod/bld` for a push to `main`;
- `rel/vX.Y.Z/bld` for a versioned release tag.

Keeping preparation separate from publication allows normal verification jobs to remain read-only. Fork pull requests do not publish generated branches. Java does not implement branch mapping or Git push mechanics itself.

## PR-preview cleanup

`dev/pr-<N>/bld` is temporary review output. When the pull request closes, `.github/workflows/pr-cleanup.yml` delegates branch cleanup to the released generic Git workflow:

```text
brainboxemb/tool.git-project/.github/workflows/
  reusable-pr-preview-cleanup.yml@v0.2.8
```

Java supplies only its domain-owned preview suffix, `bld`. `tool.git-project` owns the branch deletion mechanics and constrains targets to `dev/pr-<positive integer>/<validated suffix>`.

The caller also exposes `workflow_dispatch` with a PR number for deliberate cleanup of a stale legacy preview. Manual cleanup does not request source-branch deletion; automatic cleanup may delete the merged same-repository source branch.

Product repositories should follow the same thin-caller pattern rather than copy Git deletion scripts.

## Generated build-output boundary

A generated `bld` branch contains build output/evidence only. A typical producer tree is:

```text
artifacts/
  <selected canonical build files>

evidence/
  toolchain-build-provenance.txt
  executions/
    java-canonical/
      execution.json
      execution.log
  tests/
    README.md
    ... raw Surefire reports ...

README.md
source-sha.txt
```

`evidence/executions/java-canonical/execution.json` is the stable domain-neutral entry point for the producer execution. It identifies the logical Java source revision separately from the exact `tool.java-project` owner revision and points to the richer Java provenance/Surefire evidence. Its `log` field resolves to the single canonical retained producer log beside it.

The generated `README.md` is the human-facing evidence map. It distinguishes artifacts, producer execution evidence, richer Java/domain evidence, current orchestration/materialization evidence and publication context. Navigation is therefore solved by the index instead of retaining the same log under multiple paths.

It must not contain a source checkout or managed tooling repositories. Temporary Actions artifacts continue to exist for job-to-job transfer and short-lived downloads; the generated branch is the convenient browsable view.

The build/preparation action remains separate from publication. This is important for repository-level output caching: a prepared canonical output tree may be built or hydrated, while pushing a generated branch is still an explicit external side effect. Current orchestration/materialization evidence, when used by a consumer, stays separate and must not rewrite retained Java producer provenance.

When cache hydration reuses input-equivalent producer output, the retained producer `source_revision` may intentionally be older than the current `orchestration/materialization.json` source revision. `orchestration/moon.log` records the current execute/cache/hydrate decision. That difference is expected provenance, not duplicate or conflicting evidence.

## Release workflow

A tool release is prepared by a normal reviewed PR that sets a non-SNAPSHOT `VERSION` and moves the corresponding changes from `Unreleased` into a dated CHANGELOG section.

Before merge, the PR proves the affected-policy contract, direct local canonical action and the full Linux/Windows self-test. After the release-preparation commit is merged, `.github/workflows/release.yml` uses the green exact-main `self-test.yml` result as the release gate and calls the released generic repository lifecycle in `tool.git-project v0.2.8`. That generic layer validates the exact current `main` SHA, `VERSION`, CHANGELOG section and required main workflow result, creates the annotated `vX.Y.Z` tag, dispatches `self-test.yml` at that tag, waits for it, and removes the temporary release-request branch.

The tagged Java self-test then owns the Java-specific half of release finalization:

1. rerun Linux/Windows bootstrap, fixture build/test, canonical artifact smoke and readable Surefire evidence from the tagged source;
2. validate the common Java producer execution envelope against the released generic schema;
3. publish the prepared canonical build tree through `tool.git-project` to `rel/vX.Y.Z/bld`;
4. prepare Java/JDK/Maven/Maven-Wrapper provenance;
5. only after the tagged test and persistent release-output publication are green, create the Java GitHub Release and attach its provenance manifest.

This separation keeps generic Git/repository release mechanics out of Java while retaining Java-specific release evidence with its semantic owner. Consumers remain on the last released tag until they deliberately update.

## Boundaries

Do not add product-specific assumptions here, including:

- timing-system module names or domain behaviour;
- RFID/CAN/display/backoffice logic;
- proprietary/private protocol data or credentials;
- one product's Raspberry Pi image content;
- Docker services merely because a Java build exists.

Cross-repository engineering-documentation assembly remains outside `tool.java-project`. Generic base/head affected mechanics remain in `tool.git-project`; Java owns only the Java-specific classification and execution semantics layered on that generic result.

Docker/Compose may be introduced by consumers for real external-service integration tests such as RabbitMQ, but it is not part of the fast Java build baseline.

## Evidence

The repository self-test proves independent layers:

1. local root bootstrap/update on Ubuntu and Windows using the pinned `tool.git-project v0.2.8` gitlink;
2. the stable local canonical action against the internal fixture;
3. exact base/head affected classification, including unrelated -> none, normal Java -> smoke and build/toolchain-sensitive -> full;
4. Java fixture verification through the reusable workflow:
   - Linux canonical action and artifact production;
   - native Windows `verify` on the full path;
   - execution on Windows of the exact JAR uploaded by the Linux canonical job;
5. readable Surefire summary, one canonical retained producer log, schema-valid common Java execution evidence and the generated evidence-map README from the canonical producer output;
6. Java release, publication and cleanup callers are pinned to released `tool.git-project@v0.2.8`;
7. on pull requests, publication of the prepared fixture build tree to `dev/pr-N/bld` through the stale-safe generic publisher;
8. on `main`, publication to `prod/bld` through the same generic publisher;
9. on a release tag, publication to `rel/vX.Y.Z/bld` before the Java GitHub Release is published.

Linux Java evidence also includes test reports and `toolchain-build-provenance.txt`. The prepared publication tree carries the common `evidence/executions/java-canonical/{execution.json,execution.log}` pair and deliberately does not retain a second byte-identical legacy log.

## Development workflow

Follow [`AGENTS.md`](AGENTS.md): reserve issue `#N`, create `feature/pr-N-<short-slug>`, make the smallest initial commit, convert that same issue directly into draft PR `#N`, and continue evidence/review in that same work item before merge.