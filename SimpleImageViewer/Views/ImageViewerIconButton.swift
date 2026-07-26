import SwiftUI

struct ImageViewerIconButton: View {
    let systemName: String
    var help: String?
    var destructive = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
        }
        .buttonStyle(GlassCircleButtonStyle(destructive: destructive))
        .help(help ?? "")
    }
}
