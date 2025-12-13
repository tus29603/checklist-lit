//
//  CategoryManager.swift
//  Checklist-Lite
//
//  Created by Tesfaldet Haileab on 12/12/25.
//

import Foundation
import Combine

@MainActor
class CategoryManager: ObservableObject {
    @Published var categories: [Category] = []
    
    private let categoriesKey = "SavedCategories"
    
    init() {
        loadCategories()
        if categories.isEmpty {
            categories = [Category.general]
            saveCategories()
        }
    }
    
    func category(for id: UUID) -> Category {
        categories.first { $0.id == id } ?? Category.general
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
        categories.removeAll { $0.id == category.id }
        saveCategories()
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

