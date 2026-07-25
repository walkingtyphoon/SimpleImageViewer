//
//  ImageFile.swift
//  SimpleImageViewer
//

import Foundation

struct ImageFile: Identifiable, Equatable, Hashable, Sendable {
    let id: URL
    let url: URL
    let name: String

    init(url: URL, name: String? = nil) {
        self.url = url
        self.name = name ?? url.lastPathComponent
        self.id = url
    }
}
