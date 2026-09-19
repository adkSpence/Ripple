//
//  BottleSetupController.swift
//  Ripple
//

import Foundation
import SwiftData

enum BottleSetupError: LocalizedError, Equatable {
    case emptyUserName
    case emptyBottleName
    case invalidCapacity

    var errorDescription: String? {
        switch self {
        case .emptyUserName:
            "Enter your name."
        case .emptyBottleName:
            "Enter a name for your bottle."
        case .invalidCapacity:
            "Capacity must be a positive whole number."
        }
    }
}

@MainActor
final class BottleSetupController {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    @discardableResult
    func createFirstBottle(
        bottleID: UUID = UUID(),
        userName: String,
        bottleName: String,
        capacityML: Int,
        isTagConnected: Bool = false
    ) throws -> Bottle {
        let trimmedUserName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBottleName = bottleName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedUserName.isEmpty else {
            throw BottleSetupError.emptyUserName
        }

        guard !trimmedBottleName.isEmpty else {
            throw BottleSetupError.emptyBottleName
        }

        guard capacityML > 0 else {
            throw BottleSetupError.invalidCapacity
        }

        let user = User(name: trimmedUserName)
        let bottle = Bottle(
            id: bottleID,
            name: trimmedBottleName,
            capacityML: capacityML,
            owner: user,
            isTagConnected: isTagConnected
        )

        modelContext.insert(user)
        modelContext.insert(bottle)

        do {
            try modelContext.save()
            return bottle
        } catch {
            modelContext.rollback()
            throw error
        }
    }
}
