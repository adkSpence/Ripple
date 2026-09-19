//
//  BottleTagTests.swift
//  RippleTests
//

import Foundation
import Testing
@testable import Ripple

struct BottleTagTests {
    @Test func roundTripPreservesBottleIdentifier() throws {
        let bottleID = UUID()
        let tag = BottleTag(bottleID: bottleID)

        #expect(try BottleTag(url: tag.url).bottleID == bottleID)
    }

    @Test(arguments: [
        "https://example.com/bottle/v1/00000000-0000-0000-0000-000000000000",
        "watertracker://bottle/v2/00000000-0000-0000-0000-000000000000",
        "watertracker://bottle/v1/not-a-uuid",
    ])
    func invalidIdentifiersAreRejected(value: String) {
        #expect(throws: BottleTagError.invalidIdentifier) {
            try BottleTag(url: #require(URL(string: value)))
        }
    }
}
