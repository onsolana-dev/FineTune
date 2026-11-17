# FineTune Local

A personal fork of [Ronit Singh's FineTune](https://github.com/ronitsingh10/FineTune), modified by onsolana-dev on 2026-11-17. It keeps per-app volume boosting, audio routing, EQ, and menu-bar controls while removing automatic downloads and updates.

This fork is **GPLv3**, with the original copyright retained. It is not an official upstream release. Upstream Homebrew packages and DMGs do not contain these changes.

## Changes

- Removed Sparkle, the update UI, appcast, and release automation.
- Bundled the two remaining dependencies as exact, hash-checked source. Builds do not fetch packages. Removed the unused snapshot-testing dependency tree.
- Replaced interpolated AppleScript app activation with AppKit's application-opening API.
- Removed `finetune://` commands that could change audio settings from external links.
- Made AutoEQ local-only: import a ParametricEQ.txt file or use a previously cached profile. No catalog or profile downloads.
- Added validation and size limits to local profile reads.
- Removed the npm-based DMG builder and optional Git filter setup.
- Assigned the fork its own bundle identifier, `dev.onsolana.FineTuneLocal`.

## Build

Requires full Xcode 26.1.1 or newer, macOS 15.4 or newer, and an existing Python 3 installation for the source hash check. The verified local build uses Xcode 27.2. No package installation is needed.

```bash
bash scripts/build-local.sh
```

The app is written to `.build-local/Build/Products/Release/FineTune.app`. The script uses an ad-hoc signature for local use; it does not sign with a developer account, notarize, install, launch, or publish the app. `DEVELOPER_DIR` may point to a different installed Xcode.

```bash
bash scripts/test-local-profiles.sh
```

These standalone regression checks do not launch the audio app or request recording permissions. They exercise valid local profiles, missing caches, traversal identifiers, symlinks, and file-size limits.

## Use

After launching your locally built app, grant system-audio access in macOS when prompted. Play a movie, open FineTune's menu-bar popup, and adjust that player's volume/boost. Media-key control optionally needs Accessibility permission. Launch-at-login remains off by default. Headphone profiles are imported from files through the EQ controls.

No automatic updates are supplied. Future code changes need a new review and local build. Existing upstream screenshots and guides describe the original product and may mention removed features; this README describes the fork.

## Security and provenance

See [SECURITY.md](SECURITY.md), [Vendor/provenance.json](Vendor/provenance.json), and [LICENSE](LICENSE). Each vendored package retains its MIT license. Source review is bounded; passing a scan is not a guarantee of safety or runtime correctness.
