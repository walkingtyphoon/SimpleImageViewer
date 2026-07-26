import AppKit
import SwiftUI

struct GalleryThumbnail: View {
    let image: ImageFile
    let onTap: () -> Void

    @State private var nsImage: NSImage?

    var body: some View {
        Button(action: onTap) {
            content
                .aspectRatio(1, contentMode: .fit)
                .overlay(alignment: .bottom) {
                    nameBackdrop
                }
                .overlay(alignment: .bottomLeading) {
                    nameLabel
                }
        }
        .buttonStyle(.plain)
        .task(id: image.id) {
            nsImage = ThumbnailLoader.load(url: image.url, maxPixel: 360)
        }
    }

    private var content: some View {
        ZStack {
            GlassCardBackground()

            if let nsImage {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped()
                    .clipShape(
                        RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                    )
            } else {
                ProgressView()
                    .controlSize(.small)
            }
        }
    }

    private var nameBackdrop: some View {
        LinearGradient(
            colors: [.clear, .black.opacity(0.55)],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 48)
        .clipShape(
            UnevenRoundedRectangle(
                bottomLeadingRadius: AppTheme.cardRadius,
                bottomTrailingRadius: AppTheme.cardRadius,
                style: .continuous
            )
        )
    }

    private var nameLabel: some View {
        Text(image.name)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.white.opacity(0.92))
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
    }
}
