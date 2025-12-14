//
//  CategoryManager.swift
//  Checklist-Lite
//
//  Created by Tesfaldet Haileab on 12/12/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class CategoryManager: ObservableObject {
    @Published var categories: [Category] = []
    
    private let categoriesKey = "SavedCategories"
    
    init() {
        loadCategories()
        if categories.isEmpty {
            // Add default categories
            categories = [
                Category.general,
                Category(name: "Work", color: "#007AFF"),
                Category(name: "Personal", color: "#34C759"),
                Category(name: "Shopping", color: "#FF9500")
            ]
            saveCategories()
        }
    }
    
    func addCategory(_ category: Category) {
        categories.append(category)
        saveCategories()
    }
    
    func updateCategory(_ category: Category) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
            saveCategories()
        }
    }
    
    func deleteCategory(_ category: Category) {
        // Don't allow deleting the General category
        if category.id == Category.general.id {
            return
        }
        categories.removeAll { $0.id == category.id }
        saveCategories()
    }
    
    func category(for id: UUID) -> Category {
        categories.first(where: { $0.id == id }) ?? Category.general
    }
    
    private func saveCategories() {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: categoriesKey)
        }
    }
    
    private func loadCategories() {
        if let data = UserDefaults.standard.data(forKey: categoriesKey),
           let decoded = try? JSONDecoder().decode([Category].self, from: data) {
            categories = decoded
        }
    }
}

