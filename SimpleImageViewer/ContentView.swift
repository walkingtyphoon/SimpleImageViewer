//
//  ContentView.swift
//  SimpleImageViewer
//
//  Created by Typhoon Walking on 2026/7/25.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = GalleryViewModel()

    var body: some View {
        GalleryView(viewModel: viewModel)
            .frame(minWidth: 720, minHeight: 520)
    }
}

#Preview {
    ContentView()
}
