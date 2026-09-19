//
//  BottleTagController.swift
//  Ripple
//

import SwiftData

@MainActor
final class BottleTagController {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func markTagConnected(to bottle: Bottle) throws {
        bottle.isTagConnected = true

        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
    }
}
