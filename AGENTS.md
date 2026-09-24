# Repository agent guidance

This file is for agents changing `tool.java-project` itself. Java consumer
repositories do **not** inherit these instructions.

Before repository work, read the shared BrainboxEmb agent entrypoint:

- [brainboxemb.meta/AGENTS.md](https://github.com/brainboxemb/brainboxemb.meta/blob/main/AGENTS.md)

It owns the current generic Git/commit/PR/CI workflow and routes to shared
repository-tooling and software/Java guidance.

## Local technical entrypoints

For durable `tool.java-project` behaviour, start with:

- [README.md](README.md) — repository purpose, Java baseline and lifecycle overview;
- [docs/consumer-usage.md](docs/consumer-usage.md) — released consumer contract and pinning model;
- [docs/execution-lifecycle.md](docs/execution-lifecycle.md) — Java execution and ownership boundary;
- [docs/local-canonical-action.md](docs/local-canonical-action.md) — canonical local Java action;
- [project.java.yml](project.java.yml) — current Java/Maven toolchain baseline;
- [VERSION](VERSION) and [CHANGELOG.md](CHANGELOG.md) — release identity/history.

Use source, fixtures, workflows and live CI for implementation/current-state evidence.

## Owner boundaries

Keep ownership explicit:

- generic repository/dependency/bootstrap/publication mechanics belong in `tool.git-project`;
- reusable Java/Maven execution, evidence and Windows qualification belong here;
- consumer repositories own product source, POM/module layout and product tests;
- project-family requirements, architecture and engineering-document assembly stay outside this repository.

Keep Java tooling generic and independently testable. Product/domain assumptions,
credentials, proprietary protocols or product-specific deployment behaviour do
not belong here.

## Consumer boundary

Pinned consumers reconstruct exact tool behaviour from their own configuration,
immutable workflow/gitlink refs and this pinned revision's README, docs, source,
fixtures and tests.

They should not use this owner `AGENTS.md` as consumer working guidance.

## Local constraints

Retain the repository's documented Java SE 8 / Maven Wrapper baseline until a
deliberate toolchain change is accepted. Linux remains the canonical artifact
producer and Windows provides compatibility qualification as documented in the
repository lifecycle.

Do not make Docker a prerequisite for the normal Java compile/unit-test path
unless a concrete integration requirement justifies it.

When changing a public reusable workflow or Java tooling contract, update the
owning README/docs/source/tests and qualify the exact PR head before merge.
