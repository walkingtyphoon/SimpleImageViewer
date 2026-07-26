import AppKit

/// Accumulates horizontal scroll and emits at most one navigation per gesture.
struct ScrollImageNavigator: Equatable {
    enum Direction: Equatable {
        case next
        case previous
    }

    var threshold: CGFloat

    private var accumulatedX: CGFloat = 0
    private var didNavigateThisGesture = false

    init(threshold: CGFloat = 28) {
        self.threshold = threshold
    }

    mutating func consume(
        deltaX: CGFloat,
        phase: NSEvent.Phase,
        momentumPhase: NSEvent.Phase
    ) -> Direction? {
        let isDiscrete = phase.isEmpty && momentumPhase.isEmpty

        if isDiscrete {
            guard abs(deltaX) >= max(threshold * 0.35, 4) else { return nil }
            return deltaX < 0 ? .next : .previous
        }

        if phase.contains(.began) {
            resetSession()
            accumulatedX += deltaX
            return nil
        }

        if didNavigateThisGesture {
            resetIfGestureEnded(phase: phase, momentumPhase: momentumPhase)
            return nil
        }

        accumulatedX += deltaX
        if let direction = accumulatedDirection {
            didNavigateThisGesture = true
            accumulatedX = 0
            return direction
        }

        resetIfGestureEnded(phase: phase, momentumPhase: momentumPhase)
        return nil
    }

    private var accumulatedDirection: Direction? {
        if accumulatedX <= -threshold { return .next }
        if accumulatedX >= threshold { return .previous }
        return nil
    }

    private mutating func resetIfGestureEnded(
        phase: NSEvent.Phase,
        momentumPhase: NSEvent.Phase
    ) {
        if phase.contains(.ended)
            || phase.contains(.cancelled)
            || momentumPhase.contains(.ended)
            || momentumPhase.contains(.cancelled) {
            resetSession()
        }
    }

    private mutating func resetSession() {
        accumulatedX = 0
        didNavigateThisGesture = false
    }
}
