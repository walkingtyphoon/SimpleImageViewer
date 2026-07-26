import CoreGraphics

extension ImageViewerState {
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

    private func normalizedRotation(_ degrees: Double) -> Double {
        var value = degrees.truncatingRemainder(dividingBy: 360)
        if value < 0 { value += 360 }
        return value
    }
}
