// the strip at the top of a dashboard: a few figures side by side on the track, hairlines between
// them, every figure as tall as the tallest. usaaage fills it with what is tightest, the spend and
// the pace; swaaap with what has room and what goes next. each app says what its figures are.

import LaaabsKit
import SwiftUI

/// the strip: its figures in one row on `surfaceTrack`, radius 10. put a `StripDivider` between
/// two figures.
public struct FigureStrip<Content: View>: View {
    let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            content
        }
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BrandColors.surfaceTrack, in: RoundedRectangle(cornerRadius: 10))
        // every figure as tall as the tallest, so the dividers run the full height.
        .fixedSize(horizontal: false, vertical: true)
    }
}

/// the hairline between two figures, the strip's full height.
public struct StripDivider: View {
    public init() {}

    public var body: some View {
        Rectangle()
            .fill(BrandColors.hairlineSoft)
            .frame(width: 1)
            .frame(maxHeight: .infinity)
    }
}

/// one figure: the title (and a link beside it), the value, one line under it.
public struct StripFigure<Content: View, Accessory: View>: View {
    let title: String
    let content: Content
    let accessory: Accessory

    public init(title: String, @ViewBuilder content: () -> Content, @ViewBuilder accessory: () -> Accessory) {
        self.title = title
        self.content = content()
        self.accessory = accessory()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.brandCaption)
                    .foregroundStyle(BrandColors.onSecondary)
                Spacer(minLength: 0)
                accessory
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(.horizontal, 16)
        .accessibilityElement(children: .combine)
    }
}

extension StripFigure where Accessory == EmptyView {
    public init(title: String, @ViewBuilder content: () -> Content) {
        self.init(title: title, content: content, accessory: { EmptyView() })
    }
}

/// a figure's value: Outfit 24 bold, mono digits, one line that shrinks to 70 % before it cuts.
public struct FigureValue: View {
    let text: String
    let color: Color

    public init(_ text: String, color: Color = BrandColors.on) {
        self.text = text
        self.color = color
    }

    public var body: some View {
        Text(verbatim: text)
            .font(.outfit(24, weight: .bold))
            .monospacedDigit()
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }
}

/// the line under a figure's value, cut at the end with the whole of it on hover.
public struct FigureCaption: View {
    let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(.brandCaption)
            .monospacedDigit()
            .foregroundStyle(BrandColors.onSecondary)
            .lineLimit(1)
            .truncationMode(.tail)
            .help(text)
    }
}
