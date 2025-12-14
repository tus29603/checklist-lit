//
//  ChecklistItem.swift
//  Checklist-Lite
//
//  Created by Tesfaldet Haileab on 12/12/25.
//

import Foundation

struct ChecklistItem: Identifiable, Codable {
    let id: UUID
    var text: String
    var isCompleted: Bool
    var categoryId: UUID
    let createdAt: Date
    
    init(id: UUID = UUID(), text: String, isCompleted: Bool = false, categoryId: UUID = Category.general.id, createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.isCompleted = isCompleted
        self.categoryId = categoryId
        self.createdAt = createdAt
    }
}

