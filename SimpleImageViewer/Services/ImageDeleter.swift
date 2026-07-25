//
//  ImageDeleter.swift
//  SimpleImageViewer
//

import Foundation

protocol ImageDeleting: Sendable {
    func delete(_ image: ImageFile) throws
}

struct FileImageDeleter: ImageDeleting {
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func delete(_ image: ImageFile) throws {
        try fileManager.removeItem(at: image.url)
    }
}
