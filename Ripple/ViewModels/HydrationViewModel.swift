//
//  HydrationViewModel.swift
//  Ripple
//

import Foundation
import Observation

@MainActor
@Observable
final class HydrationViewModel {
    let title = "Ripple"

    private let drinkLoggingController: DrinkLoggingController

    private(set) var lastLoggedEntry: DrinkEntry?
    private(set) var errorMessage: String?
    private(set) var confirmationMessage: String?

    init(drinkLoggingController: DrinkLoggingController) {
        self.drinkLoggingController = drinkLoggingController
    }

    @discardableResult
    func logFullBottle(
        _ bottle: Bottle,
        at timestamp: Date = Date()
    ) -> DrinkEntry? {
        do {
            let entry = try drinkLoggingController.logFullBottle(
                bottle,
                at: timestamp
            )
            lastLoggedEntry = entry
            errorMessage = nil
            confirmationMessage = "Logged \(entry.amountML) ml from \(bottle.name)."
            return entry
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    @discardableResult
    func logScannedTag(
        url: URL,
        at timestamp: Date = Date()
    ) -> DrinkEntry? {
        do {
            let tag = try BottleTag(url: url)
            let entry = try drinkLoggingController.logFullBottle(
                withID: tag.bottleID,
                at: timestamp
            )
            lastLoggedEntry = entry
            errorMessage = nil
            confirmationMessage = "Logged \(entry.amountML) ml from \(entry.bottle.name)."
            return entry
        } catch {
            errorMessage = error.localizedDescription
            confirmationMessage = nil
            return nil
        }
    }

    func showScanError(_ error: Error) {
        errorMessage = error.localizedDescription
        confirmationMessage = nil
    }
}
