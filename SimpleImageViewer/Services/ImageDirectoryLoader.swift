//
//  ImageDirectoryLoader.swift
//  SimpleImageViewer
//

import Foundation

enum ImageDirectoryLoaderError: Error, Equatable, LocalizedError {
    case directoryNotFound(URL)
    case notADirectory(URL)
    case unreadable(URL)

    var errorDescription: String? {
        switch self {
        case .directoryNotFound(let url):
            return "Folder not found: \(url.path)"
        case .notADirectory(let url):
            return "Not a folder: \(url.path)"
        case .unreadable(let url):
            return "Unable to read folder: \(url.path)"
        }
    }
}

protocol ImageLoading: Sendable {
    func loadImages(from directory: URL) throws -> [ImageFile]
}

struct ImageDirectoryLoader: ImageLoading {
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func loadImages(from directory: URL) throws -> [ImageFile] {
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: directory.path, isDirectory: &isDirectory) else {
            throw ImageDirectoryLoaderError.directoryNotFound(directory)
        }
        guard isDirectory.boolValue else {
            throw ImageDirectoryLoaderError.notADirectory(directory)
        }

        let contents: [URL]
        do {
            contents = try fileManager.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
            )
        } catch {
            throw ImageDirectoryLoaderError.unreadable(directory)
        }

        return contents
            .filter { url in
                let values = try? url.resourceValues(forKeys: [.isRegularFileKey])
                let isFile = values?.isRegularFile ?? true
                return isFile && SupportedImageFormats.isImage(url: url)
            }
            .map { ImageFile(url: $0) }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}
