//
//  ScrollImageNavigatorTests.swift
//  SimpleImageViewerTests
//

import AppKit
import Testing
@testable import SimpleImageViewer

struct ScrollImageNavigatorTests {

    @Test
    func continuousSwipeEmitsOnlyOneNavigation() {
        var navigator = ScrollImageNavigator(threshold: 28)
        let empty = NSEvent.Phase()

        // Gesture begins
        #expect(
            navigator.consume(deltaX: 0, phase: .began, momentumPhase: empty) == nil
        )

        // Small moves accumulate, no switch yet
        #expect(
            navigator.consume(deltaX: -10, phase: .changed, momentumPhase: empty) == nil
        )
        #expect(
            navigator.consume(deltaX: -10, phase: .changed, momentumPhase: empty) == nil
        )

        // Cross threshold → next once
        #expect(
            navigator.consume(deltaX: -12, phase: .changed, momentumPhase: empty) == .next
        )

        // Further motion / momentum must not switch again
        #expect(
            navigator.consume(deltaX: -80, phase: .changed, momentumPhase: empty) == nil
        )
        #expect(
            navigator.consume(deltaX: -40, phase: empty, momentumPhase: .changed) == nil
        )

        // End of gesture resets for the next swipe
        #expect(
            navigator.consume(deltaX: 0, phase: empty, momentumPhase: .ended) == nil
        )

        #expect(
            navigator.consume(deltaX: 30, phase: .began, momentumPhase: empty) == nil
        )
        #expect(
            navigator.consume(deltaX: 5, phase: .changed, momentumPhase: empty) == .previous
        )
    }

    @Test
    func discreteMouseWheelNotchSwitchesOncePerEvent() {
        var navigator = ScrollImageNavigator(threshold: 28)
        let empty = NSEvent.Phase()

        #expect(
            navigator.consume(deltaX: -10, phase: empty, momentumPhase: empty) == .next
        )
        #expect(
            navigator.consume(deltaX: 10, phase: empty, momentumPhase: empty) == .previous
        )
        #expect(
            navigator.consume(deltaX: -1, phase: empty, momentumPhase: empty) == nil
        )
    }
}
