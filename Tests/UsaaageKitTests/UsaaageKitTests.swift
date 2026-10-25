// the formats, the window logic and a small snapshot of the menu bar glyphs and the gallery.
// with UKIT_SNAPSHOT_DIR set, the snapshots are also written there as png files to look at.

import AppKit
import LaaabsKit
import SwiftUI
import Testing
@testable import UsaaageKit

@Suite struct FormatTests {
    @Test func percent() {
        #expect(KitFormat.percent(82) == "82 %")
        #expect(KitFormat.percent(41.5) == "42 %")
        #expect(KitFormat.percent(3.25) == "3.2 %")
        #expect(KitFormat.percent(0) == "0 %")
        #expect(KitFormat.percent(140) == "100 %")
        #expect(KitFormat.percent(-3) == "0 %")
    }

    @Test func money() {
        #expect(KitFormat.money(0) == "$0")
        #expect(KitFormat.money(0.004) == "< $0.01")
        #expect(KitFormat.money(4.2) == "$4.20")
        #expect(KitFormat.money(318.4) == "$318")
        #expect(KitFormat.money(12_480.3) == "$12,480")
        #expect(KitFormat.money(-88.8) == "-$88.80")
    }

    @Test func tokens() {
        #expect(KitFormat.tokens(640) == "640")
        #expect(KitFormat.tokens(4_100) == "4.1k")
        #expect(KitFormat.tokens(4_000) == "4k")
        #expect(KitFormat.tokens(999_499) == "999k")
        #expect(KitFormat.tokens(999_500) == "1M")
        #expect(KitFormat.tokens(9_800_000) == "9.8M")
        #expect(KitFormat.tokens(1_234_000_000) == "1.2B")
    }

    @Test func durationsAndCountdowns() {
        let now: KitEpoch = 1_792_022_400
        #expect(KitFormat.duration(20) == "< 1 min")
        #expect(KitFormat.duration(2 * 3600 + 10 * 60 + 59) == "2 h 10 min")
        #expect(KitFormat.duration(3 * 86_400 + 4 * 3600 + 30 * 60) == "3 d 4 h")
        #expect(KitFormat.countdown(to: now + 6000, now: now) == "in 1 h 40 min")
        #expect(KitFormat.countdown(to: now - 1, now: now) == "reset")
        #expect(KitFormat.countdown(to: nil, now: now) == nil)
        #expect(KitFormat.ago(now - 30, now: now) == "just now")
        #expect(KitFormat.ago(now - 180, now: now) == "3 min ago")
    }

    @Test func runsOutAt() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let now: KitEpoch = 1_792_065_600
        #expect(KitFormat.runsOut(now + 5 * 3600 + 40 * 60, now: now, calendar: calendar) == "runs out at 17:40")
        #expect(KitFormat.clock(now + 21 * 3600 + 10 * 60, now: now, calendar: calendar) == "fri 09:10")
    }

    @Test func planNames() {
        #expect(KitFormat.planName("max_20x") == "Max 20x")
        #expect(KitFormat.planName("plus") == "Plus")
        #expect(KitFormat.planName(" ") == nil)
    }
}

@Suite struct WindowTests {
    @Test func theMostConstrainedIsTheHighestKnownShare() {
        let a = KitWindow(kindLabel: "5 h", usedPct: 40)
        let b = KitWindow(kindLabel: "week", usedPct: 71)
        let c = KitWindow(kindLabel: "Fable week", usedPct: nil)
        #expect(KitWindow.mostConstrained([a, b, c]) == 1)
        #expect(KitWindow.mostConstrained([c]) == nil)
        #expect(KitWindow.mostConstrained([]) == nil)
    }

    @Test func thePaceWarnsOnlyBeforeTheReset() {
        let now: KitEpoch = 1000
        #expect(KitWindow(kindLabel: "5 h", usedPct: 50, resetsAt: 5000, runsOutAt: 3000).runsOut(now: now) == 3000)
        #expect(KitWindow(kindLabel: "5 h", usedPct: 50, resetsAt: 2000, runsOutAt: 3000).runsOut(now: now) == nil)
        #expect(KitWindow(kindLabel: "5 h", usedPct: 50, runsOutAt: 900).runsOut(now: now) == nil)
        #expect(KitWindow(kindLabel: "5 h", usedPct: 80, threshold: 80).isPastThreshold)
    }
}

@Suite struct GlyphSnapshotTests {
    /// the alpha of one pixel, in points from the bottom left.
    private func alpha(_ image: CGImage, scale: CGFloat, x: CGFloat, y: CGFloat) -> UInt8 {
        let data = image.dataProvider!.data! as Data
        let px = Int(x * scale)
        let py = image.height - 1 - Int(y * scale)
        return data[py * image.bytesPerRow + px * 4 + 3]
    }

    @Test func bothVariantsShareSizeAndAreTemplates() throws {
        for glyph in KitGallery.glyphs {
            let image = glyph.image()
            #expect(image.isTemplate)
            #expect(image.size == MenuBarGlyph.size)
            for scale in [1.0, 2.0] {
                let cg = try #require(glyph.cgImage(scale: scale))
                #expect(cg.width == Int(18 * scale))
                #expect(cg.height == Int(16 * scale))
            }
        }
    }

