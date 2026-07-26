import SwiftUI

struct ImageViewerSideNavigation: View {
    let canGoPrevious: Bool
    let canGoNext: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack {
            navButton(
                systemName: "chevron.left",
                enabled: canGoPrevious,
                help: "Previous (←)",
                action: onPrevious
            )

            Spacer()

            navButton(
                systemName: "chevron.right",
                enabled: canGoNext,
                help: "Next (→)",
                action: onNext
            )
        }
        .padding(.horizontal, 20)
    }

    private func navButton(
        systemName: String,
        enabled: Bool,
        help: String,
        action: @escaping () -> Void
    ) -> some View {
        ImageViewerIconButton(systemName: systemName, help: help, action: action)
            .disabled(!enabled)
            .opacity(enabled ? 1 : 0.35)
    }
}
