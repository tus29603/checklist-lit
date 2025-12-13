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
    @Published var newItemText: String = "" // Used by MultiLineTextField
    @Published var selectedCategoryId: UUID? {
        didSet {
            saveSelectedCategory()
        }
    }
    @Published var selectedPriority: Priority = .none
    @Published var statusFilter: StatusFilter = .all
    @Published var searchText: String = ""
    @Published var sortOption: SortOption = .manual
    @Published var categoryManager = CategoryManager()
    
    @Published var debouncedSearchText: String = "" // Debounced version of searchText

    private let itemsKey = "SavedChecklistItems"
    private let selectedCategoryKey = "SelectedCategoryId"
    private var saveTask: Task<Void, Never>?
    private var searchTask: Task<Void, Never>?
    private var nextOrder: Int = 0
    
    init() {
        loadItems()
        loadSelectedCategory()
        updateNextOrder()
        // Initialize debounced search to match search text
        debouncedSearchText = searchText
    }
    
    // Update debounced search text when searchText changes
    func updateSearchText(_ newValue: String) {
        // Only update if the value actually changed to prevent unnecessary updates
        guard searchText != newValue else { return }
        searchText = newValue
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
            guard !Task.isCancelled else { return }
            debouncedSearchText = newValue
        }
    }
    
    // MARK: - Item Management
    
    func addItem(categoryId: UUID? = nil, priority: Priority? = nil) {
        let trimmedText = newItemText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        let category = categoryId ?? selectedCategoryId ?? Category.general.id
        let itemPriority = priority ?? selectedPriority
        
        let newItem = ChecklistItem(
            text: trimmedText,
            categoryId: category,
            priority: itemPriority,
            order: nextOrder
        )
        nextOrder += 1
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            items.append(newItem)
        }
        newItemText = ""
        saveItemsAsync()
    }
    
    func addItems(from texts: [String], categoryId: UUID? = nil, priority: Priority? = nil) {
        for text in texts {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedText.isEmpty else { continue }
            
            let category = categoryId ?? selectedCategoryId ?? Category.general.id
            let itemPriority = priority ?? selectedPriority
            
            let newItem = ChecklistItem(
                text: trimmedText,
                categoryId: category,
                priority: itemPriority,
                order: nextOrder
            )
            nextOrder += 1
            items.append(newItem) // Append without animation for bulk add
        }
        saveItemsAsync()
    }
    
    func updateItem(_ updatedItem: ChecklistItem) {
        if let index = items.firstIndex(where: { $0.id == updatedItem.id }) {
            items[index] = updatedItem
            saveItemsAsync()
        }
    }
    
    func toggleItem(_ item: ChecklistItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                items[index].isChecked.toggle()
                items[index].status = items[index].isChecked ? .completed : .active
            }
            saveItemsAsync()
        }
    }
    
    func archiveItem(_ item: ChecklistItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                items[index].status = .archived
            }
            saveItemsAsync()
        }
    }
    
    func unarchiveItem(_ item: ChecklistItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                items[index].status = .active
            }
            saveItemsAsync()
        }
    }
    
    func deleteItem(_ item: ChecklistItem) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            items.removeAll { $0.id == item.id }
        }
        saveItemsAsync()
    }
    
    func moveItems(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
        updateOrder()
        saveItemsAsync()
    }
    
    func clearCompleted() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            items.removeAll { $0.isChecked || $0.status == .completed }
        }
        saveItemsAsync()
    }
    
    func clearAll() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            items.removeAll()
        }
        nextOrder = 0
        saveItemsAsync()
    }
    
    // MARK: - Filtering & Sorting
    
    var filteredAndSortedItems: [ChecklistItem] {
        var filtered = items
        
        // Category filter
        if let categoryId = selectedCategoryId {
            filtered = filtered.filter { $0.categoryId == categoryId }
        }
        
        // Status filter
        switch statusFilter {
        case .all:
            break
        case .active:
            filtered = filtered.filter { $0.status == .active }
        case .completed:
            filtered = filtered.filter { $0.status == .completed || $0.isChecked }
        case .archived:
            filtered = filtered.filter { $0.status == .archived }
        }
        
        // Search filter (uses debounced text)
        if !debouncedSearchText.isEmpty {
            let searchLower = debouncedSearchText.lowercased()
            filtered = filtered.filter { item in
                item.text.lowercased().contains(searchLower) ||
                item.notes.lowercased().contains(searchLower) ||
                categoryManager.category(for: item.categoryId).name.lowercased().contains(searchLower)
            }
        }
        
        // Sorting
        switch sortOption {
        case .manual:
            filtered.sort { $0.order < $1.order }
        case .creationDate:
            filtered.sort { $0.createdAt > $1.createdAt }
        case .dueDate:
            filtered.sort { item1, item2 in
                guard let date1 = item1.dueDate else { return false }
                guard let date2 = item2.dueDate else { return true }
                return date1 < date2
            }
        case .priority:
            let priorityOrder: [Priority] = [.high, .medium, .low, .none]
            filtered.sort { item1, item2 in
                let index1 = priorityOrder.firstIndex(of: item1.priority) ?? 999
                let index2 = priorityOrder.firstIndex(of: item2.priority) ?? 999
                return index1 < index2
            }
        }
        
        return filtered
    }
    
    // MARK: - Counts
    
    var completedCount: Int {
        items.filter { $0.isChecked || $0.status == .completed }.count
    }
    
    var totalCount: Int {
        items.count
    }
    
    var hasCompletedItems: Bool {
        completedCount > 0
    }
    
    var completionPercentage: Double {
        totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0
    }
    
    // MARK: - Persistence
    
    private func saveItemsAsync() {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second debounce
            guard !Task.isCancelled else { return }
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: itemsKey)
            }
        }
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: itemsKey),
           let decoded = try? JSONDecoder().decode([ChecklistItem].self, from: data) {
            items = decoded
            // Migrate old `isChecked` to `status` if necessary
            for i in 0..<items.count {
                if items[i].isChecked && items[i].status == .active {
                    items[i].status = .completed
                }
            }
        }
    }
    
    private func saveSelectedCategory() {
        if let id = selectedCategoryId {
            UserDefaults.standard.set(id.uuidString, forKey: selectedCategoryKey)
        } else {
            UserDefaults.standard.removeObject(forKey: selectedCategoryKey)
        }
    }
    
    private func loadSelectedCategory() {
        if let idString = UserDefaults.standard.string(forKey: selectedCategoryKey),
           let id = UUID(uuidString: idString) {
            selectedCategoryId = id
        }
    }
    
    private func updateNextOrder() {
        if let maxOrder = items.map({ $0.order }).max() {
            nextOrder = maxOrder + 1
        } else {
            nextOrder = 0
        }
    }
    
    private func updateOrder() {
        for i in 0..<items.count {
            items[i].order = i
        }
    }
}

