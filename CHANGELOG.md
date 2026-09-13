# Changelog

## Unreleased

- Add stable local `java-project.sh canonical` action for the existing canonical Maven lifecycle.
- Make the Linux reusable canonical workflow call the same local action used by local/repository orchestration instead of maintaining a second inline implementation.
- Retain the human-readable canonical Maven execution log alongside toolchain provenance and Surefire evidence.
- Generate the readable Surefire summary through a JDK-only helper so the canonical local action does not add Python as a Java-build prerequisite.
- Keep publication/finalization separate from the cacheable/prepared canonical output tree.

## 0.1.0 — 2026-09-13

- Bootstrap reusable Java/Maven build and test tooling.
- Establish Java 8, Maven Wrapper, Linux canonical build and Windows compatibility direction.
- Add optional generated build-output publication from the canonical Linux build:
  - pull request #N -> `dev/pr-N/bld`;
  - `main` -> `prod/bld`;
  - selected canonical artifacts, provenance and test evidence;
  - separate read-only verification and write-enabled publication workflows.
- Generate a human-readable `evidence/tests/README.md` from the canonical Surefire XML without rerunning tests, including overall, module and suite totals plus failure/error details.
- Add a versioned tool-release workflow that tags an exact already-verified `main` commit, reruns the full self-test from the release tag and publishes the GitHub Release only after the tagged self-test is green.
