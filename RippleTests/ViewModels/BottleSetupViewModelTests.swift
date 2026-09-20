//
//  BottleSetupViewModelTests.swift
//  RippleTests
//

import SwiftData
import Testing
@testable import Ripple

@MainActor
struct BottleSetupViewModelTests {
    @Test
    func validFormCreatesBottleAndClearsError() throws {
        let container = try makeTestContainer()
        let viewModel = makeViewModel(container: container)
        viewModel.userName = "Astro"
        viewModel.bottleName = "Desk Bottle"
        viewModel.capacityText = "500"

        let bottle = viewModel.save()

        #expect(bottle?.capacityML == 500)
        #expect(viewModel.errorMessage == nil)
    }

    @Test(arguments: ["", "750.5", "large"])
    func nonIntegerCapacityShowsValidationError(capacityText: String) throws {
        let container = try makeTestContainer()
        let viewModel = makeViewModel(container: container)
        viewModel.userName = "Astro"
        viewModel.bottleName = "Desk Bottle"
        viewModel.capacityText = capacityText

        let bottle = viewModel.save()

        #expect(bottle == nil)
        #expect(viewModel.errorMessage == "Capacity must be a positive whole number.")
    }

    private func makeViewModel(container: ModelContainer) -> BottleSetupViewModel {
        BottleSetupViewModel(
            bottleSetupController: BottleSetupController(
                modelContext: container.mainContext
            )
        )
    }

    private func makeTestContainer() throws -> ModelContainer {
        let schema = Schema([
            User.self,
            Bottle.self,
            DrinkEntry.self,
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }
}
