// the notices of a panel: a bell in the header with a badge for the ones not seen yet, and each
// notice as one line under it (the body on hover). each app keeps its own notices, its seen marks
// and what opening the bell does; the kit draws them the same in both.

import LaaabsKit
import SwiftUI

/// the bell in a panel's header: `bell.badge` with the count of unseen notices (9+ past nine), lit
/// while its notices are open.
public struct NoticeBell: View {
    let unseen: Int
    let isOpen: Bool
    let action: () -> Void

    public init(unseen: Int, isOpen: Bool, action: @escaping () -> Void) {
        self.unseen = unseen
        self.isOpen = isOpen
        self.action = action
    }

    /// what the badge says, or nil for no badge.
    static func badge(unseen: Int) -> String? {
        guard unseen > 0 else { return nil }
        return unseen > 9 ? "9+" : "\(unseen)"
    }

    static func accessibilityLabel(unseen: Int) -> String {
        unseen > 0 ? String(localized: "notices, \(unseen) new") : String(localized: "notices")
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: unseen > 0 ? "bell.badge" : "bell")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(isOpen ? BrandColors.on : BrandColors.onSecondary)
                .frame(width: 26, height: 26)
                .background(isOpen ? BrandColors.surfaceSelected : .clear, in: RoundedRectangle(cornerRadius: 7))
                .overlay(alignment: .topTrailing) {
                    if let badge = Self.badge(unseen: unseen) {
                        Text(verbatim: badge)
                            .font(.brandBadge)
                            .monospacedDigit()
                            .foregroundStyle(BrandColors.surface)
                            .padding(.horizontal, 4)
                            .frame(minWidth: 14, minHeight: 14)
                            .background(BrandColors.on, in: Capsule())
                            .offset(x: 4, y: -3)
                    }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(isOpen ? String(localized: "hide the notices") : String(localized: "notices"))
        .accessibilityLabel(Self.accessibilityLabel(unseen: unseen))
    }
}

/// a notice in one line, for a panel: when it came (mono), its symbol, the title and a dismiss; the
/// body on hover.
public struct NoticeLine: View {
    let symbol: String
    let tint: Color
    let title: String
    let message: String?
    let time: String?
    let action: Action?
    let dismiss: (() -> Void)?

    /// what a notice lets a person do at once, such as "sign in" for an account signed out.
    public struct Action {
        public let title: String
        public let run: () -> Void

        public init(title: String, run: @escaping () -> Void) {
            self.title = title
            self.run = run
        }
    }

    /// - parameters:
    ///   - tint: the symbol's colour (amber for usaaage's pace notices).
    ///   - time: when it came, in mono before the symbol (`14:05`).
    ///   - action: a word in cyan before the dismiss, when the notice has something to do.
    public init(symbol: String, tint: Color = BrandColors.onSecondary, title: String, message: String?, time: String? = nil, action: Action? = nil, dismiss: (() -> Void)? = nil) {
        self.symbol = symbol
        self.tint = tint
        self.title = title
        self.message = message
        self.time = time
        self.action = action
        self.dismiss = dismiss
    }

    /// the hover text: the title, then the body.
    static func help(title: String, message: String?) -> String {
        message.map { "\(title)\n\($0)" } ?? title
    }

    public var body: some View {
        HStack(spacing: 8) {
            if let time {
                Text(verbatim: time)
                    .font(.brandDigits)
                    .foregroundStyle(BrandColors.onTertiary)
            }
            Image(systemName: symbol)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(tint)
                .frame(width: 14)
            Text(title)
                .font(.brandCallout)
                .foregroundStyle(BrandColors.on)
                .lineLimit(1)
                .truncationMode(.tail)
            Spacer(minLength: 0)
            if let action {
                Button(action: action.run) {
                    Text(action.title)
                        .font(.brandButton)
                        .foregroundStyle(BrandColors.accent)
                }
                .buttonStyle(.plain)
            }
            if let dismiss {
                Button(action: dismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(BrandColors.onTertiary)
                        .frame(width: 18, height: 18)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help(String(localized: "dismiss"))
                .accessibilityLabel(String(localized: "dismiss"))
            }
        }
        .frame(minHeight: 22)
        .contentShape(Rectangle())
        .help(Self.help(title: title, message: message))
        .accessibilityElement(children: .combine)
    }
}
