import Foundation
import SwiftData
import Testing
@testable import Ripple

@MainActor
struct BottleRegistrationViewModelTests {
    @Test func manualRegistrationCreatesAnUnconnectedBottle() throws {
        let fixture = try RegistrationFixture()
        fixture.viewModel.startManualRegistration()
        fixture.viewModel.bottleName = "Daily Bottle"
        fixture.viewModel.capacityText = "750"

        fixture.viewModel.save()

        let bottles = try fixture.context.fetch(FetchDescriptor<Bottle>())
        #expect(bottles.count == 1)
        #expect(bottles.first?.name == "Daily Bottle")
        #expect(bottles.first?.isTagConnected == false)
    }

    @Test func detectingWritableTagOpensTheDetailsForm() throws {
        let fixture = try RegistrationFixture()

        fixture.viewModel.startNFCRegistration()

        #expect(fixture.detector.didDetect)
        #expect(fixture.viewModel.mode == .nfc)
        #expect(fixture.viewModel.isShowingForm)
    }

    @Test func nfcRegistrationWritesBeforeCreatingConnectedBottle() throws {
        let fixture = try RegistrationFixture()
        fixture.viewModel.startNFCRegistration()
        fixture.viewModel.bottleName = "Gym Bottle"
        fixture.viewModel.capacityText = "500"

        fixture.viewModel.save()

        let bottle = try #require(fixture.context.fetch(FetchDescriptor<Bottle>()).first)
        #expect(fixture.writer.writtenURL == BottleTag(bottleID: bottle.id).url)
        #expect(bottle.isTagConnected)
    }
}

@MainActor
private struct RegistrationFixture {
    let container: ModelContainer
    let context: ModelContext
    let detector = FakeTagDetector()
    let writer = FakeRegistrationWriter()
    let viewModel: BottleRegistrationViewModel

    init() throws {
        let schema = Schema([User.self, Bottle.self, DrinkEntry.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [configuration])
        context = container.mainContext
        viewModel = BottleRegistrationViewModel(
            detector: detector,
            writer: writer,
            controller: BottleSetupController(modelContext: context)
        )
    }
}

@MainActor
private final class FakeTagDetector: NFCBottleTagDetecting {
    private(set) var didDetect = false

    func detectWritableTag(completion: @escaping (Result<Void, Error>) -> Void) {
        didDetect = true
        completion(.success(()))
    }
}

@MainActor
private final class FakeRegistrationWriter: NFCBottleWriting {
    private(set) var writtenURL: URL?

    func beginWrite(url: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        writtenURL = url
        completion(.success(()))
    }
}
