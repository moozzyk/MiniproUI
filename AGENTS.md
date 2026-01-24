# AGENTS.md

## Project overview
Visual Minipro is a macOS SwiftUI app for XGecu programmers. The Xcode project is `Visual Minipro.xcodeproj` and the main target is **Visual Minipro**.

## Key paths
- App sources: `MiniproUI/`
- App entry point: `MiniproUI/MiniproUIApp.swift`
- Minipro integration: `MiniproUI/Minipro/`
- Unit tests: `MiniproUITests/`
- UI tests: `MiniproUIUITests/`

## Build
Preferred: open `Visual Minipro.xcodeproj` in Xcode and run the **Visual Minipro** scheme.

CLI (if a shared scheme exists):
```
xcodebuild -project "Visual Minipro.xcodeproj" -scheme "Visual Minipro" -configuration Debug build
```

## Tests
```
xcodebuild -project "Visual Minipro.xcodeproj" -scheme "Visual Minipro" test
```
UI tests require a simulator.

## Notes for agents
- Keep entitlements files in sync with any new hardware or file access needs.
- Prefer minimal SwiftUI changes; avoid unrelated formatting churn.
