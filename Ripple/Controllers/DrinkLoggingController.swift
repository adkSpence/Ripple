//
//  DrinkLoggingController.swift
//  Ripple
//

import Foundation
import SwiftData

enum DrinkLoggingError: LocalizedError, Equatable {
    case invalidBottleCapacity

    var errorDescription: String? {
        switch self {
        case .invalidBottleCapacity:
            "Bottle capacity must be greater than zero."
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
}
