//
//  GalleryViewModel.swift
//  SimpleImageViewer
//

import Foundation
import Observation

@MainActor
@Observable
final class GalleryViewModel {
    private(set) var images: [ImageFile] = []
    private(set) var directoryURL: URL?
    private(set) var errorMessage: String?
    private(set) var isViewerPresented = false

    var viewerState = ImageViewerState(images: [], currentIndex: 0)

    var isEmpty: Bool { images.isEmpty }

    private let loader: any ImageLoading
    private let deleter: any ImageDeleting

    init(
        loader: any ImageLoading = ImageDirectoryLoader(),
        deleter: any ImageDeleting = FileImageDeleter()
    ) {
        self.loader = loader
        self.deleter = deleter
    }

    func setErrorMessage(_ message: String?) {
        errorMessage = message
    }

    func loadDirectory(_ url: URL) {
        do {
            let loaded = try loader.loadImages(from: url)
            images = loaded
            directoryURL = url
            errorMessage = nil

            if isViewerPresented {
                syncViewerWithGallery()
                if images.isEmpty {
                    isViewerPresented = false
                }
            }
        } catch {
            images = []
            directoryURL = url
            errorMessage = error.localizedDescription
            isViewerPresented = false
            viewerState = ImageViewerState(images: [], currentIndex: 0)
        }
    }

    func openViewer(for image: ImageFile) {
        guard let index = images.firstIndex(of: image) else { return }
        viewerState = ImageViewerState(images: images, currentIndex: index)
        isViewerPresented = true
    }

    func closeViewer() {
        isViewerPresented = false
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

    func handleSwipeEnd(translation: CGSize, threshold: CGFloat = ImageViewerState.defaultSwipeThreshold) {
        viewerState.handleSwipeEnd(translation: translation, threshold: threshold)
    }

    @discardableResult
    func deleteCurrentImage() -> Bool {
        guard let image = viewerState.currentImage else { return false }

        do {
            try deleter.delete(image)
        } catch {
            errorMessage = error.localizedDescription
            return false
        }

        viewerState.deleteCurrent()
        images = viewerState.images

        if images.isEmpty {
            isViewerPresented = false
        }
        return true
    }

    // MARK: - Private

    private func syncViewerWithGallery() {
        let previousID = viewerState.currentImage?.id
        var index = 0
        if let previousID, let match = images.firstIndex(where: { $0.id == previousID }) {
            index = match
        } else {
            index = min(viewerState.currentIndex, max(images.count - 1, 0))
        }
        viewerState = ImageViewerState(images: images, currentIndex: images.isEmpty ? 0 : index)
    }
}
