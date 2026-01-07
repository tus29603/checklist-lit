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
    
    func moveItems(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
        saveItems()
    }
    
    func moveFilteredItems(from source: IndexSet, to destination: Int, filteredItems: [ChecklistItem]) {
        // Map filtered indices to actual item IDs
        let sourceIds = source.map { filteredItems[$0].id }
        
        // Find the destination item ID
        let destinationId = destination < filteredItems.count ? filteredItems[destination].id : nil
        
        // Get actual indices in the full items array
        var actualSourceIndices: [Int] = []
        for id in sourceIds {
            if let index = items.firstIndex(where: { $0.id == id }) {
                actualSourceIndices.append(index)
            }
        }
        
        // Find destination index in full array
        var actualDestinationIndex: Int
        if let destinationId = destinationId,
           let destIndex = items.firstIndex(where: { $0.id == destinationId }) {
            actualDestinationIndex = destIndex
        } else {
            // If destination is beyond filtered items, find the last item of the filtered category
            if let lastFiltered = filteredItems.last,
               let lastIndex = items.firstIndex(where: { $0.id == lastFiltered.id }) {
                actualDestinationIndex = lastIndex + 1
            } else {
                actualDestinationIndex = items.count
            }
        }
        
        // Adjust destination if moving items before it
        let itemsBeforeDestination = actualSourceIndices.filter { $0 < actualDestinationIndex }.count
        actualDestinationIndex -= itemsBeforeDestination
        
        // Perform the move
        let sourceIndexSet = IndexSet(actualSourceIndices)
        items.move(fromOffsets: sourceIndexSet, toOffset: actualDestinationIndex)
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
