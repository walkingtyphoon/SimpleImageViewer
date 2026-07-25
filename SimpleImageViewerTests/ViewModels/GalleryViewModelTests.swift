//
//  GalleryViewModelTests.swift
//  SimpleImageViewerTests
//

import Foundation
import Testing
@testable import SimpleImageViewer

@MainActor
struct GalleryViewModelTests {

    @Test
    func loadDirectoryPopulatesImages() throws {
        let directory = try makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }

        try Data().write(to: directory.appendingPathComponent("a.png"))
        try Data().write(to: directory.appendingPathComponent("b.jpg"))

        let viewModel = GalleryViewModel(loader: ImageDirectoryLoader())
        viewModel.loadDirectory(directory)

        #expect(viewModel.images.count == 2)
        #expect(viewModel.directoryURL == directory)
        #expect(viewModel.errorMessage == nil)
        #expect(!viewModel.isEmpty)
    }

    @Test
    func loadMissingDirectorySetsError() {
        let missing = URL(fileURLWithPath: "/tmp/missing-gallery-\(UUID().uuidString)")
        let viewModel = GalleryViewModel(loader: ImageDirectoryLoader())

        viewModel.loadDirectory(missing)

        #expect(viewModel.images.isEmpty)
        #expect(viewModel.errorMessage != nil)
    }

    @Test
    func selectImageOpensViewerAtMatchingIndex() throws {
        let directory = try makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }

        try Data().write(to: directory.appendingPathComponent("a.png"))
        try Data().write(to: directory.appendingPathComponent("b.jpg"))
        try Data().write(to: directory.appendingPathComponent("c.png"))

        let viewModel = GalleryViewModel(loader: ImageDirectoryLoader())
        viewModel.loadDirectory(directory)

        let middle = viewModel.images[1]
        viewModel.openViewer(for: middle)

        #expect(viewModel.isViewerPresented)
        #expect(viewModel.viewerState.currentIndex == 1)
        #expect(viewModel.viewerState.currentImage?.name == middle.name)
    }

    @Test
    func closeViewerDismissesPresentation() throws {
        let directory = try makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        try Data().write(to: directory.appendingPathComponent("a.png"))

        let viewModel = GalleryViewModel(loader: ImageDirectoryLoader())
        viewModel.loadDirectory(directory)
        viewModel.openViewer(for: viewModel.images[0])
        viewModel.closeViewer()

        #expect(!viewModel.isViewerPresented)
    }

    @Test
    func deleteCurrentImageRemovesFileAndUpdatesGallery() throws {
        let directory = try makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }

        let target = directory.appendingPathComponent("keep-me-not.jpg")
        try Data([0x01]).write(to: target)
        try Data([0x02]).write(to: directory.appendingPathComponent("stay.png"))

        let viewModel = GalleryViewModel(
            loader: ImageDirectoryLoader(),
            deleter: FileImageDeleter()
        )
        viewModel.loadDirectory(directory)
        viewModel.openViewer(for: viewModel.images.first { $0.name == "keep-me-not.jpg" }!)

        let didDelete = viewModel.deleteCurrentImage()

        #expect(didDelete)
        #expect(viewModel.images.map(\.name) == ["stay.png"])
        #expect(!FileManager.default.fileExists(atPath: target.path))
        #expect(viewModel.isViewerPresented)
        #expect(viewModel.viewerState.currentImage?.name == "stay.png")
    }

    @Test
    func deleteLastRemainingImageClosesViewer() throws {
        let directory = try makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }
        try Data([0x01]).write(to: directory.appendingPathComponent("only.jpg"))

        let viewModel = GalleryViewModel(
            loader: ImageDirectoryLoader(),
            deleter: FileImageDeleter()
        )
        viewModel.loadDirectory(directory)
        viewModel.openViewer(for: viewModel.images[0])

        #expect(viewModel.deleteCurrentImage())
        #expect(viewModel.images.isEmpty)
        #expect(!viewModel.isViewerPresented)
    }

    // MARK: - Helpers

    private func makeTempDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("GalleryVM-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
}
