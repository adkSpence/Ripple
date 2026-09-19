//
//  BottleTag.swift
//  Ripple
//

import Foundation

enum BottleTagError: LocalizedError, Equatable {
    case invalidIdentifier

    var errorDescription: String? {
        "This NFC tag is not a valid Ripple bottle tag."
    }
}

struct BottleTag: Equatable {
    static let scheme = "watertracker"

    let bottleID: UUID

    var url: URL {
        URL(string: "\(Self.scheme)://bottle/v1/\(bottleID.uuidString)")!
    }

    init(bottleID: UUID) {
        self.bottleID = bottleID
    }

    init(url: URL) throws {
        guard
            url.scheme?.lowercased() == Self.scheme,
            url.host?.lowercased() == "bottle"
        else {
            throw BottleTagError.invalidIdentifier
        }

        let components = url.pathComponents.filter { $0 != "/" }
        guard
            components.count == 2,
            components[0].lowercased() == "v1",
            let bottleID = UUID(uuidString: components[1])
        else {
            throw BottleTagError.invalidIdentifier
        }

        self.bottleID = bottleID
    }
}
