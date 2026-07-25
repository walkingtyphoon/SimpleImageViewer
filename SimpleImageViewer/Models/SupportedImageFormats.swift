//
//  SupportedImageFormats.swift
//  SimpleImageViewer
//

import Foundation

enum SupportedImageFormats {
    static let extensions: Set<String> = [
        "jpg", "jpeg", "png", "gif",
        "heic", "heif",
        "tiff", "tif",
        "bmp", "webp"
    ]

    static func isImage(fileName: String) -> Bool {
        let ext = (fileName as NSString).pathExtension.lowercased()
        guard !ext.isEmpty else { return false }
        return extensions.contains(ext)
    }

    static func isImage(url: URL) -> Bool {
        isImage(fileName: url.lastPathComponent)
    }
}
