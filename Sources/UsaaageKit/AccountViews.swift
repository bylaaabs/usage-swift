// the account as a panel row and as a dashboard card. the same parts in the same order in both
// apps: the dot, the label, the plan badge, the in use pill, the app's own tags, then the meters
// (or why there are none). slots take what only one app has: tags, trailing buttons, extra rows,
// a footer.

import LaaabsKit
import SwiftUI

/// one account in the menu bar panel: the dot, the label, the plan, the in use pill, the tags and a
/// caption on the trailing edge; then its compact meters or a note. the account in use carries the
/// 3 pt cyan bar at the leading edge. hovering washes the row.
public struct AccountRowView<Tags: View, Trailing: View, Extra: View>: View {
    let label: String
    let plan: String?
    let dot: StatusDot.State
    let active: Bool
    let activeText: String
    let detail: String?
    let client: KitClient?
    let windows: [KitWindow]
    let note: String?
    let labelWidth: CGFloat?
    let now: KitEpoch
    let tags: Tags
    let trailing: (Bool) -> Trailing
    let extra: Extra

    @State private var isHovered = false

    /// - parameters:
    ///   - dot: the status dot; pass `.inUse` with `active`.
    ///   - active: the account in use: cyan bars, the pill and the leading bar.
    ///   - activeText: the pill's word (`active` in usaaage, `in use` in swaaap).
    ///   - detail: a caption on the trailing edge, such as the provider.
    ///   - client: its `ClientMark` before the dot; with it, `detail` is not drawn.
    ///   - note: why there are no meters, in one or two lines.
    ///   - labelWidth: one label column for every meter of the row (see `meterLabelWidth`).
    ///   - tags: badges after the label and the pill.
    ///   - trailing: buttons on the trailing edge, given whether the row is hovered.
    ///   - extra: rows under the meters, such as folded per model weeks; drawn only with meters.
    public init(
        label: String,
        plan: String? = nil,
        dot: StatusDot.State,
        active: Bool = false,
        activeText: String = String(localized: "active"),
        detail: String? = nil,
        client: KitClient? = nil,
        windows: [KitWindow],
        note: String? = nil,
        labelWidth: CGFloat? = nil,
        now: KitEpoch,
        @ViewBuilder tags: () -> Tags,
        @ViewBuilder trailing: @escaping (Bool) -> Trailing,
        @ViewBuilder extra: () -> Extra
    ) {
        self.label = label
        self.plan = plan
        self.dot = dot
        self.active = active
        self.activeText = activeText
        self.detail = detail
        self.client = client
        self.windows = windows
        self.note = note
        self.labelWidth = labelWidth
        self.now = now
        self.tags = tags()
        self.trailing = trailing
        self.extra = extra()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 7) {
                if let client {
                    ClientMark(client, size: 14)
                }
                StatusDot(dot)
                Text(label)
                    .font(.brandBody)
                    .foregroundStyle(BrandColors.on)
                    .lineLimit(1)
                PlanBadge(plan)
                if active { InUsePill(activeText) }
                tags
                Spacer(minLength: 0)
                if let detail, client == nil {
                    Text(detail)
                        .font(.brandCaption)
                        .foregroundStyle(BrandColors.onTertiary)
                        .lineLimit(1)
                }
                trailing(isHovered)
            }
            if let note {
                Text(note)
                    .font(.brandCaption)
                    .foregroundStyle(BrandColors.onTertiary)
                    .lineLimit(2)
                    .padding(.leading, client == nil ? 14 : 35)
            }
            // the extra rows belong to the meters: a row with no meters draws neither.
            if !windows.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(windows) { window in
                        WindowMeter(window, active: active, style: .compact, labelWidth: labelWidth, now: now)
                    }
                    extra
                }
                .padding(.leading, client == nil ? 14 : 35)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(isHovered ? BrandColors.surfaceHover : .clear, in: RoundedRectangle(cornerRadius: 9))
        .inUseBar(active)
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
    }
}

