//
//  Bottle.swift
//  Ripple
//

import Foundation
import SwiftData

@Model
final class Bottle {
    @Attribute(.unique) var id: UUID
    var name: String
    var capacityML: Int
    var owner: User
    var isTagConnected: Bool = false

    init(
        id: UUID = UUID(),
        name: String,
        capacityML: Int,
        owner: User,
        isTagConnected: Bool = false
    ) {
        self.id = id
        self.name = name
        self.capacityML = capacityML
        self.owner = owner
        self.isTagConnected = isTagConnected
    }
}
