import AppKit
import SwiftUI

struct PointerEventCatcher: NSViewRepresentable {
    enum Event {
        case scroll(
            deltaX: CGFloat,
            deltaY: CGFloat,
            isCommand: Bool,
            phase: NSEvent.Phase,
            momentumPhase: NSEvent.Phase
        )
        case magnify(CGFloat)
    }

    let onEvent: (Event) -> Void

    func makeNSView(context: Context) -> PointerNSView {
        let view = PointerNSView()
        view.onEvent = onEvent
        return view
    }

    func updateNSView(_ nsView: PointerNSView, context: Context) {
        nsView.onEvent = onEvent
    }

    static func dismantleNSView(_ nsView: PointerNSView, coordinator: ()) {
        nsView.teardown()
    }
}