extension AccountRowView where Tags == EmptyView, Trailing == EmptyView, Extra == EmptyView {
    /// a row with no slots.
    public init(
        label: String, plan: String? = nil, dot: StatusDot.State, active: Bool = false,
        activeText: String = String(localized: "active"), detail: String? = nil, client: KitClient? = nil,
        windows: [KitWindow], note: String? = nil, labelWidth: CGFloat? = nil, now: KitEpoch
    ) {
        self.init(
            label: label, plan: plan, dot: dot, active: active, activeText: activeText, detail: detail,
            client: client, windows: windows, note: note, labelWidth: labelWidth, now: now,
            tags: { EmptyView() }, trailing: { _ in EmptyView() }, extra: { EmptyView() }
        )
    }
}

/// one account on the dashboard: the dot, the label in the headline, the plan, the in use pill,
/// the tags, a caption and buttons on the trailing edge; a subtitle (who it is, where it comes
/// from); every window as a full meter, or a note; a footer. the account in use has a crisp 1.5 pt
/// cyan border, nothing else.
public struct AccountCardView<Tags: View, Trailing: View, Footer: View>: View {
    let label: String
    let plan: String?
    let dot: StatusDot.State
    let active: Bool
    let activeText: String
    let detail: String?
    let client: KitClient?
    let subtitle: String?
    let windows: [KitWindow]
    let note: String?
    let labelWidth: CGFloat?
    let now: KitEpoch
    let tags: Tags
    let trailing: Trailing
    let footer: Footer

    /// `labelWidth`: one label column on every card of a grid, so the bars line up (74 fits
    /// `Fable week`). `client`: its `ClientMark` before the dot; with it, `detail` is not
    /// drawn as a caption.
    public init(
        label: String,
        plan: String? = nil,
        dot: StatusDot.State,
        active: Bool = false,
        activeText: String = String(localized: "active"),
        detail: String? = nil,
        client: KitClient? = nil,
        subtitle: String? = nil,
        windows: [KitWindow],
        note: String? = nil,
        labelWidth: CGFloat? = 74,
        now: KitEpoch,
        @ViewBuilder tags: () -> Tags,
        @ViewBuilder trailing: () -> Trailing,
        @ViewBuilder footer: () -> Footer
    ) {
        self.label = label
        self.plan = plan
        self.dot = dot
        self.active = active
        self.activeText = activeText
        self.detail = detail
        self.client = client
        self.subtitle = subtitle
        self.windows = windows
        self.note = note
        self.labelWidth = labelWidth
        self.now = now
        self.tags = tags()
        self.trailing = trailing()
        self.footer = footer()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                if let client {
                    ClientMark(client)
                }
                StatusDot(dot, size: 8)
                Text(label)
                    .font(.brandHeadline)
                    .foregroundStyle(BrandColors.on)
                    .lineLimit(1)
                PlanBadge(plan)
                if active { InUsePill(activeText) }
                tags
                Spacer(minLength: 0)
                if let detail, client == nil {
                    Text(detail)
                        .font(.brandCaption)
                        .foregroundStyle(BrandColors.onTertiary)
                        .lineLimit(1)
                }
                trailing
            }
            if let subtitle {
                Text(subtitle)
                    .font(.brandCaption)
                    .foregroundStyle(BrandColors.onSecondary)
                    .lineLimit(1)
            }
            if !windows.isEmpty {
                VStack(spacing: 8) {
                    ForEach(windows) { window in
                        WindowMeter(window, active: active, style: .full, labelWidth: labelWidth, now: now)
                    }
                }
                .padding(.top, 2)
            } else if let note {
                Text(note)
                    .font(.brandCallout)
                    .foregroundStyle(BrandColors.onSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            footer
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(BrandColors.surfaceTrack, in: RoundedRectangle(cornerRadius: 10))
        .inUseBorder(active)
    }
}

extension AccountCardView where Tags == EmptyView, Trailing == EmptyView, Footer == EmptyView {
    /// a card with no slots.
    public init(
        label: String, plan: String? = nil, dot: StatusDot.State, active: Bool = false,
        activeText: String = String(localized: "active"), detail: String? = nil, client: KitClient? = nil,
        subtitle: String? = nil, windows: [KitWindow], note: String? = nil, labelWidth: CGFloat? = 74, now: KitEpoch
    ) {
        self.init(
            label: label, plan: plan, dot: dot, active: active, activeText: activeText, detail: detail,
            client: client, subtitle: subtitle, windows: windows, note: note, labelWidth: labelWidth, now: now,
            tags: { EmptyView() }, trailing: { EmptyView() }, footer: { EmptyView() }
        )
    }
}
