//
//  Item.swift
//  PokeDex
//
//  Created by Carlos Villanueva on 08/10/26.
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
