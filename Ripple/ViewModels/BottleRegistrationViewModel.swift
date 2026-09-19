import Foundation
import Observation

enum BottleRegistrationMode: Equatable {
    case manual
    case nfc
}

@MainActor
@Observable
final class BottleRegistrationViewModel {
    var bottleName = ""
    var capacityText = ""
    private(set) var mode: BottleRegistrationMode = .manual
    private(set) var isDetecting = false
    private(set) var isSaving = false
    private(set) var isShowingForm = false
    private(set) var errorMessage: String?

    @ObservationIgnored private let detector: NFCBottleTagDetecting
    @ObservationIgnored private let writer: NFCBottleWriting
    @ObservationIgnored private let controller: BottleSetupController

    init(
        detector: NFCBottleTagDetecting,
        writer: NFCBottleWriting,
        controller: BottleSetupController
    ) {
        self.detector = detector
        self.writer = writer
        self.controller = controller
    }

    func startManualRegistration() {
        resetForm()
        mode = .manual
        isShowingForm = true
    }

    func startNFCRegistration() {
        errorMessage = nil
        isDetecting = true
        detector.detectWritableTag { [weak self] result in
            guard let self else { return }
            isDetecting = false
            switch result {
            case .success:
                resetForm()
                mode = .nfc
                isShowingForm = true
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }

    func dismissForm() {
        isShowingForm = false
        errorMessage = nil
    }

    func save() {
        let name = bottleName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            errorMessage = BottleSetupError.emptyBottleName.localizedDescription
            return
        }
        guard let capacity = Int(capacityText), capacity > 0 else {
            errorMessage = BottleSetupError.invalidCapacity.localizedDescription
            return
        }

        isSaving = true
        errorMessage = nil
        let bottleID = UUID()

        if mode == .manual {
            createBottle(id: bottleID, name: name, capacity: capacity)
        } else {
            writer.beginWrite(url: BottleTag(bottleID: bottleID).url) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success:
                    createBottle(id: bottleID, name: name, capacity: capacity)
                case .failure(let error):
                    isSaving = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func createBottle(id: UUID, name: String, capacity: Int) {
        do {
            _ = try controller.createFirstBottle(
                bottleID: id,
                userName: "You",
                bottleName: name,
                capacityML: capacity,
                isTagConnected: mode == .nfc
            )
            isSaving = false
            isShowingForm = false
        } catch {
            isSaving = false
            errorMessage = error.localizedDescription
        }
    }

    private func resetForm() {
        bottleName = ""
        capacityText = ""
        errorMessage = nil
    }
}
