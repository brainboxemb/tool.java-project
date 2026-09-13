# Changelog

## Unreleased

## 0.1.3 — 2026-09-13

- Expose the existing native-Windows compatibility build and exact Linux-canonical-artifact smoke as a separately consumable reusable workflow.
- Keep Maven Wrapper validation, Windows `mvn verify`, test evidence, and canonical-artifact smoke owned by `tool.java-project` instead of copying Java build semantics into repository templates.
- Refactor the existing all-in-one Java verify workflow to call the new Windows capability after its Linux canonical build, preserving current behaviour while proving the new interface in owner CI.
- Enable Moon-orchestrated consumers to execute the Linux canonical Maven lifecycle once, then retain the established independent Windows evidence without triggering a second Linux build.

## 0.1.2 — 2026-09-13

- Delegate generated branch materialization to the released `tool.git-project` generic publisher instead of duplicating Git branch-selection/push logic in Java tooling.
- Use one released generic Git lifecycle baseline, `tool.git-project v0.1.3`, for bootstrap, PR-preview cleanup, generated-output publication, and release-request/tag orchestration.
- Replace the long Java-owned release-request/tag implementation with a thin caller to the generic `tool.git-project v0.1.3` release workflow.
- Keep Java-specific tagged verification, `rel/vX.Y.Z/bld` publication, Java/JDK/Maven/Maven-Wrapper provenance, and the Java GitHub Release asset in `tool.java-project`.
- Use the stale-safe generic publisher from `tool.git-project v0.1.3`, preventing older successful workflow runs from overwriting newer `dev/pr-N/bld` or `prod/bld` output.
- Extend the Java generated-output lifecycle to release tags: `vX.Y.Z` publishes the prepared canonical build tree to `rel/vX.Y.Z/bld`.
- Require successful persistent release-build publication before creating the Java GitHub Release.
- Retain Java ownership of canonical Maven execution, the prepared `bld` tree, and Java-specific artifact/evidence/provenance semantics.
- Backfill `rel/v0.1.1/bld` from the already verified `prod/bld` output for the same source commit without retagging or rebuilding v0.1.1.

## 0.1.1 — 2026-09-13

- Add stable local `java-project.sh canonical` action for the existing canonical Maven lifecycle.
- Make the Linux reusable canonical workflow call the same local action used by local/repository orchestration instead of maintaining a second inline implementation.
- Retain the human-readable canonical Maven execution log alongside toolchain provenance and Surefire evidence.
- Generate the readable Surefire summary through a JDK-only helper so the canonical local action does not add Python as a Java-build prerequisite.
- Keep publication/finalization separate from the cacheable/prepared canonical output tree.
- Use the released `tool.git-project v0.1.0` reusable cleanup workflow for Java `dev/pr-<N>/bld` lifecycle cleanup instead of adding Java-specific branch-deletion logic.
- Provide both automatic `pull_request: closed` cleanup and an explicit manual cleanup entry for legacy/stale PR previews.
- Adopt the exact `tool.git-project v0.1.0` bootstrap-tool commit so local Java tooling also receives the corrected dirty-worktree-before-checkout ordering.
- Restore the documented main-publication lifecycle by invoking the generated-output publisher on `main`, producing the `prod/bld` branch after a successful canonical build.

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
