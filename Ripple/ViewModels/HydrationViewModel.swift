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
            return entry
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
