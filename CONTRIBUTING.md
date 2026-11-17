# Working on FineTune Local

This is a modified personal fork, not the upstream distribution. Changes should retain the original GPLv3 notices and the MIT notices of the two vendored libraries.

Build using `bash scripts/build-local.sh`. Run the isolated profile regression checks with `bash scripts/test-local-profiles.sh`. The Xcode project refers only to packages in `Vendor/`; do not replace these with floating remote requirements.

Before changing a dependency, inspect the exact new source and all build entrypoints without executing it. Record its upstream revision and file hashes in `Vendor/provenance.json` only after review. A manifest is executable Swift, so inspect it before letting SwiftPM evaluate it. Keep review evidence outside the untrusted source checkout.

Audio callback code must avoid allocations, locks, Objective-C messaging, file I/O, and logging. Hardware-dependent behavior needs a separate playback test; compilation alone is not evidence that audio routing works on every output device.
