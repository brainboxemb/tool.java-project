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
provenance + retained execution log
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

## Tool release baseline

`VERSION` is the source-controlled release version of `tool.java-project`; it is independent of the Maven version used by any product or fixture. A release tag is `v<VERSION>`.

The v0.1.2 release line contains the production-transition Java boundary plus the generic generated-output lifecycle:

```text
tool.java-project   v0.1.2
Java CI baseline    Eclipse Temurin 8.0.504+1
Maven               3.9.16
Maven Wrapper       3.3.4
tool.git-project    v0.1.1 / bcbec20c33ef924a83ec9e9e8264547de0b331e6
```

A consumer should express the semantic Java-tool release in its project dependency configuration while reusable GitHub workflow callers remain pinned to a deliberate released interface. This gives people a readable version while keeping cross-repository workflow composition controlled.

Generic repository-lifecycle workflows are consumed from their own released owner. Java generated-output publication and PR-preview cleanup therefore call released `tool.git-project v0.1.1` workflows rather than copying Git branch-selection, push, or deletion logic into this repository.

The intended external-consumer model mirrors the SCAD project family:

```text
tool.java-project
    reusable project workflow and conventions

template.java-project
    canonical minimal external reference consumer

real Java repositories
    product-specific implementation and realistic integration evidence
```

The internal fixture in this repository remains the fast first-line tooling test. The separate `template.java-project` reference consumer is intended to prove that the released contract can actually be consumed from a clean independent repository; real products then provide additional realistic evidence.

## Initial toolchain baseline

- Java: Eclipse Temurin 8u504-b01 for hosted Linux/Windows CI;
- Java language/API/bytecode baseline: Java SE 8;
- Maven: 3.9.16 through Maven Wrapper;
- Maven Wrapper: 3.3.4 scripts;
- canonical artifact producer: GitHub-hosted Linux;
- compatibility environment: GitHub-hosted Windows;
- Docker: not required for normal compile/unit-test paths.

The baseline values are also recorded in `project.java.yml`. The reusable workflows continue to take explicit inputs in this revision; later tooling may validate/read the Java profile directly once the profile contract has been exercised by real consumers.

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

The v0.1.2 line pins that bootstrap gitlink to the exact `tool.git-project v0.1.1` release commit. This carries both the dirty-worktree-before-checkout protection and the generic generated-output/preview lifecycle used by Java CI.

For this repository `project.yml` currently has no additional managed externals; it exists to establish the shared generic/project-profile structure and to prove the same local flow consumers will use.

## Repository structure

```text
.github/workflows/
  reusable-java-verify.yml    reusable canonical build/test workflow
  reusable-java-publish.yml   thin bld wrapper around generic Git publisher
  pr-cleanup.yml              thin caller of tagged generic Git cleanup
  local-action-test.yml       direct stable-action fixture proof
  self-test.yml               local-bootstrap + Java fixture proof
  release.yml                 exact-commit tool release/tag dispatcher

docs/
  consumer-usage.md           workflow contract, pinning and evidence model
  local-canonical-action.md   stable local domain-action contract

fixture/
  minimal-java-app/           generic runnable Java 8 test fixture

support/
  SurefireSummary.java        JDK-only readable Surefire report generator

tools/
  tool.git-project/           pinned bootstrap submodule

java-project.sh               stable local Java domain action
VERSION                       tool.java-project release version
project.yml                   generic repository/profile declaration
project.java.yml              Java-specific baseline
bootstrap.ps1 / bootstrap.sh
update-repo.ps1 / update-repo.sh
AGENTS.md
CHANGELOG.md
README.md
```

## Consumer direction

A consumer repository keeps its own `pom.xml`, source/tests and Maven Wrapper. It can use the same generic Git bootstrap pattern locally, call the stable local Java action, and/or call the reusable workflows from this repository using a deliberate pinned reference.

See [`docs/consumer-usage.md`](docs/consumer-usage.md) for the complete CI contract and example caller workflow, and [`docs/local-canonical-action.md`](docs/local-canonical-action.md) for the local/orchestration-facing action.

The reusable verification workflow provides generic Java behaviour such as:

- explicit Java provisioning;
- invocation of the stable canonical local action on Linux;
- Maven Wrapper version/use validation;
- Linux canonical verification and artifact production;
- test-report/artifact collection;
- retained canonical execution logging and build provenance;
- Windows compatibility verification;
- canonical-artifact execution smoke tests when configured;
- optional staging of selected canonical build files for generated publication.

The Java publication wrapper passes that prepared bundle to the released generic Git publisher with suffix `bld`. The resulting lifecycle is:

