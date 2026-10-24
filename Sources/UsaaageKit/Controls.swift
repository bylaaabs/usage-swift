// small buttons: a 26 pt symbol button and the refresh that turns into a spinner while it runs.

import LaaabsKit
import SwiftUI

/// a symbol button, 26 pt, the hover wash of the kit's rows.
public struct IconButton: View {
    let symbol: String
    let label: String
    let action: () -> Void

    @State private var isHovered = false

    public init(symbol: String, label: String, action: @escaping () -> Void) {
        self.symbol = symbol
        self.label = label
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(isHovered ? BrandColors.on : BrandColors.onSecondary)
                .frame(width: 26, height: 26)
                .background(isHovered ? BrandColors.surfaceSelected : .clear, in: RoundedRectangle(cornerRadius: 7))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .help(label)
        .accessibilityLabel(label)
    }
}

/// reads again now: a symbol button that turns into a spinner while the read runs.
public struct RefreshButton: View {
    let isRunning: Bool
    let label: String
    let action: () -> Void

    public init(isRunning: Bool, label: String = String(localized: "read now"), action: @escaping () -> Void) {
        self.isRunning = isRunning
        self.label = label
        self.action = action
    }

    public var body: some View {
        ZStack {
            if isRunning {
                ProgressView()
                    .controlSize(.small)
                    .scaleEffect(0.75)
                    .frame(width: 26, height: 26)
                    .accessibilityLabel(String(localized: "reading"))
            } else {
                IconButton(symbol: "arrow.clockwise", label: label, action: action)
            }
        }
        .frame(width: 26, height: 26)
    }
}
