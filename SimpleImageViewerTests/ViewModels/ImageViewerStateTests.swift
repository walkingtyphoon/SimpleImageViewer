//
//  ImageViewerStateTests.swift
//  SimpleImageViewerTests
//

import CoreGraphics
import Foundation
import Testing
@testable import SimpleImageViewer

struct ImageViewerStateTests {

    // MARK: - Navigation

    @Test
    func goNextAdvancesIndexAndResetsTransform() {
        var state = makeState(count: 3, index: 0)
        state.scale = 2.5
        state.offset = CGSize(width: 40, height: 20)
        state.rotationDegrees = 90

        state.goNext()

        #expect(state.currentIndex == 1)
        #expect(state.scale == 1)
        #expect(state.offset == .zero)
        #expect(state.rotationDegrees == 0)
    }

    @Test
    func goNextDoesNothingAtLastImage() {
        var state = makeState(count: 3, index: 2)

        state.goNext()

        #expect(state.currentIndex == 2)
    }

    @Test
    func goPreviousMovesBackAndResetsTransform() {
        var state = makeState(count: 3, index: 2)
        state.scale = 3
        state.offset = CGSize(width: -10, height: 5)

        state.goPrevious()

        #expect(state.currentIndex == 1)
        #expect(state.scale == 1)
        #expect(state.offset == .zero)
    }

    @Test
    func goPreviousDoesNothingAtFirstImage() {
        var state = makeState(count: 3, index: 0)

        state.goPrevious()

        #expect(state.currentIndex == 0)
    }

    @Test
    func canGoNextAndPreviousFlags() {
        var state = makeState(count: 3, index: 0)
        #expect(state.canGoPrevious == false)
        #expect(state.canGoNext == true)

        state.currentIndex = 1
        #expect(state.canGoPrevious == true)
        #expect(state.canGoNext == true)

        state.currentIndex = 2
        #expect(state.canGoPrevious == true)
        #expect(state.canGoNext == false)
    }

    // MARK: - Delete

    @Test
    func deleteCurrentRemovesImageAndKeepsIndexWhenPossible() {
        var state = makeState(count: 3, index: 1)

        let deleted = state.deleteCurrent()

        #expect(deleted?.name == "img-1.jpg")
        #expect(state.images.map(\.name) == ["img-0.jpg", "img-2.jpg"])
        #expect(state.currentIndex == 1)
        #expect(state.currentImage?.name == "img-2.jpg")
    }

    @Test
    func deleteLastImageClampsIndexToNewLast() {
        var state = makeState(count: 3, index: 2)

        let deleted = state.deleteCurrent()

        #expect(deleted?.name == "img-2.jpg")
        #expect(state.images.count == 2)
        #expect(state.currentIndex == 1)
        #expect(state.currentImage?.name == "img-1.jpg")
    }

    @Test
    func deleteOnlyImageClearsSelection() {
        var state = makeState(count: 1, index: 0)

        let deleted = state.deleteCurrent()

        #expect(deleted?.name == "img-0.jpg")
        #expect(state.images.isEmpty)
        #expect(state.currentIndex == 0)
        #expect(state.currentImage == nil)
        #expect(state.isEmpty)
    }

    @Test
    func deleteWhenEmptyReturnsNil() {
        var state = ImageViewerState(images: [], currentIndex: 0)

        #expect(state.deleteCurrent() == nil)
        #expect(state.isEmpty)
    }

    // MARK: - Rotation

    @Test
    func rotateClockwiseStepsBy90() {
        var state = makeState(count: 1, index: 0)

        state.rotateClockwise()
        #expect(state.rotationDegrees == 90)

        state.rotateClockwise()
        #expect(state.rotationDegrees == 180)

        state.rotateClockwise()
        #expect(state.rotationDegrees == 270)

        state.rotateClockwise()
        #expect(state.rotationDegrees == 0)
    }

    @Test
    func rotateCounterClockwiseStepsByNegative90() {
        var state = makeState(count: 1, index: 0)

        state.rotateCounterClockwise()
        #expect(state.rotationDegrees == 270)

        state.rotateCounterClockwise()
        #expect(state.rotationDegrees == 180)
    }

    // MARK: - Zoom & pan

    @Test
    func zoomClampsToConfiguredRange() {
        var state = makeState(count: 1, index: 0)

        state.zoom(by: 10)
        #expect(state.scale == ImageViewerState.maxScale)

        state.scale = 1
        state.zoom(by: 0.01)
        #expect(state.scale == ImageViewerState.minScale)
    }

    @Test
    func setScaleClampsAndResetsOffsetWhenNearIdentity() {
        var state = makeState(count: 1, index: 0)
        state.offset = CGSize(width: 30, height: 10)

        state.setScale(1.0)

        #expect(state.scale == 1)
        #expect(state.offset == .zero)
    }

    @Test
    func panOnlyAppliesWhenZoomedIn() {
        var state = makeState(count: 1, index: 0)
        state.scale = 1

        state.pan(by: CGSize(width: 20, height: 10))
        #expect(state.offset == .zero)

        state.scale = 2
        state.pan(by: CGSize(width: 20, height: 10))
        #expect(state.offset == CGSize(width: 20, height: 10))

        state.pan(by: CGSize(width: -5, height: 5))
        #expect(state.offset == CGSize(width: 15, height: 15))
    }

    @Test
    func resetTransformRestoresDefaults() {
        var state = makeState(count: 1, index: 0)
        state.scale = 2.2
        state.offset = CGSize(width: 8, height: 4)
        state.rotationDegrees = 180

        state.resetTransform()

        #expect(state.scale == 1)
        #expect(state.offset == .zero)
        #expect(state.rotationDegrees == 0)
    }

    // MARK: - Swipe navigation

    @Test
    func horizontalSwipeLeftGoesNextWhenNotZoomed() {
        var state = makeState(count: 3, index: 0)

        let didNavigate = state.handleSwipeEnd(
            translation: CGSize(width: -120, height: 5),
            threshold: 80
        )

        #expect(didNavigate)
        #expect(state.currentIndex == 1)
    }

    @Test
    func horizontalSwipeRightGoesPreviousWhenNotZoomed() {
        var state = makeState(count: 3, index: 1)

        let didNavigate = state.handleSwipeEnd(
            translation: CGSize(width: 120, height: -3),
            threshold: 80
        )

        #expect(didNavigate)
        #expect(state.currentIndex == 0)
    }

    @Test
    func swipeBelowThresholdDoesNotNavigate() {
        var state = makeState(count: 3, index: 1)

        let didNavigate = state.handleSwipeEnd(
            translation: CGSize(width: -40, height: 0),
            threshold: 80
        )

        #expect(!didNavigate)
        #expect(state.currentIndex == 1)
    }

    @Test
    func swipeDoesNotNavigateWhenZoomed() {
        var state = makeState(count: 3, index: 1)
        state.scale = 2

        let didNavigate = state.handleSwipeEnd(
            translation: CGSize(width: -200, height: 0),
            threshold: 80
        )

        #expect(!didNavigate)
        #expect(state.currentIndex == 1)
    }

    // MARK: - Helpers

    private func makeState(count: Int, index: Int) -> ImageViewerState {
        let images = (0..<count).map { i in
            ImageFile(
                url: URL(fileURLWithPath: "/tmp/img-\(i).jpg"),
                name: "img-\(i).jpg"
            )
        }
        return ImageViewerState(images: images, currentIndex: index)
    }
}
