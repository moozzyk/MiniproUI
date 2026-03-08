# CLAUDE.md

## Project overview
Visual Minipro is a macOS SwiftUI app for XGecu programmers. The Xcode project is `Visual Minipro.xcodeproj` and the main target is **Visual Minipro**.

## Key paths
- App sources: `MiniproUI/`
- App entry point: `MiniproUI/MiniproUIApp.swift`
- Minipro integration: `MiniproUI/Minipro/`
- Unit tests: `MiniproUITests/`
- UI tests: `MiniproUIUITests/`

## Build
```
xcodebuild -project "Visual Minipro.xcodeproj" -scheme "Visual Minipro" -configuration Debug build
```

## Tests
```
xcodebuild -project "Visual Minipro.xcodeproj" -scheme "Visual Minipro" test
```
UI tests require a simulator. Unit tests do not.

## Architecture
The app is layered:

```
SwiftUI Views → MiniproAPI → MiniproInvoker → minipro CLI binary
```

- **`minipro`** is a bundled CLI binary (not a system tool). `MiniproInvoker` locates it via `Bundle.main.path(forAuxiliaryExecutable:)` and runs it via `ProcessInvoker`.
- **`MiniproInvoker.invoke(...)`** returns an `InvocationResult` (`exitCode`, `stdOut: Data`, `stdErr: String`).
- **`MiniproAPI`** is the public interface for all programmer operations. Each method invokes `MiniproInvoker` and delegates parsing to a `ResponseProcessor`.
- **ResponseProcessors** (`MiniproUI/Minipro/ResponseProcessors/`) parse `InvocationResult` and throw typed `MiniproAPIError` values. `ensureNoError(_:)` in `ReponseProcessorUtils.swift` handles common error patterns (programmer not found, device not found, IO error, invalid chip ID, etc.) and should be called first in every processor.

## Adding a new programmer operation
1. Add a `static func` to `MiniproAPI.swift`.
2. Create `XxxProcessor.swift` in `MiniproUI/Minipro/ResponseProcessors/`. Call `ensureNoError` first, then parse the result.
3. Add corresponding `MiniproAPIError` cases if needed.
4. Add a SwiftUI view in `MiniproUI/` if the operation needs UI.
5. Add unit tests in `MiniproUITests/` mirroring the source path.

## Tests
Tests use **Swift Testing** (not XCTest): `@Test` functions and `#expect` / `#require` macros.
The test module import is `@testable import Visual_Minipro` (underscore, not space).
Test files mirror the source tree structure under `MiniproUITests/`.

## Code style
- Format with Xcode's built-in formatter (Ctrl+Shift+I). Do not use external formatters.
- Prefer minimal SwiftUI changes; avoid unrelated formatting churn.
- Keep entitlements files in sync with any new hardware or file access needs.
