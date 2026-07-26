import SwiftUI

struct ImageViewerCanvas: View {
    let image: ImageFile
    @Binding var viewerState: ImageViewerState
    @Binding var scrollNavigator: ScrollImageNavigator
    let onSwipeEnd: (CGSize) -> Void
    let onNext: () -> Void
    let onPrevious: () -> Void

    @State var dragTranslation: CGSize = .zero
    @State var magnifyBaseScale: CGFloat = 1
    @State var isMagnifying = false

    var body: some View {
        GeometryReader { geo in
            AsyncLocalImage(url: image.url)
                .rotationEffect(.degrees(viewerState.rotationDegrees))
                .scaleEffect(viewerState.scale)
                .offset(x: imageOffsetX, y: viewerState.offset.height)
                .frame(width: geo.size.width, height: geo.size.height)
                .contentShape(Rectangle())
                .gesture(dragGesture)
                .simultaneousGesture(magnificationGesture)
                .onTapGesture(count: 2, perform: toggleZoom)
        }
        .padding(.top, 56)
        .padding(.bottom, 72)
        .id(image.id)
        .animation(.easeOut(duration: 0.18), value: viewerState.currentIndex)
        .background {
            PointerEventCatcher { event in
                handlePointerEvent(event)
            }
        }
    }

    private var imageOffsetX: CGFloat {
        viewerState.offset.width + (viewerState.isZoomed ? 0 : dragTranslation.width * 0.35)
    }

    private func toggleZoom() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
            if viewerState.isZoomed {
                viewerState.resetTransform()
            } else {
                viewerState.setScale(2.5)
            }
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged(handleDragChanged)
            .onEnded(handleDragEnded)
    }

    private func handleDragChanged(_ value: DragGesture.Value) {
        if viewerState.isZoomed {
            let delta = CGSize(
                width: value.translation.width - dragTranslation.width,
                height: value.translation.height - dragTranslation.height
            )
            viewerState.pan(by: delta)
        }
        dragTranslation = value.translation
    }

    private func handleDragEnded(_ value: DragGesture.Value) {
        if !viewerState.isZoomed {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                onSwipeEnd(value.translation)
            }
        }
        dragTranslation = .zero
    }
}
