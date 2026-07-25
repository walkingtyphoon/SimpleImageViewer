//
//  ImageViewerState.swift
//  SimpleImageViewer
//

import CoreGraphics
import Foundation

/// Pure, testable state for the full-screen image viewer.
struct ImageViewerState: Equatable {
    static let minScale: CGFloat = 1
    static let maxScale: CGFloat = 8
    static let defaultSwipeThreshold: CGFloat = 80

    var images: [ImageFile]
    var currentIndex: Int
    var scale: CGFloat = 1
    var offset: CGSize = .zero
    var rotationDegrees: Double = 0

    var isEmpty: Bool { images.isEmpty }

    var currentImage: ImageFile? {
        guard images.indices.contains(currentIndex) else { return nil }
        return images[currentIndex]
    }

    var canGoNext: Bool {
        !images.isEmpty && currentIndex < images.count - 1
    }

    var canGoPrevious: Bool {
        !images.isEmpty && currentIndex > 0
    }

    var isZoomed: Bool {
        scale > 1.01
    }

    // MARK: - Navigation

    mutating func goNext() {
        guard canGoNext else { return }
        currentIndex += 1
        resetTransform()
    }

    mutating func goPrevious() {
        guard canGoPrevious else { return }
        currentIndex -= 1
        resetTransform()
    }

    // MARK: - Delete

    @discardableResult
    mutating func deleteCurrent() -> ImageFile? {
        guard images.indices.contains(currentIndex) else { return nil }
        let removed = images.remove(at: currentIndex)
        if images.isEmpty {
            currentIndex = 0
        } else {
            currentIndex = min(currentIndex, images.count - 1)
        }
        resetTransform()
        return removed
    }

    // MARK: - Transform

    mutating func rotateClockwise() {
        rotationDegrees = normalizedRotation(rotationDegrees + 90)
    }

    mutating func rotateCounterClockwise() {
        rotationDegrees = normalizedRotation(rotationDegrees - 90)
    }

    mutating func zoom(by factor: CGFloat) {
        setScale(scale * factor)
    }

    mutating func setScale(_ newScale: CGFloat) {
        let clamped = min(max(newScale, Self.minScale), Self.maxScale)
        scale = clamped
        if scale <= 1.01 {
            scale = 1
            offset = .zero
        }
    }

    mutating func pan(by delta: CGSize) {
        guard isZoomed else { return }
        offset = CGSize(
            width: offset.width + delta.width,
            height: offset.height + delta.height
        )
    }

    mutating func resetTransform() {
        scale = 1
        offset = .zero
        rotationDegrees = 0
    }

    /// Handles end of a horizontal swipe. Returns whether navigation occurred.
    @discardableResult
    mutating func handleSwipeEnd(
        translation: CGSize,
        threshold: CGFloat = ImageViewerState.defaultSwipeThreshold
    ) -> Bool {
        guard !isZoomed else { return false }

        if translation.width <= -threshold, canGoNext {
            goNext()
            return true
        }
        if translation.width >= threshold, canGoPrevious {
            goPrevious()
            return true
        }
        return false
    }

    // MARK: - Private

    private func normalizedRotation(_ degrees: Double) -> Double {
        var value = degrees.truncatingRemainder(dividingBy: 360)
        if value < 0 { value += 360 }
        return value
    }
}
