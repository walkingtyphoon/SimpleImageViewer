import AppKit

final class PointerNSView: NSView {
    var onEvent: ((PointerEventCatcher.Event) -> Void)?
    private var monitor: Any?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard monitor == nil else { return }
        monitor = NSEvent.addLocalMonitorForEvents(
            matching: [.scrollWheel, .magnify]
        ) { [weak self] event in
            self?.handle(event)
            return event
        }
    }

    func teardown() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }

    deinit {
        teardown()
    }

    private func handle(_ event: NSEvent) {
        switch event.type {
        case .scrollWheel:
            onEvent?(
                .scroll(
                    deltaX: event.scrollingDeltaX,
                    deltaY: event.scrollingDeltaY,
                    isCommand: event.modifierFlags.contains(.command),
                    phase: event.phase,
                    momentumPhase: event.momentumPhase
                )
            )
        case .magnify:
            onEvent?(.magnify(event.magnification))
        default:
            break
        }
    }
}
