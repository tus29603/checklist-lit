//
//  Category.swift
//  Checklist-Lite
//
//  Created by Tesfaldet Haileab on 12/12/25.
//

import Foundation

struct Category: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var color: String // Store as hex string
    
    init(id: UUID = UUID(), name: String, color: String = "#0A84FF") {
        self.id = id
        self.name = name
        self.color = color
    }
    
    static let general = Category(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, name: "General", color: "#0A84FF")
}

