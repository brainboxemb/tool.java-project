# Consumer usage

`tool.java-project` provides reusable Java/Maven engineering workflow behaviour. A consumer repository remains responsible for its own source code, `pom.xml`, tests, module layout and Maven Wrapper files.

## Consumer prerequisites

A Java consumer should contain at least:

```text
pom.xml
mvnw
mvnw.cmd
.mvn/wrapper/maven-wrapper.properties
src/...
```

For the initial baseline the expected toolchain is:

```text
Java              Eclipse Temurin 8u504-b01 (`8.0.504+1` in setup-java)
Java source/API    Java SE 8
Maven              3.9.16
Maven Wrapper      3.3.4
```

The repository Maven Wrapper owns the Maven distribution. A globally installed Maven is not required by the workflow.

## Reusable workflow

A consumer calls `.github/workflows/reusable-java-verify.yml` from this repository.

While the toolchain is pre-v1, pin the workflow to an **immutable full commit SHA**. Do not consume the moving `main` branch.

Example:

```yaml
name: Java verification

on:
  pull_request:
  push:
    branches: [main]

permissions:
  contents: read

jobs:
  java:
    uses: brainboxemb/tool.java-project/.github/workflows/reusable-java-verify.yml@<full-commit-sha>
    with:
      working-directory: .
      java-version: '8.0.504+1'
      maven-version: '3.9.16'
      maven-wrapper-version: '3.3.4'
      artifact-name: my-app-canonical
      artifact-path: target/my-app.jar
      runnable-jar-name: my-app.jar
      smoke-expected-output: 'optional exact stdout'
      test-report-path: target/surefire-reports/**
```

`runnable-jar-name` is optional. If omitted, the Windows canonical-artifact smoke job is skipped. `smoke-expected-output` is also optional; when supplied, the job requires exact trimmed stdout from `java -jar`.

## What the reusable workflow proves

### Linux canonical build

The Linux job:

1. checks out the consumer commit;
2. provisions the exact configured Temurin Java baseline;
3. validates the Maven Wrapper and expected Maven/Wrapper versions;
4. runs `./mvnw verify`;
5. records build provenance;
6. uploads the configured canonical artifact;
7. uploads test/provenance evidence.

Linux is the canonical artifact producer for the initial toolchain.

### Windows compatibility build

The Windows job independently checks out the same consumer source, provisions the same Java baseline, validates `mvnw.cmd`, and runs `mvnw.cmd verify`.

This catches operating-system-specific build/test assumptions rather than hiding Windows behind a Linux container.

### Windows canonical-artifact smoke

When `runnable-jar-name` is supplied, a separate Windows job downloads the **exact artifact produced by the Linux canonical job** and runs it with Java 8.

This distinguishes:

```text
source builds on Windows
```

from:

```text
canonical Linux-produced artifact really runs on Windows
```

Both forms of evidence are useful.

## Provenance

The Linux evidence contains `target/toolchain-build-provenance.txt`, including:

- toolchain contract version;
- repository/event/ref information;
- actually checked-out GitHub SHA;
- pull-request head/base SHA where available;
- reusable workflow reference;
- runner OS/architecture;
- configured Java, Maven and Maven Wrapper baselines;
- observed Java and Maven runtime versions.

For pull-request workflows GitHub may build a synthetic PR merge commit. The provenance therefore records the actually built SHA separately from the pull-request head/base SHA.

## Versioning and pinning policy

Initial/pre-v1 policy:

- consumers pin a full immutable commit SHA;
- adopting a new toolchain commit is an explicit reviewed dependency/tooling update;
- `main` is not a stable consumer contract.

After the workflow contract has been exercised by real consumers, the repository may publish a deliberate `v1` release/tag policy. A moving major tag should only be introduced with a documented compatibility/update policy; immutable commits remain valid for maximum reproducibility.

## Docker

Docker is intentionally **not required** by this workflow. Java compilation/unit tests need only the provisioned JDK plus the repository Maven Wrapper.

Consumers may use Docker/Compose in separate integration jobs when a real external service makes it useful, such as RabbitMQ. Those integration fixtures should not become a prerequisite for the fast generic Java verify path.
