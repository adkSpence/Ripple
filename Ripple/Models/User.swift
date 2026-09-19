//
//  User.swift
//  Ripple
//

import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var name: String
    var dailyGoalML: Int = 2_000

    init(id: UUID = UUID(), name: String, dailyGoalML: Int = 2_000) {
        self.id = id
        self.name = name
        self.dailyGoalML = dailyGoalML
    }
}
