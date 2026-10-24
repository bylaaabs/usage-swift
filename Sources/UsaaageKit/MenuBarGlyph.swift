// the menu bar glyph of the usage apps, one family in two variants:
//
// - `.usage(windows)` (usaaage): the detailed meter, two or three thin bars (5 h, week and a third
//   window when there is one), the most constrained one at full ink, the others lighter.
// - `.switching(level:active:)` (swaaap): the same meter simplified to one bar, with a small switch
//   mark above it (two short opposed arrows).
//
// both are 18 x 16 pt template images with 3 pt bars, radius 1.5, the track at 30 % of the ink: the
// same weight and size, so they read as siblings. dimmed (40 %) when stale or the daemon is down.

import AppKit

public enum MenuBarGlyph: Hashable, Sendable {
    /// the detailed meter: one bar per window, in order, top to bottom; two or three are drawn
    /// (fewer are padded with unknown bars, more are cut). the most constrained is at full ink.
    case usage([KitWindow])
    /// the simplified meter: one bar for `level` (0 to 100, nil when unknown) and the switch mark,
    /// at full ink when `active` (a run is using an account), lighter when not.
    case switching(level: Double?, active: Bool)

    /// the size of every variant, in points.
    public static let size = NSSize(width: 18, height: 16)
    /// the thickness of every bar, in points.
    public static let barHeight: CGFloat = 3
    /// the line of the switch mark, in points.
    public static let markLine: CGFloat = 1.5

    static let trackAlpha: CGFloat = 0.3
    static let quietAlpha: CGFloat = 0.55
    static let dimmedAlpha: CGFloat = 0.4

    /// the glyph as a template image for an `NSStatusItem`: macOS gives it the menu bar's ink.
    public func image(dimmed: Bool = false) -> NSImage {
        let glyph = self
        let image = NSImage(size: Self.size, flipped: false) { _ in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
            glyph.draw(in: ctx, ink: NSColor.black.cgColor, dimmed: dimmed)
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = accessibilityDescription
        return image
    }

    /// the glyph drawn in `ink` at `scale` (1 for 1x, 2 for retina), for snapshots and previews.
    public func cgImage(scale: CGFloat, ink: NSColor = .black, dimmed: Bool = false) -> CGImage? {
        let width = Int(Self.size.width * scale)
        let height = Int(Self.size.height * scale)
        guard let ctx = CGContext(
            data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        ctx.scaleBy(x: scale, y: scale)
        draw(in: ctx, ink: ink.cgColor, dimmed: dimmed)
        return ctx.makeImage()
    }

    /// what VoiceOver says for the glyph alone; the item's title and tooltip say more.
    public var accessibilityDescription: String {
        switch self {
        case let .usage(windows):
            guard let i = KitWindow.mostConstrained(windows), let used = windows[i].usedPct else {
                return String(localized: "usage unknown")
            }
            return String(localized: "\(windows[i].kindLabel) \(KitFormat.percent(used)) used")
        case let .switching(level, _):
            return level.map { String(localized: "\(KitFormat.percent($0)) used") } ?? String(localized: "usage unknown")
        }
    }

    // MARK: - drawing (points, origin at the bottom left)

    func draw(in ctx: CGContext, ink: CGColor, dimmed: Bool) {
        let alpha: CGFloat = dimmed ? Self.dimmedAlpha : 1
        switch self {
        case let .usage(windows):
            let shown = Array(windows.prefix(3)) + Array(repeating: KitWindow(kindLabel: "", usedPct: nil), count: max(0, 2 - windows.count))
            let top = KitWindow.mostConstrained(shown)
            let rows = Self.barRows(count: shown.count)
            for (i, window) in shown.enumerated() {
                let fill = (top == nil || top == i) ? 1 : Self.quietAlpha
                drawBar(ctx, ink: ink, y: rows[i], value: window.usedPct, fillAlpha: fill * alpha, trackAlpha: Self.trackAlpha * alpha)
            }
        case let .switching(level, active):
            drawBar(ctx, ink: ink, y: Self.switchBarY, value: level, fillAlpha: alpha, trackAlpha: Self.trackAlpha * alpha)
            drawSwitchMark(ctx, ink: ink, alpha: (active ? 1 : Self.quietAlpha) * alpha)
        }
    }

    /// the bottom edge of each bar, top bar first, on whole points so they stay crisp at 1x.
    static func barRows(count: Int) -> [CGFloat] {
        count >= 3 ? [12, 7, 2] : [10, 4]
    }

    /// the one bar of the switching glyph sits low, with the switch mark over it.
    static let switchBarY: CGFloat = 3

    private func drawBar(_ ctx: CGContext, ink: CGColor, y: CGFloat, value: Double?, fillAlpha: CGFloat, trackAlpha: CGFloat) {
        let h = Self.barHeight
        let x: CGFloat = 1
        let width = Self.size.width - 2
        ctx.setFillColor(ink.copy(alpha: trackAlpha) ?? ink)
        ctx.addPath(CGPath(roundedRect: CGRect(x: x, y: y, width: width, height: h), cornerWidth: h / 2, cornerHeight: h / 2, transform: nil))
        ctx.fillPath()
        guard let value else { return }
        let share = CGFloat(min(max(value, 0), 100) / 100)
        guard share > 0 else { return }
        // the fill is drawn over a cleared track, so the ink never adds up past its own alpha.
        let rect = CGRect(x: x, y: y, width: max(width * share, h), height: h)
        let path = CGPath(roundedRect: rect, cornerWidth: h / 2, cornerHeight: h / 2, transform: nil)
        ctx.saveGState()
        ctx.setBlendMode(.clear)
        ctx.addPath(path)
        ctx.fillPath()
        ctx.restoreGState()
        ctx.setFillColor(ink.copy(alpha: fillAlpha) ?? ink)
        ctx.addPath(path)
        ctx.fillPath()
    }

    /// two short opposed arrows over the bar: one to the right on top, one to the left under it.
    private func drawSwitchMark(_ ctx: CGContext, ink: CGColor, alpha: CGFloat) {
        let line = Self.markLine
        let head: CGFloat = 2
        let left: CGFloat = 4
        let right: CGFloat = 14
        let upper: CGFloat = 13
        let lower: CGFloat = 9
        let path = CGMutablePath()
        // top: to the right.
        path.move(to: CGPoint(x: left, y: upper))
        path.addLine(to: CGPoint(x: right, y: upper))
        path.move(to: CGPoint(x: right - head, y: upper + head))
        path.addLine(to: CGPoint(x: right, y: upper))
        path.addLine(to: CGPoint(x: right - head, y: upper - head))
        // bottom: to the left.
        path.move(to: CGPoint(x: right, y: lower))
        path.addLine(to: CGPoint(x: left, y: lower))
        path.move(to: CGPoint(x: left + head, y: lower + head))
        path.addLine(to: CGPoint(x: left, y: lower))
        path.addLine(to: CGPoint(x: left + head, y: lower - head))
        ctx.saveGState()
        ctx.setStrokeColor(ink.copy(alpha: alpha) ?? ink)
        ctx.setLineWidth(line)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        ctx.addPath(path)
        ctx.strokePath()
        ctx.restoreGState()
    }
}
