import SwiftUI

struct OpenFolderButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("Open Folder", systemImage: "folder.badge.plus")
                .font(.system(size: 14, weight: .semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay {
                    Capsule()
                        .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                }
        }
        .foregroundStyle(.white)
    }
}
