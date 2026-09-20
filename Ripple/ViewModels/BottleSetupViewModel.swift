//
//  BottleSetupViewModel.swift
//  Ripple
//

import Foundation
import Observation

@MainActor
@Observable
final class BottleSetupViewModel {
    var userName = ""
    var bottleName = ""
    var capacityText = ""

    private(set) var errorMessage: String?

    private let bottleSetupController: BottleSetupController

    init(bottleSetupController: BottleSetupController) {
        self.bottleSetupController = bottleSetupController
    }

    @discardableResult
    func save() -> Bottle? {
        guard let capacityML = Int(capacityText) else {
            errorMessage = BottleSetupError.invalidCapacity.localizedDescription
            return nil
        }

        do {
            let bottle = try bottleSetupController.createFirstBottle(
                userName: userName,
                bottleName: bottleName,
                capacityML: capacityML
            )
            errorMessage = nil
            return bottle
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
