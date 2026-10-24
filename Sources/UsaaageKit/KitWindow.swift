// one usage window as the views draw it: a plain value each app fills from its own model.

import Foundation

/// one window of one account: `5 h`, `week`, `Fable week`, a month pool.
public struct KitWindow: Hashable, Sendable, Identifiable {
    /// a stable key for lists, the wire name of the kind (`5h`, `7d`, `model_week:Fable`).
    public var id: String
    /// what the meter says before the bar: `5 h`, `week`, `Fable week`.
    public var kindLabel: String
    /// 0 to 100; nil when the window is not known.
    public var usedPct: Double?
    /// when it resets, if known.
    public var resetsAt: KitEpoch?
    /// at or past it the bar turns full white and a hairline tick marks it; nil for none.
    public var threshold: Double?
    /// the reading is older than it should be: the bar is drawn at half.
    public var stale: Bool
    /// at the current pace the window reaches 100 % then (usaaage's pace), before it resets.
    public var runsOutAt: KitEpoch?
    /// what an even use would have spent by now (usaaage's pace), 0 to 100; the used percent
    /// against it says ahead or behind.
    public var expectedPct: Double?

    public init(
        id: String? = nil,
        kindLabel: String,
        usedPct: Double?,
        resetsAt: KitEpoch? = nil,
        threshold: Double? = nil,
        stale: Bool = false,
        runsOutAt: KitEpoch? = nil,
        expectedPct: Double? = nil
    ) {
        self.id = id ?? kindLabel
        self.kindLabel = kindLabel
        self.usedPct = usedPct
        self.resetsAt = resetsAt
        self.threshold = threshold
        self.stale = stale
        self.runsOutAt = runsOutAt
        self.expectedPct = expectedPct
    }

    /// how far the use is from an even one, in points: above zero ahead (spending faster), below
    /// behind. nil without an expected share.
    public var paceDelta: Double? {
        guard let usedPct, let expectedPct else { return nil }
        return usedPct - expectedPct
    }

    /// at or past its threshold.
    public var isPastThreshold: Bool {
        guard let usedPct, let threshold else { return false }
        return usedPct >= threshold
    }

    /// when the window runs out at the current pace, if that is still ahead and before its reset.
    public func runsOut(now: KitEpoch) -> KitEpoch? {
        guard let at = runsOutAt, at > now else { return nil }
        if let reset = resetsAt, at >= reset { return nil }
        return at
    }

    /// the index of the most constrained window: the highest share used. nil when none is known.
    public static func mostConstrained(_ windows: [KitWindow]) -> Int? {
        var best: Int?
        for (i, w) in windows.enumerated() {
            guard let used = w.usedPct else { continue }
            if let b = best, let top = windows[b].usedPct, top >= used { continue }
            best = i
        }
        return best
    }
}
