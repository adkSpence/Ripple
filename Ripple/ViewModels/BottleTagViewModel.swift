//
//  BottleTagViewModel.swift
//  Ripple
//

import Foundation
import Observation

@MainActor
@Observable
final class BottleTagViewModel {
    private(set) var isWriting = false
    private(set) var confirmationMessage: String?
    private(set) var errorMessage: String?

    @ObservationIgnored private let writer: NFCBottleWriting
    @ObservationIgnored private let controller: BottleTagController

    init(
        writer: NFCBottleWriting,
        controller: BottleTagController
    ) {
        self.writer = writer
        self.controller = controller
    }

    func connectTag(to bottle: Bottle) {
        isWriting = true
        confirmationMessage = nil
        errorMessage = nil

        writer.beginWrite(url: BottleTag(bottleID: bottle.id).url) { [weak self] result in
            guard let self else { return }
            isWriting = false

            switch result {
            case .success:
                do {
                    try controller.markTagConnected(to: bottle)
                    confirmationMessage = "NFC tag connected to \(bottle.name)."
                } catch {
                    errorMessage = error.localizedDescription
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}
