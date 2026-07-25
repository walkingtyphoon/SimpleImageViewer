//
//  ImageDirectoryLoaderTests.swift
//  SimpleImageViewerTests
//

import Foundation
import Testing
@testable import SimpleImageViewer

struct ImageDirectoryLoaderTests {

    @Test
    func loadsOnlyImageFilesSortedByName() throws {
        let directory = try makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }

        try writeEmptyFile(named: "zeta.png", in: directory)
        try writeEmptyFile(named: "alpha.jpg", in: directory)
        try writeEmptyFile(named: "readme.txt", in: directory)
        try writeEmptyFile(named: "beta.HEIC", in: directory)

        let loader = ImageDirectoryLoader()
        let images = try loader.loadImages(from: directory)

        #expect(images.map(\.name) == ["alpha.jpg", "beta.HEIC", "zeta.png"])
        #expect(images.allSatisfy { $0.url.deletingLastPathComponent() == directory })
    }

    @Test
    func returnsEmptyArrayForEmptyDirectory() throws {
        let directory = try makeTempDirectory()
        defer { try? FileManager.default.removeItem(at: directory) }

        let loader = ImageDirectoryLoader()
        let images = try loader.loadImages(from: directory)

        #expect(images.isEmpty)
    }

    @Test
    func throwsWhenDirectoryDoesNotExist() {
        let missing = URL(fileURLWithPath: "/tmp/simple-image-viewer-missing-\(UUID().uuidString)")
        let loader = ImageDirectoryLoader()

        #expect(throws: ImageDirectoryLoaderError.self) {
            try loader.loadImages(from: missing)
        }
    }

    // MARK: - Helpers

    private func makeTempDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("SimpleImageViewer-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func writeEmptyFile(named name: String, in directory: URL) throws {
        try Data().write(to: directory.appendingPathComponent(name))
    }
}
