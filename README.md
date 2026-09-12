# tool.java-project

Reusable Java/Maven engineering tooling for reproducible Linux/Windows builds, testing, CI workflows, artifacts, and build provenance.

## Purpose

This repository owns generic Java-project engineering behaviour that can be reused by product repositories. It deliberately does **not** own product/domain behaviour.

The initial baseline proves:

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

The first real product consumer will be created only after this repository can prove the toolchain with its own generic fixture.

## Repository structure

```text
.github/workflows/
  reusable-java-verify.yml   reusable consumer workflow
  self-test.yml              repository/fixture proof

fixture/
  minimal-java-app/          generic runnable Java 8 test fixture

scripts/
  collect-build-info.py      build provenance helper

AGENTS.md
CHANGELOG.md
README.md
```

## Consumer direction

A consumer repository should keep its own `pom.xml` and Maven Wrapper, then call a versioned/pinned reusable workflow from this repository.

The reusable workflow is intended to provide generic behaviour such as:

- explicit Java provisioning;
- Maven Wrapper validation/use;
- Linux canonical verification and artifact production;
- test-report/artifact collection;
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

## Development workflow

Changes use issue → feature branch → draft PR → evidence/review → merge.

The initial bootstrap work is tracked in issue/PR #1.
