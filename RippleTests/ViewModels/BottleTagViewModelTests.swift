//
//  BottleTagViewModelTests.swift
//  RippleTests
//

import Foundation
import SwiftData
import Testing
@testable import Ripple

@MainActor
struct BottleTagViewModelTests {
    @Test func successfulWriteMarksBottleAsConnected() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        let user = User(name: "Astro")
        let bottle = Bottle(name: "Daily Bottle", capacityML: 750, owner: user)
        context.insert(user)
        context.insert(bottle)

        let writer = FakeNFCBottleWriter(result: .success(()))
        let viewModel = BottleTagViewModel(
            writer: writer,
            controller: BottleTagController(modelContext: context)
        )

        viewModel.connectTag(to: bottle)

        #expect(writer.writtenURL == BottleTag(bottleID: bottle.id).url)
        #expect(bottle.isTagConnected)
        #expect(viewModel.confirmationMessage == "NFC tag connected to Daily Bottle.")
        #expect(viewModel.errorMessage == nil)
    }

    @Test func failedWriteDoesNotMarkBottleAsConnected() throws {
        let container = try makeTestContainer()
        let context = container.mainContext
        let user = User(name: "Astro")
        let bottle = Bottle(name: "Daily Bottle", capacityML: 750, owner: user)
        context.insert(user)
        context.insert(bottle)

        let writer = FakeNFCBottleWriter(
            result: .failure(NFCBottleWriterError.readOnly)
        )
        let viewModel = BottleTagViewModel(
            writer: writer,
            controller: BottleTagController(modelContext: context)
        )

        viewModel.connectTag(to: bottle)

        #expect(!bottle.isTagConnected)
        #expect(viewModel.confirmationMessage == nil)
        #expect(viewModel.errorMessage == "This NFC tag is read-only. Use a blank or rewritable tag.")
    }

    private func makeTestContainer() throws -> ModelContainer {
        let schema = Schema([User.self, Bottle.self, DrinkEntry.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}

@MainActor
private final class FakeNFCBottleWriter: NFCBottleWriting {
    let result: Result<Void, Error>
    private(set) var writtenURL: URL?

    init(result: Result<Void, Error>) {
        self.result = result
    }

    func beginWrite(
        url: URL,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        writtenURL = url
        completion(result)
    }
}
