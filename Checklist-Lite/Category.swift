//
//  Category.swift
//  Checklist-Lite
//
//  Created by Tesfaldet Haileab on 12/12/25.
//

import Foundation

struct Category: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var color: String // Hex color string
    
    init(id: UUID = UUID(), name: String, color: String = "#007AFF") {
        self.id = id
        self.name = name
        self.color = color
    }
    
    static let general = Category(name: "General", color: "#8E8E93")
}



