# tool.java-project

Reusable Java/Maven engineering tooling for reproducible Linux/Windows builds, testing, CI workflows, artifacts, build provenance, and generated build-output publication.

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
  Maven Wrapper / Java verification / reusable CI
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
provenance
    ↓
Windows compatibility execution of that exact artifact
```

Consumers may additionally opt in to generated build publication:

```text
canonical Linux build
    ↓
prepared publication bundle
    ↓
PR     → dev/pr-N/bld
main   → prod/bld
```

The publication step reuses the canonical build; it does not run a second Maven build merely to populate the generated branch.

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

For this repository `project.yml` currently has no additional managed externals; it exists to establish the shared generic/project-profile structure and to prove the same local flow consumers will use.

## Repository structure

```text
.github/workflows/
  reusable-java-verify.yml    reusable canonical build/test workflow
  reusable-java-publish.yml   optional generated build-output publisher
  self-test.yml               local-bootstrap + Java fixture proof

docs/
  consumer-usage.md           workflow contract, pinning and evidence model

fixture/
  minimal-java-app/           generic runnable Java 8 test fixture

tools/
  tool.git-project/           pinned bootstrap submodule

project.yml                   generic repository/profile declaration
project.java.yml              Java-specific baseline
bootstrap.ps1 / bootstrap.sh
update-repo.ps1 / update-repo.sh
AGENTS.md
CHANGELOG.md
README.md
```

## Consumer direction

A consumer repository keeps its own `pom.xml`, source/tests and Maven Wrapper. It can use the same generic Git bootstrap pattern locally and call the reusable workflows from this repository using a deliberate pinned reference.

See [`docs/consumer-usage.md`](docs/consumer-usage.md) for the complete CI contract and example caller workflow.

The reusable verification workflow provides generic Java behaviour such as:

- explicit Java provisioning;
- Maven Wrapper version/use validation;
- Linux canonical verification and artifact production;
- test-report/artifact collection;
- build provenance;
- Windows compatibility verification;
- canonical-artifact execution smoke tests when configured;
- optional staging of selected canonical build files for generated publication.

The separate publication workflow can publish that prepared bundle as:

- `dev/pr-<PR-number>/bld` for a same-repository pull request;
- `prod/bld` for a push to `main`.

Keeping publication separate allows normal verification jobs to remain read-only. Fork pull requests do not publish generated branches.

Product repositories remain responsible for their own source code, dependencies, tests, module layout and product-specific configuration.

## Generated build-output boundary

A generated `bld` branch contains build output/evidence only. A typical tree is:

```text
artifacts/
  <selected canonical build files>

evidence/
  toolchain-build-provenance.txt
  tests/...

README.md
source-sha.txt
```

It must not contain a source checkout or managed tooling repositories. Temporary Actions artifacts continue to exist for job-to-job transfer and short-lived downloads; the generated branch is the convenient browsable view.

## Boundaries

Do not add product-specific assumptions here, including:

- timing-system module names or domain behaviour;
- RFID/CAN/display/backoffice logic;
- proprietary/private protocol data or credentials;
- one product's Raspberry Pi image content;
- Docker services merely because a Java build exists.

Docker/Compose may be introduced by consumers for real external-service integration tests such as RabbitMQ, but it is not part of the fast Java build baseline.

## Evidence

The repository self-test proves independent layers:

1. local root bootstrap/update on Ubuntu and Windows using the pinned `tool.git-project` gitlink;
2. Java fixture verification:
   - Linux canonical `verify` and artifact production;
   - independent Windows `verify`;
   - execution on Windows of the exact JAR uploaded by the Linux canonical job;
3. on pull requests, publication of the prepared fixture build tree to `dev/pr-N/bld`.

Linux Java evidence also includes test reports and `toolchain-build-provenance.txt`.

## Development workflow

Changes use issue → feature branch → draft PR → evidence/review → merge.
