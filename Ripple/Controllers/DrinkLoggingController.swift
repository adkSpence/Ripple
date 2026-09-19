//
//  DrinkLoggingController.swift
//  Ripple
//

import Foundation
import SwiftData

enum DrinkLoggingError: LocalizedError, Equatable {
    case invalidBottleCapacity
    case bottleNotFound

    var errorDescription: String? {
        switch self {
        case .invalidBottleCapacity:
            "Bottle capacity must be greater than zero."
        case .bottleNotFound:
            "This tag is not linked to a bottle in Ripple."
        }
    }
}

@MainActor
final class DrinkLoggingController {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    @discardableResult
    func logFullBottle(
        _ bottle: Bottle,
        at timestamp: Date = Date()
    ) throws -> DrinkEntry {
        guard bottle.capacityML > 0 else {
            throw DrinkLoggingError.invalidBottleCapacity
        }

        let entry = DrinkEntry(
            bottle: bottle,
            amountML: bottle.capacityML,
            timestamp: timestamp
        )

        modelContext.insert(entry)
        try modelContext.save()

        return entry
    }

    @discardableResult
    func logFullBottle(
        withID bottleID: UUID,
        at timestamp: Date = Date()
    ) throws -> DrinkEntry {
        let descriptor = FetchDescriptor<Bottle>(
            predicate: #Predicate { $0.id == bottleID }
        )

        guard let bottle = try modelContext.fetch(descriptor).first else {
            throw DrinkLoggingError.bottleNotFound
        }

        return try logFullBottle(bottle, at: timestamp)
    }
}
