# AshteMobile — Project Review

## What was checked
- Reviewed the uploaded Xcode project structure and the main SwiftUI navigation, appearance, source, signing, and archive-handling paths.
- Parsed all 166 Swift source files with the Swift 6.2 parser. No Swift syntax errors were reported.
- Reviewed the app's plist and build workflow configuration.
- A full iOS build was not possible in this environment because Apple's Xcode/iOS SDK and signing environment are not available here. A successful Swift parse is not the same as a successful iOS build.

## Fixes applied
### VPN/proxy policy consistency
`AshteMobile/AshteMobileApp.swift`
- Removed the hard-coded `antiVPNEnabled = true` override.
- The UI/security gate now follows the configured `anti_vpn_proxy` policy instead of blocking users when that setting is false.
- Applied the same policy during startup, path updates, protected operations, deep-link handling, and the URL loading shield.

### Debian AR archive reader
`AshteMobile/Utilities/ARDecompression/AR.swift`
- Removed `try!` from archive file loading. A missing or unreadable file now returns a normal error instead of terminating the app.
- Added checks for the archive signature, fixed-size member header, header trailer, numeric fields, member size, and padding.
- Removed force-unwrapped integer conversions and unchecked `Data` ranges.
- Parse the archive permission field as octal, as required by the ar format.
- Preserve zero-byte archive members.

`AshteMobile/Utilities/Handlers/TweakHandler.swift`
- Updated the call site to propagate the new throwing initializer with `try`.

## Design review
The app already uses native SwiftUI navigation, system materials, semantic grouped backgrounds, configurable accent color, and light/dark/system appearance. Those are good foundations for a modern iOS look. I did not replace the existing navigation or signing screens with a new visual system because doing that without an Xcode build and device testing could break core workflows.

Recommended next design pass:
1. Standardize spacing, corner radii, card surfaces, and typography across Today, Apps, Signing, and Settings.
2. Improve empty/loading/error states so they share one visual language.
3. Review iPad/sidebar behavior and Dynamic Type, VoiceOver, and right-to-left layouts.
4. Reduce the size and responsibility of `SourcesView.swift` by extracting its metadata, caching, and view sections into smaller units.

## Items requiring owner review
- `Makefile` downloads a TLS certificate/private-key package and copies the resulting files into the built app bundle. Confirm that this private key is intended to be distributed to every app installation. A shared server private key embedded in a public IPA can be extracted; if it is a server identity, move TLS termination to the server or provision per-installation credentials.
- `NetworkShield` detects configured system proxy settings and selected tunnel interfaces, but iOS does not provide a reliable general-purpose way for an app to prove that no VPN, packet tunnel, or traffic inspection is active. Treat this as a heuristic, not a security guarantee.
- The build workflow targets Xcode 26.2 when that runner image exists and otherwise falls back to the runner's selected Xcode. Confirm the selected Xcode version and package resolution in CI before publishing.
- Review the large `SourcesView.swift` file for maintainability and regression risk before making broad UI changes.

## Validation
- Swift syntax parse: 166/166 files passed.
- Targeted syntax parse after the archive-reader and VPN-policy changes: passed.
- Full iOS compile, simulator run, device run, signing, and network integration tests: not run (Xcode/iOS SDK unavailable).
