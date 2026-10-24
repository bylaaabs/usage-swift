// the account's state at a glance: the status dot, the plan badge and the in use treatment (a plain
// cyan dot, the kit's status pill, a crisp 1.5 pt border on a card, a 3 pt bar on a panel row).
// never a glow, a halo, a shadow or a soft cyan tint behind anything.

import AppKit
import LaaabsKit
import SwiftUI

/// the dot before an account. cyan only for the account in use, a plain fill with no glow.
public struct StatusDot: View {
    public enum State: Hashable, Sendable {
        /// the account in use: plain filled cyan.
        case inUse
        /// signed in and readable: white at 80 %.
        case ready
        /// signed in, but its usage cannot be read: white at 30 %.
        case quiet
        /// out of the rotation (swaaap): white at 20 %.
        case idle
        /// signed out or not known yet: a ring.
        case signedOut
        /// paused (swaaap): a dim ring.
        case paused
    }

    let state: State
    let size: CGFloat

    public init(_ state: State, size: CGFloat = 7) {
        self.state = state
        self.size = size
    }

    public var body: some View {
        Group {
            switch state {
            case .inUse: Circle().fill(BrandColors.accent)
            case .ready: Circle().fill(BrandColors.onBody)
            case .quiet: Circle().fill(BrandColors.onTertiary)
            case .idle: Circle().fill(BrandColors.onDisabled)
            case .signedOut: Circle().strokeBorder(BrandColors.onSecondary, lineWidth: 1.2)
            case .paused: Circle().strokeBorder(BrandColors.onTertiary, lineWidth: 1.2)
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

/// the dot of the account in use: plain filled cyan, no glow.
public struct ActiveDot: View {
    let size: CGFloat

    public init(size: CGFloat = 7) { self.size = size }

    public var body: some View { StatusDot(.inUse, size: size) }
}

/// the kit's status pill for the account in use: `active` in usaaage, `in use` in swaaap.
public struct InUsePill: View {
    let text: String
    let help: String?

    public init(_ text: String = String(localized: "active"), help: String? = nil) {
        self.text = text
        self.help = help
    }

    public var body: some View {
        BrandStatusPill(text: text, isLive: true)
            .fixedSize()
            .help(help ?? "")
            .accessibilityLabel(String(localized: "\(text), in use now"))
    }
}

/// the plan next to the account's name: `Max 20x`, `Plus`. nothing when there is none.
public struct PlanBadge: View {
    let name: String?

    public init(_ name: String?) { self.name = name }

    public var body: some View {
        if let name, !name.isEmpty {
            BrandBadge(text: name, tint: BrandColors.on)
                .fixedSize()
                .accessibilityLabel(String(localized: "plan \(name)"))
        }
    }
}

extension View {
    /// the account in use, on a card: a crisp 1.5 pt cyan border. no glow, no tint.
    public func inUseBorder(_ on: Bool, cornerRadius: CGFloat = 10) -> some View {
        overlay {
            if on {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(BrandColors.accent, lineWidth: 1.5)
            }
        }
    }

    /// the account in use, on a panel row: a 3 pt cyan bar at its leading edge.
    public func inUseBar(_ on: Bool, inset: CGFloat = 8) -> some View {
        overlay(alignment: .leading) {
            if on {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(BrandColors.accent)
                    .frame(width: 3)
                    .padding(.vertical, inset)
            }
        }
    }
}

/// the client of an account, as the dashboard and the panel name it.
public enum KitClient: Hashable, Sendable {
    case claude, codex, cursor
    /// a client the kit has no mark for: its name, drawn as two letters.
    case other(String)

    public var name: String {
        switch self {
        case .claude: "Claude Code"
        case .codex: "Codex"
        case .cursor: "Cursor"
        case let .other(name): name
        }
    }

    /// the svg in `Resources/clients`, when the kit has the client's mark.
    var markFile: String? {
        switch self {
        case .claude: "claude"
        case .codex: "openai"
        case .cursor: "cursor"
        case .other: nil
        }
    }
}

/// the client of an account as its mark (Claude's star, OpenAI's knot for Codex, Cursor's cube),
/// one colour, the body white; an unknown client as two letters on the track. hovering names it.
public struct ClientMark: View {
    let client: KitClient
    let size: CGFloat

    public init(_ client: KitClient, size: CGFloat = 16) {
        self.client = client
        self.size = size
    }

    public var body: some View {
        Group {
            if let image = Self.image(client) {
                Image(nsImage: image)
                    .renderingMode(.template)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .foregroundStyle(BrandColors.onBody)
                    .frame(width: size, height: size)
            } else {
                Text(verbatim: String(client.name.prefix(2)).uppercased())
                    .font(.custom("GeistMono-Medium", size: size * 0.5))
                    .foregroundStyle(BrandColors.onBody)
                    .frame(width: size + 4, height: size + 4)
                    .background(BrandColors.surfaceSelected, in: RoundedRectangle(cornerRadius: (size + 4) * 0.28))
            }
        }
        .fixedSize()
        .help(client.name)
        .accessibilityLabel(client.name)
    }

    @MainActor private static var cache: [String: NSImage] = [:]

    /// the client's mark as a template image, read once from the package's resources.
    @MainActor static func image(_ client: KitClient) -> NSImage? {
        guard let file = client.markFile else { return nil }
        if let cached = cache[file] { return cached }
        guard let url = Bundle.module.url(forResource: file, withExtension: "svg", subdirectory: "clients"),
              let image = NSImage(contentsOf: url) else { return nil }
        image.isTemplate = true
        cache[file] = image
        return image
    }
}
