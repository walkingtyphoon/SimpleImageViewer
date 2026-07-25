//
//  ImageViewerView.swift
//  SimpleImageViewer
//

import AppKit
import SwiftUI

struct ImageViewerView: View {
    @Bindable var viewModel: GalleryViewModel
    @State private var showDeleteConfirm = false
    @State private var dragTranslation: CGSize = .zero
    @State private var magnifyBaseScale: CGFloat = 1
    @State private var isMagnifying = false
    @State private var scrollNavigator = ScrollImageNavigator()

    var body: some View {
        ZStack {
            Color.black.opacity(0.92)
                .ignoresSafeArea()

            AppTheme.backgroundGradient
                .opacity(0.55)
                .ignoresSafeArea()

            if let image = viewModel.viewerState.currentImage {
                zoomableImage(for: image)
            } else {
                ContentUnavailableView(
                    "No Image",
                    systemImage: "photo",
                    description: Text("There's nothing left to show.")
                )
                .foregroundStyle(.white)
            }

            // Side navigation — vertically centered
            HStack {
                sideNavButton(
                    systemName: "chevron.left",
                    enabled: viewModel.viewerState.canGoPrevious,
                    help: "Previous (←)"
                ) {
                    viewModel.goToPreviousImage()
                }

                Spacer()

                sideNavButton(
                    systemName: "chevron.right",
                    enabled: viewModel.viewerState.canGoNext,
                    help: "Next (→)"
                ) {
                    viewModel.goToNextImage()
                }
            }
            .padding(.horizontal, 20)

            // Top / bottom chrome
            VStack {
                topBar
                Spacer()
                bottomChrome
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .focusable()
        .onKeyPress(.leftArrow) {
            viewModel.goToPreviousImage()
            return .handled
        }
        .onKeyPress(.rightArrow) {
            viewModel.goToNextImage()
            return .handled
        }
        .onKeyPress(.escape) {
            viewModel.closeViewer()
            return .handled
        }
        .confirmationDialog(
            "Delete this image?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                viewModel.deleteCurrentImage()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            if let name = viewModel.viewerState.currentImage?.name {
                Text("“\(name)” will be permanently removed from disk.")
            }
        }
    }

    // MARK: - Chrome

    private var topBar: some View {
        HStack(spacing: 10) {
            Button {
                viewModel.closeViewer()
            } label: {
                Image(systemName: "xmark")
            }
            .buttonStyle(GlassCircleButtonStyle())
            .help("Close (Esc)")

            Spacer()

            if let image = viewModel.viewerState.currentImage {
                VStack(spacing: 2) {
                    Text(image.name)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(counterText)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppTheme.secondaryLabel)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay {
                            Capsule().strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                        }
                }
            }

            Spacer()

            HStack(spacing: 8) {
                Button {
                    viewModel.rotateCounterClockwise()
                } label: {
                    Image(systemName: "rotate.left")
                }
                .buttonStyle(GlassCircleButtonStyle())
                .help("Rotate left")

                Button {
                    viewModel.rotateClockwise()
                } label: {
                    Image(systemName: "rotate.right")
                }
                .buttonStyle(GlassCircleButtonStyle())
                .help("Rotate right")

                Button {
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(GlassCircleButtonStyle(destructive: true))
                .help("Delete")
            }
        }
    }

    private var bottomChrome: some View {
        HStack(spacing: 8) {
            Button {
                viewModel.viewerState.setScale(viewModel.viewerState.scale - 0.25)
            } label: {
                Image(systemName: "minus.magnifyingglass")
            }
            .buttonStyle(GlassCircleButtonStyle())

            Text(zoomLabel)
                .font(.system(size: 12, weight: .semibold, design: .rounded).monospacedDigit())
                .foregroundStyle(.white)
                .frame(minWidth: 48)

            Button {
                viewModel.viewerState.setScale(viewModel.viewerState.scale + 0.25)
            } label: {
                Image(systemName: "plus.magnifyingglass")
            }
            .buttonStyle(GlassCircleButtonStyle())

            Button {
                viewModel.viewerState.resetTransform()
            } label: {
                Image(systemName: "arrow.counterclockwise")
            }
            .buttonStyle(GlassCircleButtonStyle())
            .help("Reset zoom")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay {
                    Capsule().strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
                }
        }
    }

    private func sideNavButton(
        systemName: String,
        enabled: Bool,
        help: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
        }
        .buttonStyle(GlassCircleButtonStyle())
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.35)
        .help(help)
    }

    // MARK: - Image canvas

    private func zoomableImage(for image: ImageFile) -> some View {
        GeometryReader { geo in
            ZStack {
                AsyncLocalImage(url: image.url)
                    .rotationEffect(.degrees(viewModel.viewerState.rotationDegrees))
                    .scaleEffect(viewModel.viewerState.scale)
                    .offset(
                        x: viewModel.viewerState.offset.width
                            + (viewModel.viewerState.isZoomed ? 0 : dragTranslation.width * 0.35),
                        y: viewModel.viewerState.offset.height
                    )
                    .frame(width: geo.size.width, height: geo.size.height)
                    .contentShape(Rectangle())
                    .gesture(dragGesture)
                    .simultaneousGesture(magnificationGesture)
                    .onTapGesture(count: 2) {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                            if viewModel.viewerState.isZoomed {
                                viewModel.viewerState.resetTransform()
                            } else {
                                viewModel.viewerState.setScale(2.5)
                            }
                        }
                    }
            }
        }
        .padding(.top, 56)
        .padding(.bottom, 72)
        .id(image.id)
        .animation(.easeOut(duration: 0.18), value: viewModel.viewerState.currentIndex)
        .background {
            PointerEventCatcher { event in
                handlePointerEvent(event)
            }
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if viewModel.viewerState.isZoomed {
                    let delta = CGSize(
                        width: value.translation.width - dragTranslation.width,
                        height: value.translation.height - dragTranslation.height
                    )
                    viewModel.viewerState.pan(by: delta)
                    dragTranslation = value.translation
                } else {
                    dragTranslation = value.translation
                }
            }
            .onEnded { value in
                if !viewModel.viewerState.isZoomed {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                        viewModel.handleSwipeEnd(translation: value.translation)
                    }
                }
                dragTranslation = .zero
            }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                if !isMagnifying {
                    magnifyBaseScale = viewModel.viewerState.scale
                    isMagnifying = true
                }
                viewModel.viewerState.setScale(magnifyBaseScale * value)
            }
            .onEnded { _ in
                isMagnifying = false
                magnifyBaseScale = viewModel.viewerState.scale
            }
    }

    private func handlePointerEvent(_ event: PointerEventCatcher.Event) {
        switch event {
        case .scroll(let deltaX, let deltaY, let isCommand, let phase, let momentumPhase):
            if isCommand || abs(deltaY) > abs(deltaX) * 1.2 {
                let factor = 1 + (deltaY * 0.008)
                viewModel.viewerState.zoom(by: max(0.5, min(1.5, factor)))
                return
            }

            if viewModel.viewerState.isZoomed {
                viewModel.viewerState.pan(by: CGSize(width: deltaX, height: deltaY))
                return
            }

            // One physical swipe / notch → exactly one image.
            if let direction = scrollNavigator.consume(
                deltaX: deltaX,
                phase: phase,
                momentumPhase: momentumPhase
            ) {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                    switch direction {
                    case .next:
                        viewModel.goToNextImage()
                    case .previous:
                        viewModel.goToPreviousImage()
                    }
                }
            }

        case .magnify(let magnification):
            viewModel.viewerState.zoom(by: 1 + magnification)
        }
    }

    // MARK: - Labels

    private var counterText: String {
        let total = viewModel.viewerState.images.count
        guard total > 0 else { return "0 / 0" }
        return "\(viewModel.viewerState.currentIndex + 1) / \(total)"
    }

    private var zoomLabel: String {
        let percent = Int((viewModel.viewerState.scale * 100).rounded())
        return "\(percent)%"
    }
}

