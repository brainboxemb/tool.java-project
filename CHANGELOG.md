# Changelog

## Unreleased

- Bootstrap reusable Java/Maven build and test tooling.
- Establish Java 8, Maven Wrapper, Linux canonical build and Windows compatibility direction.
- Add optional generated build-output publication from the canonical Linux build:
  - pull request #N -> `dev/pr-N/bld`;
  - `main` -> `prod/bld`;
  - selected canonical artifacts, provenance and test evidence;
  - separate read-only verification and write-enabled publication workflows.
