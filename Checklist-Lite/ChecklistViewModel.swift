//
//  ChecklistViewModel.swift
//  Checklist-Lite
//
//  Created by Tesfaldet Haileab on 12/12/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class ChecklistViewModel: ObservableObject {
    @Published var items: [ChecklistItem] = []
    @Published var categoryManager = CategoryManager()
    
    private let itemsKey = "SavedChecklistItems"
    
    init() {
        loadItems()
    }
    
    func addItem(text: String, categoryId: UUID? = nil) {
        let category = categoryId ?? Category.general.id
        let newItem = ChecklistItem(text: text, categoryId: category)
        items.append(newItem)
        saveItems()
    }
    
    func toggleItem(_ item: ChecklistItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isCompleted.toggle()
            saveItems()
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        saveItems()
    }
    
    func clearAllItems() {
        items.removeAll()
        saveItems()
    }
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: itemsKey)
        }
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: itemsKey),
           let decoded = try? JSONDecoder().decode([ChecklistItem].self, from: data) {
            items = decoded
        }
    }
}
