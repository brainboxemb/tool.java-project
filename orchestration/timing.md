# Java workflow timing

- Workflow run: `36035573121`
- Capture point: `before-generated-output-push`
- Wall clock to capture: `127 s`
- Hosted runner time to capture: `134 s`
- Started runners: `8`
- Maven reported total time: `12.695 s`

## Jobs

| Job | Runner | Result | Duration |
| --- | --- | --- | ---: |
| bootstrap-linux | ubuntu-24.04 | success | 6 s |
| release-metadata | ubuntu-24.04 | success | 7 s |
| bootstrap-windows | windows-2025 | success | 14 s |
| fixture / Linux canonical build | ubuntu-24.04 | success | 34 s |
| fixture / windows / Windows canonical-artifact smoke | windows-2025 | success | 9 s |
| fixture / windows / Windows compatibility build | windows-2025 | success | 39 s |
| verify-test-summary | ubuntu-24.04 | success | 20 s |
| publish-fixture / Publish generated output | ubuntu-24.04 | running | 5 s |

## Steps

### bootstrap-linux

| Step | Result | Duration |
| --- | --- | ---: |
| Set up job | success | 1 s |
| Checkout without submodules | success | 1 s |
| Bootstrap pinned Git tooling | success | 0 s |
| Post Checkout without submodules | success | 1 s |
| Complete job | success | 0 s |

### release-metadata

| Step | Result | Duration |
| --- | --- | ---: |
| Set up job | success | 1 s |
| Checkout source | success | 1 s |
| Validate tool version and release tag semantics | success | 0 s |
| Validate generic Git lifecycle release pin | success | 0 s |
| Post Checkout source | success | 0 s |
| Complete job | success | 0 s |

### bootstrap-windows

| Step | Result | Duration |
| --- | --- | ---: |
| Set up job | success | 1 s |
| Checkout without submodules | success | 5 s |
| Bootstrap pinned Git tooling | success | 3 s |
| Post Checkout without submodules | success | 3 s |
| Complete job | success | 0 s |

### fixture / Linux canonical build

| Step | Result | Duration |
| --- | --- | ---: |
| Set up job | success | 2 s |
| Validate execution inputs | success | 0 s |
| Checkout exact consumer source | success | 1 s |
| Set up exact Java 8 baseline | success | 0 s |
| Checkout exact tool.java-project implementation | success | 1 s |
| Run canonical Java action | success | 21 s |
| Upload canonical Java artifact | success | 1 s |
| Upload prepared build publication | success | 1 s |
| Upload Linux evidence | success | 1 s |
| Post Checkout exact tool.java-project implementation | success | 0 s |
| Post Set up exact Java 8 baseline | success | 3 s |
| Post Checkout exact consumer source | success | 0 s |
| Complete job | success | 0 s |

### fixture / windows / Windows canonical-artifact smoke

| Step | Result | Duration |
| --- | --- | ---: |
| Set up job | success | 2 s |
| Set up exact Java 8 baseline | success | 1 s |
| Download canonical Linux artifact | success | 1 s |
| Run canonical artifact on Windows | success | 2 s |
| Post Set up exact Java 8 baseline | success | 1 s |
| Complete job | success | 0 s |

### fixture / windows / Windows compatibility build

| Step | Result | Duration |
| --- | --- | ---: |
| Set up job | success | 1 s |
| Validate exact source when supplied | success | 0 s |
| Checkout exact consumer source | success | 8 s |
| Set up exact Java 8 baseline | success | 0 s |
| Validate Maven Wrapper baseline | success | 9 s |
| Verify | success | 13 s |
| Upload Windows test evidence | success | 1 s |
| Post Set up exact Java 8 baseline | success | 3 s |
| Post Checkout exact consumer source | success | 2 s |
| Complete job | success | 0 s |

### verify-test-summary

| Step | Result | Duration |
| --- | --- | ---: |
| Set up job | success | 1 s |
| Checkout source and released generic schema owner | success | 1 s |
| Bootstrap pinned Git tooling | success | 3 s |
| Install schema-validation test dependency | success | 11 s |
| Download prepared publication | success | 1 s |
| Verify readable Surefire summary and common execution evidence | success | 0 s |
| Post Checkout source and released generic schema owner | success | 0 s |
| Complete job | success | 0 s |

### publish-fixture / Publish generated output

| Step | Result | Duration |
| --- | --- | ---: |
| Set up job | success | 1 s |
| Checkout exact Java publication finalizer | success | 2 s |
| Checkout exact generic publisher implementation | success | 1 s |
| Download prepared output | running | 1 s |
