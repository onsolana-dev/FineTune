# Security scope of FineTune Local

Modified by onsolana-dev on 2026-11-17 from upstream commit `2285279d36d3f8115c1c2d4aecd904f1bdf96a51`.

## Reduced execution paths

This fork has no Sparkle updater, release installer, npm packaging command, remote Swift package reference, Git clean filter, or registered external URL command. App activation uses a bundle URL through NSWorkspace rather than composing executable AppleScript. The alert-volume feature still invokes a fixed system AppleScript with a bounded integer value.

The AutoEQ client reads local files only. No automatic network client remains in the reviewed application or vendored source. Source/donation buttons can open a browser when clicked. Removing the network entitlement is not a firewall: this app is not sandboxed, and the claim is about the inspected code, not an OS-enforced network prohibition.

## Dependencies

The `Vendor` directory contains unchanged package manifests and sources at these exact revisions, with licenses and per-file SHA-256 hashes:

| Library | Version | Revision |
| --- | --- | --- |
| FluidMenuBarExtra | 1.5.1 | `3ce81bd0e5ab0ae5b027076482f4bd86be30162c` |
| KeyboardShortcuts | 2.4.0 | `1aef85578fdd4f9eaeeb8d53b7b4fc31bf08fe27` |

Neither package declares external dependencies, build plugins, macros, or binary targets. `scripts/verify-vendor.py` rejects changed, missing, additional, or symbolic-link files before the local build. It detects accidental source drift; this repository's own manifest is not an independent trust anchor.

OSV exact-commit queries returned no advisory records for these revisions on 2026-11-17. That does not establish comprehensive Swift advisory coverage. Dependencies should be checked again when changed or before later builds.

## Permissions and limitations

System-audio capture is required to process movie audio. The app retains microphone/Bluetooth declarations for the original input-capable audio paths and paired-device controls. Accessibility is optional for media keys; launch-at-login is opt-in. These capabilities were not granted by the build/test process.

The existing TCC and monitor-DDC integrations use private macOS APIs, so compatibility may change with macOS releases. The app is not a sandbox. This work is a focused supply-chain and sensitive-data review, not a complete audit of every audio callback or a guarantee that it is free of vulnerabilities.

The scanner labels PNG/PDF artwork as incomplete text coverage. Those are ordinary app and documentation resources, not substituted executable dependencies. Raw reports and scoped execution decisions are maintained outside this repository. The original raw warnings are not suppressed to produce a clean-looking result.

## Revalidation

Review diffs and the exact dependency inventory, run the local security preflight, verify vendored hashes, compile, and run the standalone regression checks. A downloaded upstream DMG has different provenance and is not covered by this fork's source review. Locally compiled binaries use an ad-hoc signature, not an Apple Developer ID or notarization ticket.
