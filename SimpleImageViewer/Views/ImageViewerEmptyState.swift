import SwiftUI

struct ImageViewerEmptyState: View {
    var body: some View {
        ContentUnavailableView(
            "No Image",
            systemImage: "photo",
            description: Text("There's nothing left to show.")
        )
        .foregroundStyle(.white)
    }
}
