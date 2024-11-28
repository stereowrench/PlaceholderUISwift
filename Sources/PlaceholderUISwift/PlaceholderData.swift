//
//  PlaceholderData.swift
//  kitchen_script
//
//  Created by Theron Boerner on 11/25/24.
//

import Foundation

enum PlaceholderEntryType {
    case plain(String)
    case token(String)
}

struct PlaceholderEntry: Identifiable {
    var id: UUID { UUID() }
    var type: PlaceholderEntryType
}

struct PlaceholderData {
    var data: [PlaceholderEntry]
    
    init(data: [PlaceholderEntry]) {
        self.data = data
    }
    
    init() {
        self.data = []
    }
}

