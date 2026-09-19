import Foundation
import Observation

@MainActor
@Observable
final class HydrationGoalViewModel {
    var goalText = ""
    private(set) var errorMessage: String?
    @ObservationIgnored private let controller: HydrationGoalController

    init(controller: HydrationGoalController) {
        self.controller = controller
    }

    func prepare(currentGoalML: Int) {
        goalText = String(currentGoalML)
        errorMessage = nil
    }

    @discardableResult
    func save(for user: User) -> Bool {
        guard let goalML = Int(goalText) else {
            errorMessage = HydrationGoalError.invalidGoal.localizedDescription
            return false
        }
        do {
            try controller.updateGoal(for: user, dailyGoalML: goalML)
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
