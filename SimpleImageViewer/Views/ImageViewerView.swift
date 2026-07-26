import SwiftUI

struct ImageViewerView: View {
    @Bindable var viewModel: GalleryViewModel
    @State private var showDeleteConfirm = false
    @State private var scrollNavigator = ScrollImageNavigator()

    var body: some View {
        ZStack {
            Color.black.opacity(0.92)
                .ignoresSafeArea()

            AppTheme.backgroundGradient
                .opacity(0.55)
                .ignoresSafeArea()

            if let image = viewModel.viewerState.currentImage {
                ImageViewerCanvas(
                    image: image,
                    viewerState: $viewModel.viewerState,
                    scrollNavigator: $scrollNavigator,
                    onSwipeEnd: viewModel.handleSwipeEnd,
                    onNext: viewModel.goToNextImage,
                    onPrevious: viewModel.goToPreviousImage
                )
            } else {
                ImageViewerEmptyState()
            }

            ImageViewerSideNavigation(
                canGoPrevious: viewModel.viewerState.canGoPrevious,
                canGoNext: viewModel.viewerState.canGoNext,
                onPrevious: viewModel.goToPreviousImage,
                onNext: viewModel.goToNextImage
            )

            ImageViewerChrome(
                image: viewModel.viewerState.currentImage,
                counterText: counterText,
                zoomLabel: zoomLabel,
                onClose: viewModel.closeViewer,
                onRotateLeft: viewModel.rotateCounterClockwise,
                onRotateRight: viewModel.rotateClockwise,
                onDelete: { showDeleteConfirm = true },
                onZoomOut: {
                    viewModel.viewerState.setScale(viewModel.viewerState.scale - 0.25)
                },
                onZoomIn: {
                    viewModel.viewerState.setScale(viewModel.viewerState.scale + 0.25)
                },
                onResetZoom: {
                    viewModel.viewerState.resetTransform()
                }
            )
        }
        .focusable()
        .onKeyPress(.leftArrow) {
            viewModel.goToPreviousImage()
            return .handled
        }
        .onKeyPress(.rightArrow) {
            viewModel.goToNextImage()
            return .handled
        }
        .onKeyPress(.escape) {
            viewModel.closeViewer()
            return .handled
        }
        .confirmationDialog(
            "Delete this image?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                viewModel.deleteCurrentImage()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            if let name = viewModel.viewerState.currentImage?.name {
                Text("“\(name)” will be permanently removed from disk.")
            }
        }
    }

    private var counterText: String {
        let total = viewModel.viewerState.images.count
        guard total > 0 else { return "0 / 0" }
        return "\(viewModel.viewerState.currentIndex + 1) / \(total)"
    }

    private var zoomLabel: String {
        let percent = Int((viewModel.viewerState.scale * 100).rounded())
        return "\(percent)%"
    }
}
