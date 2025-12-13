//
//  ChecklistItem.swift
//  Checklist-Lite
//
//  Created by Tesfaldet Haileab on 12/12/25.
//

import Foundation

struct ChecklistItem: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var text: String
    var isChecked: Bool // Deprecated, replaced by status
    var categoryId: UUID
    var priority: Priority
    var status: ItemStatus
    var dueDate: Date?
    var notes: String
    let createdAt: Date
    var order: Int // For manual reordering

    init(id: UUID = UUID(), text: String, isChecked: Bool = false, categoryId: UUID = Category.general.id, priority: Priority = .none, status: ItemStatus = .active, dueDate: Date? = nil, notes: String = "", createdAt: Date = Date(), order: Int = 0) {
        self.id = id
        self.text = text
        self.isChecked = isChecked // Kept for migration, but status is primary
        self.categoryId = categoryId
        self.priority = priority
        self.status = status
        self.dueDate = dueDate
        self.notes = notes
        self.createdAt = createdAt
        self.order = order
    }
    
    var isOverdue: Bool {
        guard let dueDate = dueDate, status == .active else { return false }
        return dueDate < Date()
    }
}

