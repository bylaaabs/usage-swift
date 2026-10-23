// previews of every piece on the kit's surface, and the sample values they draw.

import AppKit
import LaaabsKit
import SwiftUI

/// sample values for previews, snapshots and the apps' demo modes.
public enum KitSamples {
    public static let now: KitEpoch = 1_792_065_600

    public static let fiveHour = KitWindow(id: "5h", kindLabel: "5 h", usedPct: 62, resetsAt: now + 2 * 3600 + 10 * 60, threshold: 80, runsOutAt: now + 5400)
    public static let week = KitWindow(id: "7d", kindLabel: "week", usedPct: 84, resetsAt: now + 3 * 86_400 + 4 * 3600, threshold: 80)
    public static let modelWeek = KitWindow(id: "model_week:Fable", kindLabel: "Fable week", usedPct: 12, resetsAt: now + 3 * 86_400, threshold: 80)
    public static let unknown = KitWindow(id: "7d", kindLabel: "week", usedPct: nil)
}

/// every piece of the kit on one surface: what the previews and the snapshot test draw.
public struct KitGallery: View {
    public init() {}

    public var body: some View {
        let now = KitSamples.now
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                StatusDot(.inUse)
                StatusDot(.ready)
                StatusDot(.quiet)
                StatusDot(.idle)
                StatusDot(.signedOut)
                StatusDot(.paused)
                PlanBadge("Max 20x")
                InUsePill()
                InUsePill("in use")
                RefreshButton(isRunning: false) {}
                RefreshButton(isRunning: true) {}
            }
            AccountRowView(
                label: "work", plan: "Max 20x", dot: .inUse, active: true, detail: "Claude Code",
                windows: [KitSamples.fiveHour, KitSamples.week], now: now
            )
            AccountRowView(
                label: "personal", plan: "Plus", dot: .ready, detail: "Codex",
                windows: [KitSamples.fiveHour, KitSamples.unknown], now: now
            )
            AccountRowView(label: "cursor", dot: .quiet, detail: "Cursor", windows: [], note: "usage unknown - Cursor has no source to read", now: now)
            HStack(alignment: .top, spacing: 12) {
                AccountCardView(
                    label: "work", plan: "Max 20x", dot: .inUse, active: true, detail: "Claude Code",
                    subtitle: "ada@example.com, from swaaap",
                    windows: [KitSamples.fiveHour, KitSamples.week, KitSamples.modelWeek], now: now
                )
                AccountCardView(
                    label: "personal", plan: "Plus", dot: .signedOut, detail: "Codex",
                    windows: [], note: "signed out: sign in with Codex's own login", now: now
                )
            }
            HStack(spacing: 16) {
                ForEach(Array(KitGallery.glyphs.enumerated()), id: \.offset) { _, glyph in
                    Image(nsImage: glyph.image())
                        .renderingMode(.template)
                        .foregroundStyle(BrandColors.on)
                }
            }
        }
        .padding(20)
        .frame(width: 760)
        .background(BrandColors.surface)
    }

    /// the two menu bar variants, as the side by side snapshot draws them.
    public nonisolated static let glyphs: [MenuBarGlyph] = [
        .usage([KitSamples.fiveHour, KitSamples.week]),
        .usage([KitSamples.fiveHour, KitSamples.week, KitSamples.modelWeek]),
        .switching(level: 62, active: true),
        .switching(level: 62, active: false),
    ]
}

#Preview("usaaage kit") {
    KitGallery()
}
