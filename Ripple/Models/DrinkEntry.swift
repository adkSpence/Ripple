//
//  DrinkEntry.swift
//  Ripple
//

import Foundation
import SwiftData

@Model
final class DrinkEntry {
    @Attribute(.unique) var id: UUID
    var bottle: Bottle
    var amountML: Int
    var timestamp: Date

    init(
        id: UUID = UUID(),
        bottle: Bottle,
        amountML: Int,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.bottle = bottle
        self.amountML = amountML
        self.timestamp = timestamp
    }
}
