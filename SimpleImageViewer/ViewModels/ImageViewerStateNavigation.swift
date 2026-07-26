import CoreGraphics

extension ImageViewerState {
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
}
