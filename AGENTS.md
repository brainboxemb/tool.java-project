# AGENTS.md

## Repository purpose

This repository contains reusable Java/Maven engineering tooling. Keep it generic and independently testable.

## Core rules

- Use one work-item number end to end: create issue `#N`, create `feature/pr-N-<short-slug>`, make the smallest initial commit, then convert that exact issue directly into draft PR `#N`; do not create a separate PR number for the same work item when issue conversion is available.
- Continue implementation, evidence/review and merge in that same PR.
- Do not commit directly to `main` for normal work.
- Keep product/domain behaviour out of this repository.
- Consumer repositories keep their own product source, POM/module layout and product tests.
- Use the Maven Wrapper from each Java project rather than assuming a globally installed Maven.
- Keep Java SE 8 as the initial compile/API/bytecode baseline until a deliberate toolchain change is accepted.
- Prefer one canonical platform-neutral Java artifact over OS-specific JARs.
- Linux CI is the canonical artifact producer; Windows CI verifies compatibility and executes the canonical artifact where applicable.
- Do not make Docker a prerequisite for normal compile/unit-test workflows. Use it only when a real external service or integration fixture needs it.
- Record tool/runtime versions explicitly; do not silently follow `latest` for the canonical baseline.
- Reusable workflows should be consumed through a deliberate release/tag or immutable commit reference.
- Keep credentials, secrets and proprietary configuration out of source.

## Repository boundaries

Generic tooling may include:

- reusable GitHub Actions workflows;
- Java/JDK/Maven provisioning policy;
- Maven Wrapper validation;
- test/report/artifact collection;
- build provenance;
- generic fixtures/reference consumers;
- scripts that are genuinely reusable across Java repositories.

Do not include:

- event-timing/SI-01 assumptions;
- RFID/CAN/display/backoffice behaviour;
- proprietary/private protocols;
- one product's Pi image/deployment content;
- application-specific module names as reusable-workflow requirements.

## Evidence

A toolchain change is not complete merely because its YAML parses. Prefer executable evidence:

- Linux fixture `verify` succeeds;
- Windows fixture `verify` succeeds;
- the exact canonical Linux-produced runnable artifact executes on Windows;
- provenance identifies source/toolchain inputs;
- consumer usage is documented.
