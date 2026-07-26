import SwiftUI

extension ImageViewerCanvas {
    var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                if !isMagnifying {
                    magnifyBaseScale = viewerState.scale
                    isMagnifying = true
                }
                viewerState.setScale(magnifyBaseScale * value)
            }
            .onEnded { _ in
                isMagnifying = false
                magnifyBaseScale = viewerState.scale
            }
    }

    func handlePointerEvent(_ event: PointerEventCatcher.Event) {
        switch event {
        case .scroll(let deltaX, let deltaY, let isCommand, let phase, let momentumPhase):
            handleScroll(deltaX, deltaY, isCommand, phase, momentumPhase)
        case .magnify(let magnification):
            viewerState.zoom(by: 1 + magnification)
        }
    }

    private func handleScroll(
        _ deltaX: CGFloat,
        _ deltaY: CGFloat,
        _ isCommand: Bool,
        _ phase: NSEvent.Phase,
        _ momentumPhase: NSEvent.Phase
    ) {
        if isCommand || abs(deltaY) > abs(deltaX) * 1.2 {
            let factor = 1 + (deltaY * 0.008)
            viewerState.zoom(by: max(0.5, min(1.5, factor)))
            return
        }

        if viewerState.isZoomed {
            viewerState.pan(by: CGSize(width: deltaX, height: deltaY))
            return
        }

        guard let direction = scrollNavigator.consume(
            deltaX: deltaX,
            phase: phase,
            momentumPhase: momentumPhase
        ) else { return }

        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
            direction == .next ? onNext() : onPrevious()
        }
    }
}
