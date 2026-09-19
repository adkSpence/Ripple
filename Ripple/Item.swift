//
//  Item.swift
//  Ripple
//
//  Created by Spencer Apeadjei-Duodu on 19.09.26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
