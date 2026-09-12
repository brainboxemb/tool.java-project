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

docs/
  consumer-usage.md          workflow contract, pinning and evidence model

fixture/
  minimal-java-app/          generic runnable Java 8 test fixture

AGENTS.md
CHANGELOG.md
README.md
```

## Consumer direction

A consumer repository keeps its own `pom.xml`, source/tests and Maven Wrapper, then calls the reusable workflow from this repository using a deliberate pinned reference.

See [`docs/consumer-usage.md`](docs/consumer-usage.md) for the complete contract and example caller workflow.

The reusable workflow provides generic behaviour such as:

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

The repository self-test uses the generic fixture to prove all three initial paths:

1. Linux canonical `verify` and artifact production;
2. independent Windows `verify`;
3. execution on Windows of the exact JAR uploaded by the Linux canonical job.

Linux evidence also includes test reports and `toolchain-build-provenance.txt`.

## Development workflow

Changes use issue → feature branch → draft PR → evidence/review → merge.

The initial bootstrap work is tracked in issue/PR #1.
