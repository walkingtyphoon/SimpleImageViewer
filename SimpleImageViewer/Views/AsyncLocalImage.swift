import AppKit
import SwiftUI

struct AsyncLocalImage: View {
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
