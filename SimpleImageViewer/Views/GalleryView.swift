import SwiftUI
import UniformTypeIdentifiers

struct GalleryView: View {
    @Bindable var viewModel: GalleryViewModel
    @State private var isImporterPresented = false
    @State private var securityScopedDirectory: URL?
    private let columns = [
        GridItem(.adaptive(minimum: AppTheme.galleryMinItem), spacing: AppTheme.gallerySpacing)
    ]

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                GalleryHeader(
                    subtitle: subtitle,
                    showsOpenFolderButton: !viewModel.isEmpty
                ) {
                    isImporterPresented = true
                }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 12)

                content
            }

            if viewModel.isViewerPresented {
                ImageViewerView(viewModel: viewModel)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    .zIndex(1)
            }
        }
        .animation(.easeOut(duration: 0.2), value: viewModel.isViewerPresented)
        .fileImporter(
            isPresented: $isImporterPresented,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            handleFolderPick(result)
        }
    }
    @ViewBuilder
    private var content: some View {
        if let errorMessage = viewModel.errorMessage, viewModel.images.isEmpty {
            EmptyGalleryState(
                title: "Couldn't open folder",
                message: errorMessage,
                systemImage: "exclamationmark.triangle"
            ) {
                isImporterPresented = true
            }
        } else if viewModel.isEmpty {
            EmptyGalleryState(
                title: "No images yet",
                message: "Choose a folder to browse JPG, PNG, HEIC, and more.",
                systemImage: "photo.on.rectangle.angled"
            ) {
                isImporterPresented = true
            }
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: AppTheme.gallerySpacing) {
                    ForEach(viewModel.images) { image in
                        GalleryThumbnail(image: image) {
                            viewModel.openViewer(for: image)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
                .padding(.top, 8)
            }
        }
    }
    private var subtitle: String {
        if let directoryURL = viewModel.directoryURL {
            let count = viewModel.images.count
            let noun = count == 1 ? "image" : "images"
            return "\(directoryURL.lastPathComponent) · \(count) \(noun)"
        }
        return "Select a folder to get started"
    }

    private func handleFolderPick(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            securityScopedDirectory?.stopAccessingSecurityScopedResource()
            let accessed = url.startAccessingSecurityScopedResource()
            securityScopedDirectory = accessed ? url : nil
            viewModel.loadDirectory(url)
        case .failure(let error):
            viewModel.setErrorMessage(error.localizedDescription)
        }
    }
}
