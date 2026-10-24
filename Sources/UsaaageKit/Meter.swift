// the bar, the percent and the window meter: label, bar, percent and the countdown to the reset,
// with the pace warning in amber under it when the window runs out first.

import LaaabsKit
import SwiftUI

/// the one colour the usage apps add to the kit: amber, only for a window that runs out before it
/// resets at the current pace. cyan stays the signal of the account in use.
public enum KitColors {
    public static let amber = Color(hex: 0xFFB340)
}

/// a thin bar: the used share in the white ladder, cyan for the account in use, full white at or
/// past its threshold, a hairline tick at the threshold. no red, no green: the shape says it.
public struct UsageBar: View {
    let percent: Double?
    let threshold: Double?
    let active: Bool
    let dimmed: Bool
    let height: CGFloat

    public init(percent: Double?, threshold: Double? = nil, active: Bool = false, dimmed: Bool = false, height: CGFloat = 4) {
        self.percent = percent
        self.threshold = threshold
        self.active = active
        self.dimmed = dimmed
        self.height = height
    }

    public var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let share = min(max((percent ?? 0) / 100, 0), 1)
            ZStack(alignment: .leading) {
                Capsule().fill(BrandColors.hairline)
                if percent != nil {
                    Capsule()
                        .fill(fill)
                        .frame(width: max(share * width, share > 0 ? height : 0))
                }
                if let threshold, threshold < 100 {
                    // past the threshold the tick cuts the full bar in the surface colour, so it still shows.
                    Rectangle()
                        .fill((percent ?? 0) >= threshold ? BrandColors.surface : BrandColors.onTertiary)
                        .frame(width: 1, height: height + 4)
                        .offset(x: width * threshold / 100 - 0.5)
                }
            }
        }
        .frame(height: height)
        .opacity(dimmed ? 0.5 : 1)
        .accessibilityHidden(true)
    }

    private var fill: Color {
        if active { return BrandColors.accent }
        if let percent, let threshold, percent >= threshold { return BrandColors.on }
        return BrandColors.onSecondary
    }
}

/// a percentage in the mono digits, its sign a size smaller and a hair away: `82 %` that reads as
/// one number. a dash when unknown. VoiceOver reads `82 %`.
public struct PercentLabel: View {
    let value: Double?
    let font: Font
    let color: Color

    public init(value: Double?, font: Font = .brandDigits, color: Color = BrandColors.onBody) {
        self.value = value
        self.font = font
        self.color = color
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            if let value {
                Text(verbatim: KitFormat.percentNumber(value))
                    .font(font)
                    .monospacedDigit()
                    .foregroundStyle(color)
                Text(verbatim: "%")
                    .font(.brandCaption)
                    .foregroundStyle(color.opacity(0.7))
            } else {
                Text(verbatim: "-")
                    .font(font)
                    .foregroundStyle(BrandColors.onTertiary)
            }
        }
        .lineLimit(1)
        .fixedSize()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(value.map(KitFormat.percent) ?? String(localized: "unknown"))
    }
}

/// `runs out at 17:40`, in amber.
public struct PaceWarning: View {
    let at: KitEpoch
    let now: KitEpoch

    public init(at: KitEpoch, now: KitEpoch) {
        self.at = at
        self.now = now
    }

    public var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "speedometer")
                .font(.system(size: 9, weight: .semibold))
            Text(verbatim: KitFormat.runsOut(at, now: now))
                .font(.brandCaption)
                .monospacedDigit()
        }
        .foregroundStyle(KitColors.amber)
        .help(String(localized: "at the pace of the last hour this window reaches 100 % before it resets"))
    }
}

/// one window of an account: its label, the bar, the percent and the countdown to its reset, and
/// under it, in amber, when it runs out at the current pace.
public struct WindowMeter: View {
    /// `full` on the dashboard cards, `compact` in the menu bar panel.
    public enum Style: Sendable {
        case full, compact

        /// the label column when nothing wider is asked for.
        public var labelWidth: CGFloat { self == .compact ? 30 : 38 }
        /// the countdown column: `in 2 d 23 h` fits.
        public var countdownWidth: CGFloat { self == .compact ? 78 : 96 }
    }

    let window: KitWindow
    let active: Bool
    let style: Style
    let labelWidth: CGFloat?
    let now: KitEpoch

    /// `labelWidth`: one label column for every meter of a list, so the bars line up.
    public init(_ window: KitWindow, active: Bool = false, style: Style = .full, labelWidth: CGFloat? = nil, now: KitEpoch) {
        self.window = window
        self.active = active
        self.style = style
        self.labelWidth = labelWidth
        self.now = now
    }

    private var labelColumn: CGFloat { labelWidth ?? style.labelWidth }

