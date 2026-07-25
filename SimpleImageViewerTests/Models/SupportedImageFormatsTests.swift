//
//  SupportedImageFormatsTests.swift
//  SimpleImageViewerTests
//

import Foundation
import Testing
@testable import SimpleImageViewer

struct SupportedImageFormatsTests {

    @Test(arguments: [
        "photo.jpg",
        "photo.JPEG",
        "shot.png",
        "anim.gif",
        "raw.heic",
        "scan.tiff",
        "icon.bmp",
        "web.webp",
        "portrait.heif",
        "scan.tif",
        "camera.jpeg"
    ])
    func acceptsCommonImageExtensions(_ name: String) {
        #expect(SupportedImageFormats.isImage(fileName: name))
    }

    @Test(arguments: [
        "notes.txt",
        "movie.mp4",
        "archive.zip",
        "code.swift",
        "noextension",
        ".hidden"
    ])
    func rejectsNonImageFiles(_ name: String) {
        #expect(!SupportedImageFormats.isImage(fileName: name))
    }

    @Test
    func acceptsURLWithImageExtension() {
        let url = URL(fileURLWithPath: "/tmp/gallery/sunset.PNG")
        #expect(SupportedImageFormats.isImage(url: url))
    }
}
