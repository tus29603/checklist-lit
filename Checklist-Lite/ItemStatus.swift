//
//  ItemStatus.swift
//  Checklist-Lite
//
//  Created by Tesfaldet Haileab on 12/12/25.
//

import Foundation

enum ItemStatus: String, Codable, CaseIterable {
    case active = "Active"
    case completed = "Completed"
    case archived = "Archived"
}

enum StatusFilter: String, CaseIterable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
    case archived = "Archived"
}

enum SortOption: String, CaseIterable {
    case manual = "Manual"
    case creationDate = "Created"
    case dueDate = "Due Date"
    case priority = "Priority"
}

