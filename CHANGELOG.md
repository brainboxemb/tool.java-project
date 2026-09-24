# Changelog

## Unreleased

- Route repository agent guidance through `brainboxemb.meta/AGENTS.md`, keep dependency-owner AGENTS non-inherited by consumers, and retain only Java-tool-specific navigation/boundaries locally.

## 0.3.2 — 2026-09-17

- Preserve Java/Moon preflight decision evidence durably in generated `bld` publication instead of keeping it only as a short-lived Actions artifact.
- Add compact readable preflight logging plus durable workflow/job/step timing evidence so build time can be separated from CI/orchestration overhead.
- Keep preflight as the small fan-out gate; for `full` qualification, allow native Windows Maven verification to run in parallel with the Linux canonical producer while exact-Linux-artifact smoke still waits for Linux output.
- Keep Windows frequency caller-controlled: normal protected-branch PRs can use selective `auto`, ordinary already-qualified `main` publication can use `none`, and explicit/release qualification can force `full`.
- Key Maven dependency caches from all project/module POMs plus wrapper/core-extension inputs so multi-module consumers do not inherit a root-POM-only cache key.
- Keep canonical producer evidence and Maven authority unchanged; publication/finalization adds orchestration evidence without triggering another Maven build.

## 0.3.1 — 2026-09-16

- Fix reusable Java workflows so owner implementation checkouts use the reusable job's `job.workflow_repository` and `job.workflow_sha` instead of caller-associated `github.workflow_sha`.
- Preserve exact released owner identity when `tool.java-project` is called from an independent consumer repository.
- Close the external-consumer blocker exposed by `template.java-project` Migration-006 canary run `35144965034`.

## 0.3.0 — 2026-09-16

- Add the shared Migration-006 Java execution lifecycle with an early exact base-to-head affected preflight before JDK, Maven or Windows allocation.
- Resolve Java and Windows qualification policy from one released `tool.git-project v0.2.8` affected query instead of duplicating repository-impact logic.
- Add selective `windows-mode: auto|none|smoke|full`: normal affected Java changes use exact Linux-artifact smoke, while build/toolchain-sensitive or release qualification can require full native Windows Maven verification.
- Carry the exact selected source revision through preflight, canonical Linux execution, full Windows execution and retained provenance.
- Add the reusable Java production lifecycle and keep generated-output finalization/publication separate from the canonical Maven producer so publication never triggers a duplicate Maven build.
- Keep canonical generated-output publication on the shared technical `bld` namespace and keep engineering-documentation assembly outside Java ownership.
- Align bootstrap, cleanup, publication and release lifecycle integration with released `tool.git-project v0.2.8`.

## 0.2.0 — 2026-09-14

- Make `evidence/executions/java-canonical/execution.log` the single canonical retained Java producer log and remove the byte-identical legacy `evidence/execution.log` compatibility path.
- Keep the released `brainboxemb.execution-evidence` schema at version 1; the cleanup changes retained layout/navigation, not the producer-envelope fields or semantics.
- Turn the generated build-output `README.md` into an evidence map that distinguishes artifacts, producer execution evidence, richer Java/domain evidence, current orchestration/materialization evidence, and publication context.
- Explain in generated output that cache hydration may intentionally retain an older producer `source_revision` while current `orchestration/materialization.json` names the newer input-equivalent revision.
- Preserve the canonical Maven lifecycle, Surefire evidence, toolchain provenance, Java 8 Linux/Windows verification, exact Linux-produced artifact smoke, and generic publication behaviour.

## 0.1.4 — 2026-09-14

- Add the released `brainboxemb.execution-evidence` v1 envelope beside the retained canonical Java execution log without changing the Maven lifecycle.
- Record the logical Java consumer source revision separately from the exact `tool.java-project` owner revision that supplied the canonical action semantics.
- Preserve existing Java-specific toolchain provenance, Surefire reports/summary, and the legacy `evidence/execution.log` compatibility path while exposing `evidence/executions/java-canonical/{execution.json,execution.log}` as the common producer entry point.
- Validate the Java execution envelope against the normative schema published by `tool.git-project v0.2.4` in owner CI without adding Python or JSON-schema dependencies to the canonical Java runtime action.
- Advance bootstrap, generated-output publication, PR-preview cleanup, and release-request/tag orchestration to the released `tool.git-project v0.2.4` baseline.

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
- Require successful persistent release-build publication before creating the GitHub Release.
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
