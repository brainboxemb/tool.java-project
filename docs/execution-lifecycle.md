# Java execution lifecycle

## Why this document exists

`tool.java-project` is the shared owner of Java/Maven execution behaviour. This document defines the lifecycle contract that consumer repositories should be able to call without copying orchestration logic into every Java project.

Use this document when changing the reusable Java production workflow, affected-change policy, Windows qualification, Java evidence or generated Java-output publication. It deliberately does not define project-family planning/architecture documentation; that remains outside Java tooling.

## Lifecycle shape

Java follows the same cross-domain lifecycle vocabulary used elsewhere where the underlying build system permits it:

```text
affected / preflight
        |
        +--> unrelated -> stop
        |
        v
execute or materialize
        |
        v
verify
        |
        +--> optional Windows qualification
        |
        v
finalize / publish Java-produced output
        |
        v
release qualification when applicable
```

The names and evidence concepts should remain equivalent to SCAD and future implementation domains where practical. Maven remains authoritative for Java build/test semantics; equivalence does not mean forcing Maven into another domain's mechanics.

## Windows qualification modes

Windows qualification is split so normal pull requests do not pay for a full Windows Maven build when the risk does not justify it.

### `none`

No Windows runner is started.

Use for unrelated changes and Java work for which Windows has been explicitly disabled by policy.

### `smoke`

Run the exact canonical Linux-produced runnable JAR on a Windows runner.

This checks the portable artifact on Windows without checking out the source or running a second Maven build.

### `full`

Run both:

1. an independent Windows Maven `verify` using the repository Maven Wrapper; and
2. the exact canonical Linux-produced artifact smoke when a runnable artifact is configured.

Use for Java build/toolchain/platform-sensitive changes and release qualification.

## Policy selection

Normal consumers should use `windows-mode: auto`.

In `auto`, the shared preflight derives qualification from the affected task/capability set:

```text
Java not affected        -> none
Java affected            -> smoke
Windows-full affected    -> full
release qualification    -> full
```

A consumer may expose an explicit override for exceptional/manual qualification:

```text
auto | none | smoke | full
```

`full` is the important escape hatch when a reviewer wants stronger Windows evidence than the automatic impact classification selected. The automatic path remains the default.

## Ownership

`tool.git-project` owns generic exact base/head affected querying and generic generated-output publication mechanics.

`tool.java-project` owns:

- mapping Java capability impact to Java lifecycle decisions;
- canonical Linux Maven execution;
- Java producer/test/provenance evidence;
- Windows smoke/full qualification behaviour;
- Java-produced output preparation/finalization.

Consumers own the task inputs that describe what changes affect their Java and Windows-sensitive capabilities.

Project-family requirements, planning, architecture and assembled engineering documentation are not part of this lifecycle.
