// numbers as the usage apps write them: numerals with si spacing (`90 %`, `5 h`, `2 h 10 min`),
// money in us dollars, tokens with k and M, countdowns computed at draw time from utc epoch seconds.

import Foundation

/// seconds since 1970, utc: what both daemons send.
public typealias KitEpoch = Int64

extension KitEpoch {
    /// the epoch as a `Date`.
    public var kitDate: Date { Date(timeIntervalSince1970: TimeInterval(self)) }
}

/// the formats both apps share.
public enum KitFormat {
    /// `42 %`; fractions only below 10.
    public static func percent(_ value: Double) -> String {
        "\(percentNumber(value)) %"
    }

    /// the number of a percentage, without the sign: `42`, `4.5`.
    public static func percentNumber(_ value: Double) -> String {
        let clamped = min(max(value, 0), 100)
        if clamped > 0, clamped < 10, clamped.rounded() != clamped {
            return String(format: "%.1f", clamped)
        }
        return "\(Int(clamped.rounded()))"
    }

    /// a duration, two units at most: `3 d 4 h`, `2 h 10 min`, `12 min`, `< 1 min`.
    public static func duration(_ seconds: Int64) -> String {
        let s = max(seconds, 0)
        if s < 60 { return String(localized: "< 1 min") }
        let minutes = s / 60
        let days = minutes / (24 * 60)
        let hours = (minutes % (24 * 60)) / 60
        let mins = minutes % 60
        if days > 0 {
            return hours > 0 ? "\(days) d \(hours) h" : "\(days) d"
        }
        if hours > 0 {
            return mins > 0 ? "\(hours) h \(mins) min" : "\(hours) h"
        }
        return "\(mins) min"
    }

    /// the countdown to a reset: `in 2 h 10 min`, or `reset` once it passed. nil without a time.
    public static func countdown(to resetsAt: KitEpoch?, now: KitEpoch) -> String? {
        guard let resetsAt else { return nil }
        let left = resetsAt - now
        if left <= 0 { return String(localized: "reset") }
        return String(localized: "in \(duration(left))")
    }

    /// how long ago: `3 min ago`, `just now`.
    public static func ago(_ at: KitEpoch, now: KitEpoch) -> String {
        let delta = now - at
        if delta < 60 { return String(localized: "just now") }
        return String(localized: "\(duration(delta)) ago")
    }

    /// a time of day in 24 h: `17:40` today, `thu 09:10` another day.
    public static func clock(_ at: KitEpoch, now: KitEpoch, calendar: Calendar = .current) -> String {
        let date = at.kitDate
        let time = DateFormatter()
        time.calendar = calendar
        time.timeZone = calendar.timeZone
        time.locale = Locale(identifier: "en_US_POSIX")
        time.dateFormat = calendar.isDate(date, inSameDayAs: now.kitDate) ? "HH:mm" : "EEE HH:mm"
        return time.string(from: date).lowercased()
    }

    /// the pace warning: `runs out at 17:40`.
    public static func runsOut(_ at: KitEpoch, now: KitEpoch, calendar: Calendar = .current) -> String {
        String(localized: "runs out at \(clock(at, now: now, calendar: calendar))")
    }

    /// us dollars: `$0`, `< $0.01`, `$4.20`, `$318`, `$12,480`.
    public static func money(_ usd: Double) -> String {
        if usd.isNaN { return "-" }
        let negative = usd < 0
        let value = abs(usd)
        let text: String
        if value == 0 {
            text = "$0"
        } else if value < 0.01 {
            text = "< $0.01"
        } else if value < 100 {
            text = "$" + String(format: "%.2f", value)
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 0
            formatter.locale = Locale(identifier: "en_US")
            text = "$" + (formatter.string(from: NSNumber(value: value.rounded())) ?? "\(Int(value.rounded()))")
        }
        return negative ? "-" + text : text
    }

    /// a token count: `640`, `4.1k`, `182k`, `9.8M`, `210M`, `1.2B`.
    public static func tokens(_ count: UInt64) -> String {
        let n = Double(count)
        func scaled(_ unit: Double, _ suffix: String) -> String {
            let v = n / unit
            guard v < 9.95 else { return "\(Int(v.rounded()))\(suffix)" }
            let one = (v * 10).rounded() / 10
            return one == one.rounded() ? "\(Int(one))\(suffix)" : String(format: "%.1f", one) + suffix
        }
        switch count {
        case ..<1000: return "\(count)"
        case ..<999_500: return scaled(1000, "k")
        case ..<999_500_000: return scaled(1_000_000, "M")
        default: return scaled(1_000_000_000, "B")
        }
    }

    /// a plan id or a client's plan as a person names it: `max_20x` is Max 20x, `plus` is Plus.
    public static func planName(_ raw: String?) -> String? {
        guard let raw = raw?.trimmingCharacters(in: .whitespaces), !raw.isEmpty else { return nil }
        let words = raw.replacingOccurrences(of: "_", with: " ").split(separator: " ")
        return words.enumerated().map { i, w in i == 0 ? w.prefix(1).uppercased() + w.dropFirst() : String(w) }.joined(separator: " ")
    }
}
