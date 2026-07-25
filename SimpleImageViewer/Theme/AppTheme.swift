//
//  AppTheme.swift
//  SimpleImageViewer
//

import SwiftUI

/// Visual tokens inspired by Apple's iOS 26 liquid-glass language, adapted for macOS.
enum AppTheme {
    static let cornerRadius: CGFloat = 22
    static let cardRadius: CGFloat = 16
    static let controlSize: CGFloat = 36
    static let gallerySpacing: CGFloat = 14
    static let galleryMinItem: CGFloat = 140

    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.07, green: 0.08, blue: 0.12),
            Color(red: 0.11, green: 0.10, blue: 0.18),
            Color(red: 0.05, green: 0.07, blue: 0.14)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accent = Color(red: 0.45, green: 0.62, blue: 1.0)
    static let danger = Color(red: 1.0, green: 0.38, blue: 0.40)
    static let secondaryLabel = Color.white.opacity(0.72)
}

struct GlassCardBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.35),
                                Color.white.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
    }
}

struct GlassCircleButtonStyle: ButtonStyle {
    var tint: Color = .white
    var destructive: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(destructive ? AppTheme.danger : tint)
            .frame(width: AppTheme.controlSize, height: AppTheme.controlSize)
            .background {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Circle()
                            .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.28), radius: 8, y: 3)
            }
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
