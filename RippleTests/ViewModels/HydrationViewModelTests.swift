//
//  HydrationViewModelTests.swift
//  RippleTests
//

import SwiftData
import Testing
@testable import Ripple

@MainActor
struct HydrationViewModelTests {
    @Test
    func successfulLogUpdatesViewModelState() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        let user = User(name: "Astro")
        let bottle = Bottle(
            name: "Home Bottle",
            capacityML: 500,
            owner: user
        )

        context.insert(user)
        context.insert(bottle)

        let viewModel = HydrationViewModel(
            drinkLoggingController: DrinkLoggingController(
                modelContext: context
            )
        )

        let entry = viewModel.logFullBottle(bottle)

        #expect(entry?.amountML == 500)
        #expect(viewModel.lastLoggedEntry === entry)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func failedLogPublishesAnErrorWithoutAnEntry() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        let user = User(name: "Astro")
        let bottle = Bottle(
            name: "Invalid Bottle",
            capacityML: 0,
            owner: user
        )

        context.insert(user)
        context.insert(bottle)

        let viewModel = HydrationViewModel(
            drinkLoggingController: DrinkLoggingController(
                modelContext: context
            )
        )

        let entry = viewModel.logFullBottle(bottle)

        #expect(entry == nil)
        #expect(viewModel.lastLoggedEntry == nil)
        #expect(viewModel.errorMessage == "Bottle capacity must be greater than zero.")
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
