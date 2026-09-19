import SwiftData
import Testing
@testable import Ripple

@MainActor
struct HydrationGoalViewModelTests {
    @Test func validGoalIsPersisted() throws {
        let (container, user, viewModel) = try fixture()
        viewModel.goalText = "2500"
        #expect(viewModel.save(for: user))
        #expect(user.dailyGoalML == 2_500)
        let verificationContext = ModelContext(container)
        #expect(try verificationContext.fetch(FetchDescriptor<User>()).first?.dailyGoalML == 2_500)
    }

    @Test(arguments: ["", "0", "-100", "two litres"])
    func invalidGoalIsRejected(value: String) throws {
        let (container, user, viewModel) = try fixture()
        withExtendedLifetime(container) {
            viewModel.goalText = value
            #expect(!viewModel.save(for: user))
            #expect(user.dailyGoalML == 2_000)
            #expect(viewModel.errorMessage != nil)
        }
    }

    private func fixture() throws -> (ModelContainer, User, HydrationGoalViewModel) {
        let schema = Schema([User.self, Bottle.self, DrinkEntry.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext
        let user = User(name: "Astro")
        context.insert(user)
        return (
            container,
            user,
            HydrationGoalViewModel(controller: HydrationGoalController(modelContext: context))
        )
    }
}
