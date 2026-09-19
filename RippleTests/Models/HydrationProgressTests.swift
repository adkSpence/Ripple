import Foundation
import Testing
@testable import Ripple

struct HydrationProgressTests {
    @Test func calculatesTodayProgressAndRemainingAmount() {
        let fixture = ProgressFixture()
        let entries = [
            DrinkEntry(bottle: fixture.bottle, amountML: 750, timestamp: fixture.today),
            DrinkEntry(bottle: fixture.bottle, amountML: 500, timestamp: fixture.today),
        ]
        let progress = fixture.progress(entries: entries)
        #expect(progress.amountTodayML == 1_250)
        #expect(progress.remainingML == 750)
        #expect(progress.fractionComplete == 0.625)
        #expect(!progress.isComplete)
    }

    @Test func streakIncludesTodayAfterGoalIsReached() {
        let fixture = ProgressFixture()
        let entries = (0...2).map {
            DrinkEntry(bottle: fixture.bottle, amountML: 2_000, timestamp: fixture.day(-$0))
        }
        #expect(fixture.progress(entries: entries).streak == 3)
    }

    @Test func incompleteTodayPreservesStreakThroughYesterday() {
        let fixture = ProgressFixture()
        let entries = [1, 2].map {
            DrinkEntry(bottle: fixture.bottle, amountML: 2_000, timestamp: fixture.day(-$0))
        }
        #expect(fixture.progress(entries: entries).streak == 2)
    }

    @Test func missingDayBreaksTheStreak() {
        let fixture = ProgressFixture()
        let entries = [1, 3].map {
            DrinkEntry(bottle: fixture.bottle, amountML: 2_000, timestamp: fixture.day(-$0))
        }
        #expect(fixture.progress(entries: entries).streak == 1)
    }
}

private struct ProgressFixture {
    var calendar: Calendar = {
        var value = Calendar(identifier: .gregorian)
        value.timeZone = TimeZone(secondsFromGMT: 0)!
        return value
    }()
    let bottle = Bottle(name: "Daily Bottle", capacityML: 750, owner: User(name: "Astro"))
    let today = Date(timeIntervalSince1970: 1_800_144_000)

    func day(_ offset: Int) -> Date {
        calendar.date(byAdding: .day, value: offset, to: today)!
    }
    func progress(entries: [DrinkEntry]) -> HydrationProgress {
        HydrationProgress.calculate(entries: entries, goalML: 2_000, now: today, calendar: calendar)
    }
}