// MARK: - One-swipe-one-image scroll navigation

/// Accumulates horizontal scroll and emits at most one navigation per gesture.
struct ScrollImageNavigator: Equatable {
    enum Direction: Equatable {
        case next
        case previous
    }

    /// How far the finger/wheel must travel before a switch.
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
        // Discrete mouse wheel notches often arrive with empty phase flags.
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

        // Ignore leftover momentum once we've already switched for this gesture.
        if didNavigateThisGesture {
            if phase.contains(.ended)
                || phase.contains(.cancelled)
                || momentumPhase.contains(.ended)
                || momentumPhase.contains(.cancelled) {
                resetSession()
            }
            return nil
        }

        accumulatedX += deltaX

        if accumulatedX <= -threshold {
            didNavigateThisGesture = true
            accumulatedX = 0
            return .next
        }
        if accumulatedX >= threshold {
            didNavigateThisGesture = true
            accumulatedX = 0
            return .previous
        }

        if phase.contains(.ended)
            || phase.contains(.cancelled)
            || momentumPhase.contains(.ended)
            || momentumPhase.contains(.cancelled) {
            resetSession()
        }

        return nil
    }

    private mutating func resetSession() {
        accumulatedX = 0
        didNavigateThisGesture = false
    }
}

// MARK: - Local image loader

private struct AsyncLocalImage: View {
    let url: URL
    @State private var image: NSImage?

    var body: some View {
        Group {
            if let image {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
            } else {
                ProgressView()
                    .controlSize(.large)
                    .tint(.white)
            }
        }
        .task(id: url) {
            image = NSImage(contentsOf: url)
        }
    }
}

// MARK: - Pointer events (scroll wheel + trackpad pinch)

private struct PointerEventCatcher: NSViewRepresentable {
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

private final class PointerNSView: NSView {
    var onEvent: ((PointerEventCatcher.Event) -> Void)?
    private var monitor: Any?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard monitor == nil else { return }
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel, .magnify]) { [weak self] event in
            guard let self else { return event }
            switch event.type {
            case .scrollWheel:
                self.onEvent?(
                    .scroll(
                        deltaX: event.scrollingDeltaX,
                        deltaY: event.scrollingDeltaY,
                        isCommand: event.modifierFlags.contains(.command),
                        phase: event.phase,
                        momentumPhase: event.momentumPhase
                    )
                )
            case .magnify:
                self.onEvent?(.magnify(event.magnification))
            default:
                break
            }
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
}
