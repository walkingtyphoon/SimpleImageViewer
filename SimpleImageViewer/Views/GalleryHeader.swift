import SwiftUI

struct GalleryHeader: View {
    let subtitle: String
    let showsOpenFolderButton: Bool
    let onOpenFolder: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Photos")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppTheme.secondaryLabel)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()

            if showsOpenFolderButton {
                OpenFolderButton(action: onOpenFolder)
            }
        }
    }
}
