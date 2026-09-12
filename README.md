# tool.java-project

Reusable Java/Maven engineering tooling for reproducible Linux/Windows builds, testing, CI workflows, artifacts, and build provenance.

## Purpose

This repository owns generic Java-project engineering behaviour that can be reused by product repositories. It deliberately does **not** own product/domain behaviour.

The Java tool now sits on top of the generic Git-project bootstrap layer:

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

The initial Java baseline proves:

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

## Initial toolchain baseline

- Java: Eclipse Temurin 8u504-b01 for hosted Linux/Windows CI;
- Java language/API/bytecode baseline: Java SE 8;
- Maven: 3.9.16 through Maven Wrapper;
- Maven Wrapper: 3.3.4 scripts;
- canonical artifact producer: GitHub-hosted Linux;
- compatibility environment: GitHub-hosted Windows;
- Docker: not required for normal compile/unit-test paths.

The baseline values are also recorded in `project.java.yml`. The existing reusable workflow continues to take explicit inputs in this revision; later tooling may validate/read the Java profile directly once the profile contract has been exercised by real consumers.

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
  reusable-java-verify.yml   reusable consumer workflow
  self-test.yml              local-bootstrap + Java fixture proof

docs/
  consumer-usage.md          workflow contract, pinning and evidence model

fixture/
  minimal-java-app/          generic runnable Java 8 test fixture

tools/
  tool.git-project/          pinned bootstrap submodule

project.yml                  generic repository/profile declaration
project.java.yml             Java-specific baseline
bootstrap.ps1 / bootstrap.sh
update-repo.ps1 / update-repo.sh
AGENTS.md
CHANGELOG.md
README.md
```

## Consumer direction

A consumer repository keeps its own `pom.xml`, source/tests and Maven Wrapper. It can use the same generic Git bootstrap pattern locally and call the reusable workflow from this repository using a deliberate pinned reference.

See [`docs/consumer-usage.md`](docs/consumer-usage.md) for the complete CI contract and example caller workflow.

The reusable workflow provides generic Java behaviour such as:

- explicit Java provisioning;
- Maven Wrapper version/use validation;
- Linux canonical verification and artifact production;
- test-report/artifact collection;
- build provenance;
- Windows compatibility verification;
- canonical-artifact execution smoke tests when configured.

Product repositories remain responsible for their own source code, dependencies, tests, module layout and product-specific configuration.

## Boundaries

Do not add product-specific assumptions here, including:

- timing-system module names or domain behaviour;
- RFID/CAN/display/backoffice logic;
- proprietary/private protocol data or credentials;
- one product's Raspberry Pi image content;
- Docker services merely because a Java build exists.

Docker/Compose may be introduced by consumers for real external-service integration tests such as RabbitMQ, but it is not part of the fast Java build baseline.

## Evidence

The repository self-test proves two independent layers:

1. local root bootstrap/update on Ubuntu and Windows using the pinned `tool.git-project` gitlink;
2. Java fixture verification:
   - Linux canonical `verify` and artifact production;
   - independent Windows `verify`;
   - execution on Windows of the exact JAR uploaded by the Linux canonical job.

Linux Java evidence also includes test reports and `toolchain-build-provenance.txt`.

## Development workflow

Changes use issue → feature branch → draft PR → evidence/review → merge.