    @Test func theMostConstrainedBarIsAtFullInk() throws {
        // 5 h at 62 % (quiet), week at 84 % (the tightest): the left end of both bars is filled.
        let glyph = MenuBarGlyph.usage([KitSamples.fiveHour, KitSamples.week])
        let cg = try #require(glyph.cgImage(scale: 2))
        let top = alpha(cg, scale: 2, x: 4, y: 11.5)
        let bottom = alpha(cg, scale: 2, x: 4, y: 5.5)
        #expect(bottom == 255)
        #expect(top < bottom)
        #expect(top > 100)
        // the unused end of the top bar is only the track.
        #expect(alpha(cg, scale: 2, x: 16, y: 11.5) < top)
    }

    @Test func theSwitchingGlyphHasOneBarAndTheMark() throws {
        let glyph = MenuBarGlyph.switching(level: 62, active: true)
        let cg = try #require(glyph.cgImage(scale: 2))
        #expect(alpha(cg, scale: 2, x: 4, y: 4.5) == 255) // the bar
        #expect(alpha(cg, scale: 2, x: 9, y: 13) > 200) // the upper arrow
        #expect(alpha(cg, scale: 2, x: 9, y: 9) > 200) // the lower arrow
        #expect(alpha(cg, scale: 2, x: 9, y: 11) == 0) // between them
        let quiet = try #require(MenuBarGlyph.switching(level: 62, active: false).cgImage(scale: 2))
        #expect(alpha(quiet, scale: 2, x: 9, y: 13) < 200)
    }

    @Test func dimmedIsLighter() throws {
        let glyph = MenuBarGlyph.switching(level: 100, active: true)
        let full = try #require(glyph.cgImage(scale: 1))
        let dim = try #require(glyph.cgImage(scale: 1, dimmed: true))
        #expect(alpha(dim, scale: 1, x: 9, y: 4) < alpha(full, scale: 1, x: 9, y: 4))
    }

    @MainActor @Test func theGalleryRenders() throws {
        BrandFonts.register()
        let renderer = ImageRenderer(content: KitGallery())
        renderer.scale = 2
        let image = try #require(renderer.cgImage)
        #expect(image.width == 1520)
        try write(image, "gallery.png")
        try write(sideBySide(), "menubar-glyphs.png")
    }

    /// both variants on a light and a dark menu bar, at 1x and at 2x, magnified 8x so the pixels show.
    private func sideBySide() throws -> CGImage {
        let glyphs = KitGallery.glyphs
        let cell = 18 * 8 + 24
        let width = cell * glyphs.count * 2
        let height = (16 * 8 + 24) * 2
        let ctx = try #require(CGContext(
            data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ))
        ctx.interpolationQuality = .none
        for (row, dark) in [false, true].enumerated() {
            let y = (1 - row) * (16 * 8 + 24)
            ctx.setFillColor(dark ? CGColor(gray: 0.12, alpha: 1) : CGColor(gray: 0.93, alpha: 1))
            ctx.fill(CGRect(x: 0, y: y, width: width, height: 16 * 8 + 24))
            for (scaleIndex, scale) in [1.0, 2.0].enumerated() {
                for (i, glyph) in glyphs.enumerated() {
                    let image = try #require(glyph.cgImage(scale: scale, ink: dark ? .white : .black))
                    let x = (scaleIndex * glyphs.count + i) * cell + 12
                    ctx.draw(image, in: CGRect(x: x, y: y + 12, width: 18 * 8, height: 16 * 8))
                }
            }
        }
        return try #require(ctx.makeImage())
    }

    private func write(_ image: CGImage, _ name: String) throws {
        guard let dir = ProcessInfo.processInfo.environment["UKIT_SNAPSHOT_DIR"] else { return }
        let rep = NSBitmapImageRep(cgImage: image)
        let data = try #require(rep.representation(using: .png, properties: [:]))
        try data.write(to: URL(fileURLWithPath: dir).appendingPathComponent(name))
    }
}

@Suite struct NoticeTests {
    @Test func theBellCountsTheUnseenUpToNine() {
        #expect(NoticeBell.badge(unseen: 0) == nil)
        #expect(NoticeBell.badge(unseen: 3) == "3")
        #expect(NoticeBell.badge(unseen: 9) == "9")
        #expect(NoticeBell.badge(unseen: 10) == "9+")
    }

    @Test func theBellSaysHowManyAreNew() {
        #expect(NoticeBell.accessibilityLabel(unseen: 0) == "notices")
        #expect(NoticeBell.accessibilityLabel(unseen: 2) == "notices, 2 new")
    }

    @Test @MainActor func theLineShowsTheBodyOnHover() {
        #expect(NoticeLine.help(title: "work is at 95 %", message: "it resets at 14:00") == "work is at 95 %\nit resets at 14:00")
        #expect(NoticeLine.help(title: "work is at 95 %", message: nil) == "work is at 95 %")
    }
}
