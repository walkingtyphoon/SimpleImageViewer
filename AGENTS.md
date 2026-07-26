# SimpleImageViewer Agent Instructions

Follow the shared rules in `/Users/typhoonwalking/CLionProjects/TyphoonAiRules`.

Before making changes, read these shared rule files in order:

- `/Users/typhoonwalking/CLionProjects/TyphoonAiRules/AGENTS.md`
- `/Users/typhoonwalking/CLionProjects/TyphoonAiRules/GlobalRules.md`
- `/Users/typhoonwalking/CLionProjects/TyphoonAiRules/CommandRules.md`
- `/Users/typhoonwalking/CLionProjects/TyphoonAiRules/CodingRules.md`
- `/Users/typhoonwalking/CLionProjects/TyphoonAiRules/GitRules.md`
- `/Users/typhoonwalking/CLionProjects/TyphoonAiRules/OutputRules.md`

## Project Context

SimpleImageViewer is a macOS SwiftUI image viewer built with Xcode. It supports opening image folders and opening individual image files from Finder, then browsing sibling images with viewer navigation.

## Local Project Rules

- Keep changes scoped to the macOS SwiftUI app and its tests.
- Prefer existing project structure: `Models`, `Services`, `ViewModels`, `Views`, and `Theme`.
- Use `xcodebuild` for build and test verification.
- Do not change bundle identifiers, signing settings, deployment targets, or document type registration unless the task requires it.
- If Finder file-opening behavior changes, verify both `AppInfo.plist` document type registration and `GalleryViewModel.openImageFile`.

## Verification

For normal changes, run:

```sh
xcodebuild test -project SimpleImageViewer.xcodeproj -scheme SimpleImageViewer -destination 'platform=macOS'
```
