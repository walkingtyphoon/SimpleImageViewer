//
//  SimpleImageViewerApp.swift
//  SimpleImageViewer
//
//  Created by Typhoon Walking on 2026/7/25.
//

import SwiftUI

@main
struct SimpleImageViewerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: 980, height: 700)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}
