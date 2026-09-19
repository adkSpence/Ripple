import Foundation

struct DailyHydrationStatus: Identifiable, Equatable {
    var id: Date { date }
    let date: Date
    let amountML: Int
    let isComplete: Bool
}

struct HydrationProgress: Equatable {
    let amountTodayML: Int
    let goalML: Int
    let streak: Int
    let recentDays: [DailyHydrationStatus]

    var remainingML: Int { max(goalML - amountTodayML, 0) }
    var fractionComplete: Double {
        guard goalML > 0 else { return 0 }
        return min(Double(amountTodayML) / Double(goalML), 1)
    }
    var isComplete: Bool { amountTodayML >= goalML }

    static func calculate(
        entries: [DrinkEntry],
        goalML: Int,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> HydrationProgress {
        let today = calendar.startOfDay(for: now)
        let totals = Dictionary(grouping: entries) {
            calendar.startOfDay(for: $0.timestamp)
        }.mapValues { $0.reduce(0) { $0 + $1.amountML } }

        let recentDays = (0..<7).reversed().compactMap { offset -> DailyHydrationStatus? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let amount = totals[date, default: 0]
            return DailyHydrationStatus(date: date, amountML: amount, isComplete: amount >= goalML)
        }

        var streak = 0
        var cursor = today
        if totals[cursor, default: 0] < goalML,
           let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor) {
            cursor = yesterday
        }
        while totals[cursor, default: 0] >= goalML {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }

        return HydrationProgress(
            amountTodayML: totals[today, default: 0],
            goalML: goalML,
            streak: streak,
            recentDays: recentDays
        )
    }
}
