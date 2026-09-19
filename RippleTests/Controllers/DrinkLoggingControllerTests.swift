//
//  DrinkLoggingControllerTests.swift
//  RippleTests
//

import Foundation
import SwiftData
import Testing
@testable import Ripple

@MainActor
struct DrinkLoggingControllerTests {
    @Test func loggingByBottleIdentifierFindsAndPersistsTheBottle() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        let user = User(name: "Astro")
        let bottle = Bottle(name: "Daily Bottle", capacityML: 750, owner: user)
        context.insert(user)
        context.insert(bottle)
        try context.save()

        let controller = DrinkLoggingController(modelContext: context)
        let entry = try controller.logFullBottle(withID: bottle.id)

        #expect(entry.bottle.id == bottle.id)
        #expect(entry.amountML == 750)
    }

    @Test func unknownBottleIdentifierIsRejected() throws {
        let container = try makeTestContainer()
        let controller = DrinkLoggingController(
            modelContext: container.mainContext
        )

        #expect(throws: DrinkLoggingError.bottleNotFound) {
            try controller.logFullBottle(withID: UUID())
        }
    }
    @Test
    func loggingAFullBottlePersistsItsCapacityAndRelationships() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        let user = User(name: "Astro")
        let bottle = Bottle(
            name: "Gym Bottle",
            capacityML: 750,
            owner: user
        )
        let timestamp = Date(timeIntervalSince1970: 1_789_800_000)

        context.insert(user)
        context.insert(bottle)

        let controller = DrinkLoggingController(modelContext: context)
        let entry = try controller.logFullBottle(bottle, at: timestamp)
        let persistedEntries = try context.fetch(FetchDescriptor<DrinkEntry>())

        #expect(entry.amountML == 750)
        #expect(entry.timestamp == timestamp)
        #expect(entry.bottle === bottle)
        #expect(entry.bottle.owner === user)
        #expect(persistedEntries.count == 1)
        #expect(persistedEntries.first?.id == entry.id)
    }

    @Test
    func changingBottleCapacityDoesNotRewriteDrinkHistory() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        let user = User(name: "Astro")
        let bottle = Bottle(
            name: "Work Bottle",
            capacityML: 750,
            owner: user
        )

        context.insert(user)
        context.insert(bottle)

        let controller = DrinkLoggingController(modelContext: context)
        let entry = try controller.logFullBottle(bottle)

        bottle.capacityML = 1_000
        try context.save()

        #expect(entry.amountML == 750)
        #expect(entry.bottle.capacityML == 1_000)
    }

    @Test
    func nonPositiveBottleCapacityIsRejected() throws {
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

        let controller = DrinkLoggingController(modelContext: context)

        #expect(throws: DrinkLoggingError.invalidBottleCapacity) {
            try controller.logFullBottle(bottle)
        }

        let persistedEntries = try context.fetch(FetchDescriptor<DrinkEntry>())
        #expect(persistedEntries.isEmpty)
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