    public var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 8) {
                Text(window.kindLabel)
                    .font(.brandCaption)
                    .foregroundStyle(BrandColors.onTertiary)
                    .lineLimit(1)
                    .frame(width: labelColumn, alignment: .leading)
                UsageBar(percent: window.usedPct, threshold: window.threshold, active: active, dimmed: window.stale)
                PercentLabel(value: window.usedPct, color: window.usedPct == nil ? BrandColors.onTertiary : BrandColors.onBody)
                    .frame(width: 44, alignment: .trailing)
                Text(countdown)
                    .font(.brandCaption)
                    .monospacedDigit()
                    .foregroundStyle(BrandColors.onTertiary)
                    .lineLimit(1)
                    .frame(width: style.countdownWidth, alignment: .trailing)
            }
            if let runsOut = window.runsOut(now: now) {
                PaceWarning(at: runsOut, now: now)
                    .padding(.leading, labelColumn + 8)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    private var countdown: String {
        guard window.usedPct != nil else { return String(localized: "unknown") }
        return KitFormat.countdown(to: window.resetsAt, now: now) ?? String(localized: "no reset time")
    }

    private var accessibilityText: String {
        guard let used = window.usedPct else { return String(localized: "\(window.kindLabel): unknown") }
        let reset = KitFormat.countdown(to: window.resetsAt, now: now).map { String(localized: ", resets \($0)") } ?? ""
        let pace = window.runsOut(now: now).map { ", " + KitFormat.runsOut($0, now: now) } ?? ""
        return String(localized: "\(window.kindLabel): \(KitFormat.percent(used)) used\(reset)\(pace)")
    }
}

/// the label column for a list of meters: wide enough for its longest label (`Fable week`), nil
/// when the style's own column fits them all.
public func meterLabelWidth(_ windows: [KitWindow], style: WindowMeter.Style) -> CGFloat? {
    let longest = windows.map(\.kindLabel.count).max() ?? 0
    let wanted = CGFloat(longest) * 6.2
    guard wanted > style.labelWidth else { return nil }
    return min(wanted, 96)
}

/// one window at full width, for the panel's account in detail: its name, a 6 pt bar, how much is
/// used and when it resets; under it the pace against an even use (`pace: ahead +12 %`) and whether
/// it lasts to the reset, the running out in amber.
public struct WindowSection: View {
    let window: KitWindow
    let active: Bool
    let now: KitEpoch

    public init(_ window: KitWindow, active: Bool = false, now: KitEpoch) {
        self.window = window
        self.active = active
        self.now = now
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(window.kindLabel)
                .font(.brandBody)
                .foregroundStyle(BrandColors.on)
            UsageBar(percent: window.usedPct, threshold: window.threshold, active: active, dimmed: window.stale, height: 6)
            HStack(spacing: 8) {
                Text(window.usedPct.map { String(localized: "\(KitFormat.percent($0)) used") } ?? String(localized: "unknown"))
                    .font(.brandCaption)
                    .monospacedDigit()
                    .foregroundStyle(BrandColors.onBody)
                Spacer(minLength: 0)
                Text(KitFormat.countdown(to: window.resetsAt, now: now).map { String(localized: "resets \($0)") } ?? String(localized: "no reset time"))
                    .font(.brandCaption)
                    .monospacedDigit()
                    .foregroundStyle(BrandColors.onTertiary)
            }
            if let line = paceLine {
                HStack(spacing: 0) {
                    Text(line.pace)
                        .foregroundStyle(BrandColors.onSecondary)
                    if let outcome = line.outcome {
                        Text(verbatim: line.pace.isEmpty ? outcome : ", \(outcome)")
                            .foregroundStyle(line.runsOut ? KitColors.amber : BrandColors.onSecondary)
                    }
                }
                .font(.brandCaption)
                .monospacedDigit()
                .help(String(localized: "against an even use from the start of the window to its reset; whether it runs out is the pace of the last hour"))
            }
        }
        .accessibilityElement(children: .combine)
    }

    /// `pace: ahead +12 %` and `runs out at thu 17:40` or `lasts to the reset`.
    private var paceLine: (pace: String, outcome: String?, runsOut: Bool)? {
        let runsOut = window.runsOut(now: now)
        let pace: String = window.paceDelta.map { delta in
            let points = Int(delta.rounded())
            if abs(points) < 3 { return String(localized: "pace: on pace") }
            return points > 0
                ? String(localized: "pace: ahead +\(points) %")
                : String(localized: "pace: behind \(points) %")
        } ?? ""
        if let runsOut {
            return (pace, KitFormat.runsOut(runsOut, now: now), true)
        }
        guard !pace.isEmpty else { return nil }
        return (pace, (window.usedPct ?? 0) < 100 ? String(localized: "lasts to the reset") : nil, false)
    }
}
