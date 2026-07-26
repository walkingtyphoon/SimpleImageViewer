import SwiftUI

struct EmptyGalleryState: View {
    let title: String
    let message: String
    let systemImage: String
    let onChooseFolder: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Spacer()
            icon
            copy
            chooseButton
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 24)
    }

    private var icon: some View {
        Image(systemName: systemImage)
            .font(.system(size: 48, weight: .light))
            .foregroundStyle(AppTheme.accent)
            .padding(28)
            .background {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Circle().strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                    }
            }
    }

    private var copy: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.secondaryLabel)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)
        }
    }

    private var chooseButton: some View {
        Button(action: onChooseFolder) {
            Text("Choose Folder")
                .font(.system(size: 15, weight: .semibold))
                .padding(.horizontal, 22)
                .padding(.vertical, 12)
                .background {
                    Capsule()
                        .fill(AppTheme.accent.opacity(0.9))
                }
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .padding(.top, 6)
    }
}