- `dev/pr-<PR-number>/bld` for a same-repository pull request;
- `prod/bld` for a push to `main`;
- `rel/vX.Y.Z/bld` for a versioned release tag.

Keeping preparation separate from publication allows normal verification jobs to remain read-only. Fork pull requests do not publish generated branches. Java does not implement branch mapping or Git push mechanics itself.

## PR-preview cleanup

`dev/pr-<N>/bld` is temporary review output. When the pull request closes, `.github/workflows/pr-cleanup.yml` delegates branch cleanup to the released generic Git workflow:

```text
brainboxemb/tool.git-project/.github/workflows/
  reusable-pr-preview-cleanup.yml@v0.1.1
```

Java supplies only its domain-owned preview suffix, `bld`. `tool.git-project` owns the branch deletion mechanics and constrains targets to `dev/pr-<positive integer>/<validated suffix>`.

The caller also exposes `workflow_dispatch` with a PR number for deliberate cleanup of a stale legacy preview. Manual cleanup does not request source-branch deletion; automatic cleanup may delete the merged same-repository source branch.

Product repositories should follow the same thin-caller pattern rather than copy Git deletion scripts.

## Generated build-output boundary

A generated `bld` branch contains build output/evidence only. A typical tree is:

```text
artifacts/
  <selected canonical build files>

evidence/
  execution.log
  toolchain-build-provenance.txt
  tests/
    README.md
    ... raw Surefire reports ...

README.md
source-sha.txt
```

It must not contain a source checkout or managed tooling repositories. Temporary Actions artifacts continue to exist for job-to-job transfer and short-lived downloads; the generated branch is the convenient browsable view.

The build/preparation action remains separate from publication. This is important for repository-level output caching: a prepared canonical output tree may be built or hydrated, while pushing a generated branch is still an explicit external side effect.

## Release workflow

A tool release is prepared by a normal reviewed PR that sets a non-SNAPSHOT `VERSION` and moves the corresponding changes from `Unreleased` into a dated CHANGELOG section.

After the release-preparation commit is merged and its normal `main` self-test is green, `.github/workflows/release.yml` is given the intended `vX.Y.Z` and the exact already-verified `main` commit SHA. The release workflow refuses a version/tag mismatch, a non-current `main` SHA, an existing tag or a missing CHANGELOG release section.

The workflow then:

1. creates an annotated immutable `vX.Y.Z` tag on the exact verified commit;
2. explicitly dispatches `self-test.yml` at that tag;
3. reruns Linux/Windows bootstrap, fixture build/test, canonical artifact smoke and readable Surefire evidence from the tagged source;
4. publishes the prepared canonical build tree through `tool.git-project` to `rel/vX.Y.Z/bld`;
5. only after the tagged self-test and persistent release-output publication are green, creates the GitHub Release and attaches a small release-provenance manifest.

Consumers remain on the last released tag until they deliberately update.

## Boundaries

Do not add product-specific assumptions here, including:

- timing-system module names or domain behaviour;
- RFID/CAN/display/backoffice logic;
- proprietary/private protocol data or credentials;
- one product's Raspberry Pi image content;
- Docker services merely because a Java build exists.

Repository-level orchestration also remains outside this repository: Moon task selection/cache policy is not part of `tool.java-project`. This repository exposes stable Java domain actions that such an orchestrator may call.

Docker/Compose may be introduced by consumers for real external-service integration tests such as RabbitMQ, but it is not part of the fast Java build baseline.

## Evidence

The repository self-test proves independent layers:

1. local root bootstrap/update on Ubuntu and Windows using the pinned `tool.git-project v0.1.1` gitlink;
2. the stable local canonical action against the internal fixture;
3. Java fixture verification through the reusable workflow:
   - Linux canonical action and artifact production;
   - independent Windows `verify`;
   - execution on Windows of the exact JAR uploaded by the Linux canonical job;
4. readable Surefire summary generated from the canonical test XML without rerunning tests;
5. Java publication and cleanup callers are pinned to released `tool.git-project@v0.1.1`;
6. on pull requests, publication of the prepared fixture build tree to `dev/pr-N/bld` through the generic publisher;
7. on `main`, publication to `prod/bld` through the same generic publisher;
8. on a release tag, publication to `rel/vX.Y.Z/bld` before the GitHub Release is published.

Linux Java evidence also includes test reports, `toolchain-build-provenance.txt` and `java-canonical-execution.log`. The prepared publication tree carries the execution log as `evidence/execution.log`.

## Development workflow

Changes use issue → feature branch → draft PR → evidence/review → merge.
