//
//  GalleryView.swift
//  SimpleImageViewer
//

import AppKit
import ImageIO
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
                header
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

    // MARK: - Sections

    private var header: some View {
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

            Button {
                isImporterPresented = true
            } label: {
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

    @ViewBuilder
    private var content: some View {
        if let errorMessage = viewModel.errorMessage, viewModel.images.isEmpty {
            emptyState(
                title: "Couldn't open folder",
                message: errorMessage,
                systemImage: "exclamationmark.triangle"
            )
        } else if viewModel.isEmpty {
            emptyState(
                title: "No images yet",
                message: "Choose a folder to browse JPG, PNG, HEIC, and more.",
                systemImage: "photo.on.rectangle.angled"
            )
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

    private func emptyState(title: String, message: String, systemImage: String) -> some View {
        VStack(spacing: 18) {
            Spacer()
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

            Button {
                isImporterPresented = true
            } label: {
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

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 24)
    }

    // MARK: - Helpers

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

// MARK: - Thumbnail

private struct GalleryThumbnail: View {
    let image: ImageFile
    let onTap: () -> Void

    @State private var nsImage: NSImage?

    var body: some View {
        Button(action: onTap) {
            ZStack {
                GlassCardBackground()

                if let nsImage {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
                } else {
                    ProgressView()
                        .controlSize(.small)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .overlay(alignment: .bottom) {
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
            .overlay(alignment: .bottomLeading) {
                Text(image.name)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.92))
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
            }
        }
        .buttonStyle(.plain)
        .task(id: image.id) {
            nsImage = ThumbnailLoader.load(url: image.url, maxPixel: 360)
        }
    }
}

enum ThumbnailLoader {
    static func load(url: URL, maxPixel: CGFloat) -> NSImage? {
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions) else {
            return NSImage(contentsOf: url)
        }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixel,
            kCGImageSourceShouldCacheImmediately: true
        ]

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return NSImage(contentsOf: url)
        }
        return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
    }
}
