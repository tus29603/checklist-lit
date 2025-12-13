//
//  ExportImportManager.swift
//  Checklist-Lite
//
//  Created by Tesfaldet Haileab on 12/12/25.
//

import Foundation

struct ExportImportManager {
    static func exportItems(_ items: [ChecklistItem]) -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try? encoder.encode(items)
    }
    
    static func importItems(from data: Data) -> [ChecklistItem]? {
        let decoder = JSONDecoder()
        return try? decoder.decode([ChecklistItem].self, from: data)
    }
}

