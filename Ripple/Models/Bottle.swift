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

    init(
        id: UUID = UUID(),
        name: String,
        capacityML: Int,
        owner: User
    ) {
        self.id = id
        self.name = name
        self.capacityML = capacityML
        self.owner = owner
    }
}
