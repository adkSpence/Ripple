//
//  BottleSetupControllerTests.swift
//  RippleTests
//

import SwiftData
import Testing
@testable import Ripple

@MainActor
struct BottleSetupControllerTests {
    @Test
    func creatingFirstBottlePersistsUserBottleAndOwnership() throws {
        let container = try makeTestContainer()
        let controller = BottleSetupController(
            modelContext: container.mainContext
        )

        let bottle = try controller.createFirstBottle(
            userName: "  Astro  ",
            bottleName: "  Gym Bottle  ",
            capacityML: 750
        )

        let verificationContext = ModelContext(container)
        let persistedUsers = try verificationContext.fetch(FetchDescriptor<User>())
        let persistedBottles = try verificationContext.fetch(FetchDescriptor<Bottle>())

        #expect(bottle.name == "Gym Bottle")
        #expect(bottle.owner.name == "Astro")
        #expect(persistedUsers.count == 1)
        #expect(persistedBottles.count == 1)
        #expect(persistedBottles.first?.capacityML == 750)
        #expect(persistedBottles.first?.owner.id == persistedUsers.first?.id)
    }

    @Test
    func emptyUserNameIsRejectedWithoutSavingAnything() throws {
        let container = try makeTestContainer()
        let controller = BottleSetupController(
            modelContext: container.mainContext
        )

        #expect(throws: BottleSetupError.emptyUserName) {
            try controller.createFirstBottle(
                userName: "   ",
                bottleName: "Gym Bottle",
                capacityML: 750
            )
        }

        #expect(try container.mainContext.fetch(FetchDescriptor<User>()).isEmpty)
        #expect(try container.mainContext.fetch(FetchDescriptor<Bottle>()).isEmpty)
    }

    @Test
    func emptyBottleNameIsRejectedWithoutSavingAnything() throws {
        let container = try makeTestContainer()
        let controller = BottleSetupController(
            modelContext: container.mainContext
        )

        #expect(throws: BottleSetupError.emptyBottleName) {
            try controller.createFirstBottle(
                userName: "Astro",
                bottleName: "\n",
                capacityML: 750
            )
        }

        #expect(try container.mainContext.fetch(FetchDescriptor<User>()).isEmpty)
        #expect(try container.mainContext.fetch(FetchDescriptor<Bottle>()).isEmpty)
    }

    @Test(arguments: [0, -1])
    func nonPositiveCapacityIsRejectedWithoutSavingAnything(
        capacityML: Int
    ) throws {
        let container = try makeTestContainer()
        let controller = BottleSetupController(
            modelContext: container.mainContext
        )

        #expect(throws: BottleSetupError.invalidCapacity) {
            try controller.createFirstBottle(
                userName: "Astro",
                bottleName: "Gym Bottle",
                capacityML: capacityML
            )
        }

        #expect(try container.mainContext.fetch(FetchDescriptor<User>()).isEmpty)
        #expect(try container.mainContext.fetch(FetchDescriptor<Bottle>()).isEmpty)
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
