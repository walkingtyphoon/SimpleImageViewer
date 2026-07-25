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

- macOS 26.5 or later, based on the current Xcode project deployment target
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
