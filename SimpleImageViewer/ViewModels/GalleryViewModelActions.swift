//
//  GalleryViewModelActions.swift
//  SimpleImageViewer
//

import CoreGraphics
import Foundation

extension GalleryViewModel {
    func openViewer(for image: ImageFile) {
        guard let index = images.firstIndex(of: image) else { return }
        presentViewer(at: index)
    }

    func openImageFile(_ url: URL) {
        guard SupportedImageFormats.isImage(url: url) else {
            setErrorMessage("Unsupported image file: \(url.lastPathComponent)")
            return
        }

        let directory = url.deletingLastPathComponent()
        loadDirectory(directory)

        guard errorMessage == nil else { return }
        guard let image = images.first(
            where: { $0.url.standardizedFileURL == url.standardizedFileURL }
        ) else {
            setErrorMessage("Image not found in folder: \(url.lastPathComponent)")
            return
        }

        openViewer(for: image)
    }

    func closeViewer() {
        dismissViewer()
    }

    func goToNextImage() {
        viewerState.goNext()
    }

    func goToPreviousImage() {
        viewerState.goPrevious()
    }

    func rotateClockwise() {
        viewerState.rotateClockwise()
    }

    func rotateCounterClockwise() {
        viewerState.rotateCounterClockwise()
    }

    func handleSwipeEnd(translation: CGSize) {
        viewerState.handleSwipeEnd(
            translation: translation,
            threshold: ImageViewerState.defaultSwipeThreshold
        )
    }

    func handleSwipeEnd(translation: CGSize, threshold: CGFloat) {
        viewerState.handleSwipeEnd(translation: translation, threshold: threshold)
    }
}
