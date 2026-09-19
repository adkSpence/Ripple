import Foundation
import SwiftData

enum HydrationGoalError: LocalizedError, Equatable {
    case invalidGoal

    var errorDescription: String? {
        "Enter a positive whole-number goal in millilitres."
    }
}

@MainActor
final class HydrationGoalController {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func updateGoal(for user: User, dailyGoalML: Int) throws {
        guard dailyGoalML > 0 else { throw HydrationGoalError.invalidGoal }
        user.dailyGoalML = dailyGoalML
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
    }
}
