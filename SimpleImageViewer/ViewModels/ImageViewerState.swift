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

}
