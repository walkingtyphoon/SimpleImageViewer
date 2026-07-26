import SwiftUI

struct ImageViewerChrome: View {
    let image: ImageFile?
    let counterText: String
    let zoomLabel: String
    let onClose: () -> Void
    let onRotateLeft: () -> Void
    let onRotateRight: () -> Void
    let onDelete: () -> Void
    let onZoomOut: () -> Void
    let onZoomIn: () -> Void
    let onResetZoom: () -> Void

    var body: some View {
        VStack {
            topBar
            Spacer()
            bottomBar
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private var topBar: some View {
        HStack(spacing: 10) {
            ImageViewerIconButton(systemName: "xmark", help: "Close (Esc)", action: onClose)
            Spacer()
            titlePill
            Spacer()
            imageActions
        }
    }

    @ViewBuilder
    private var titlePill: some View {
        if let image {
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
    }

    private var imageActions: some View {
        HStack(spacing: 8) {
            ImageViewerIconButton(systemName: "rotate.left", help: "Rotate left") {
                onRotateLeft()
            }
            ImageViewerIconButton(systemName: "rotate.right", help: "Rotate right") {
                onRotateRight()
            }
            ImageViewerIconButton(systemName: "trash", help: "Delete", destructive: true) {
                onDelete()
            }
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 8) {
            ImageViewerIconButton(systemName: "minus.magnifyingglass", action: onZoomOut)
            Text(zoomLabel)
                .font(.system(size: 12, weight: .semibold, design: .rounded).monospacedDigit())
                .foregroundStyle(.white)
                .frame(minWidth: 48)
            ImageViewerIconButton(systemName: "plus.magnifyingglass", action: onZoomIn)
            ImageViewerIconButton(systemName: "arrow.counterclockwise", help: "Reset zoom") {
                onResetZoom()
            }
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
}
