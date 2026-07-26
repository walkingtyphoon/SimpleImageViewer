# SimpleImageViewer

SimpleImageViewer is a lightweight macOS image browser built with SwiftUI. It lets you open a local folder, browse supported images in a responsive gallery, and inspect each image in a focused viewer.

## Features

- Open a local folder with the macOS file picker
- Browse image thumbnails in an adaptive grid
- View images in a full-window overlay
- Navigate with arrow keys, side buttons, swipes, or horizontal scrolling
- Zoom with buttons, pinch, or vertical scroll
- Pan zoomed images
- Rotate images in 90-degree steps
- Delete the current image from disk after confirmation
- Filter supported image formats and sort files by localized filename order

## Supported Formats

The app currently recognizes these file extensions:

- JPG / JPEG
- PNG
- GIF
- HEIC / HEIF
- TIFF / TIF
- BMP
- WebP

## Requirements

- macOS 26.4 or later, based on the current Xcode project deployment target
- Xcode with SwiftUI and Swift Testing support

## Getting Started

1. Open `SimpleImageViewer.xcodeproj` in Xcode.
2. Select the `SimpleImageViewer` scheme.
3. Build and run the app.
4. Click `Open Folder` and choose a folder that contains images.

## Testing

Run the unit and UI test targets from Xcode, or use:

```sh
xcodebuild test -project SimpleImageViewer.xcodeproj -scheme SimpleImageViewer -destination 'platform=macOS'
```

## Deployment

For local installation on this Mac, build a Release app and copy it to `/Applications`:

```sh
xcodebuild -project SimpleImageViewer.xcodeproj \
  -scheme SimpleImageViewer \
  -configuration Release \
  -destination 'platform=macOS' \
  -derivedDataPath build/DerivedData \
  build
```

The built app is created at:

```text
build/DerivedData/Build/Products/Release/SimpleImageViewer.app
```

Replace the installed app:

```sh
rm -rf /Applications/SimpleImageViewer.app
ditto build/DerivedData/Build/Products/Release/SimpleImageViewer.app \
  /Applications/SimpleImageViewer.app
```

For a local self-use build, ad-hoc sign the installed app and remove provenance metadata:

```sh
codesign --force --deep --sign - /Applications/SimpleImageViewer.app
xattr -dr com.apple.provenance /Applications/SimpleImageViewer.app
codesign --verify --deep --strict --verbose=2 /Applications/SimpleImageViewer.app
```

Launch the installed app:

```sh
open -n /Applications/SimpleImageViewer.app
```

If macOS blocks an image file opened with this app, the image may have quarantine metadata from a browser, chat app, or download. Remove it from that file or folder:

```sh
xattr -d com.apple.quarantine /path/to/image.png
xattr -dr com.apple.quarantine /path/to/image-folder
```

For distribution to other Macs, use Developer ID signing and Apple notarization instead of ad-hoc signing.

## Project Structure

```text
SimpleImageViewer/
  Models/       Image file metadata and supported format checks
  Services/     Folder loading and file deletion services
  Theme/        Shared visual styling
  ViewModels/   Gallery and viewer state
  Views/        Gallery and image viewer SwiftUI views

SimpleImageViewerTests/
  Unit tests for loaders, formats, and viewer state

SimpleImageViewerUITests/
  UI test scaffolding
```

## Repository

```sh
git@github.com:walkingtyphoon/SimpleImageViewer.git
```
