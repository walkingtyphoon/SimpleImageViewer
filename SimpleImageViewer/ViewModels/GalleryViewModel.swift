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
        loader: any ImageLoading,
        deleter: any ImageDeleting
    ) {
        self.loader = loader
        self.deleter = deleter
    }

    func setErrorMessage(_ message: String?) {
        errorMessage = message
    }

    func presentViewer(at index: Int) {
        viewerState = ImageViewerState(images: images, currentIndex: index)
        isViewerPresented = true
    }

    func dismissViewer() {
        isViewerPresented = false
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

    private func syncViewerWithGallery() {
        let previousID = viewerState.currentImage?.id
        var index = 0
        if let previousID,
           let match = images.firstIndex(where: { $0.id == previousID }) {
            index = match
        } else {
            index = min(viewerState.currentIndex, max(images.count - 1, 0))
        }
        let currentIndex = images.isEmpty ? 0 : index
        viewerState = ImageViewerState(images: images, currentIndex: currentIndex)
    }
}
