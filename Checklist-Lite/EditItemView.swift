//
//  EditItemView.swift
//  Checklist-Lite
//
//  Created by Tesfaldet Haileab on 12/12/25.
//

import SwiftUI

struct EditItemView: View {
    @Environment(\.dismiss) var dismiss
    let item: ChecklistItem
    @ObservedObject var viewModel: ChecklistViewModel
    
    @State private var text: String
    @State private var notes: String
    @State private var selectedCategoryId: UUID
    @State private var priority: Priority
    @State private var dueDate: Date?
    @State private var hasDueDate: Bool
    
    init(item: ChecklistItem, viewModel: ChecklistViewModel) {
        self.item = item
        self.viewModel = viewModel
        _text = State(initialValue: item.text)
        _notes = State(initialValue: item.notes)
        _selectedCategoryId = State(initialValue: item.categoryId)
        _priority = State(initialValue: item.priority)
        _dueDate = State(initialValue: item.dueDate)
        _hasDueDate = State(initialValue: item.dueDate != nil)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Item") {
                    TextField("Item text", text: $text)
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Category") {
                    Picker("Category", selection: $selectedCategoryId) {
                        ForEach(viewModel.categoryManager.categories) { category in
                            Text(category.name).tag(category.id)
                        }
                    }
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases) { priority in
                            HStack {
                                Image(systemName: priority.icon)
                                    .foregroundColor(priority.color)
                                Text(priority.rawValue)
                            }
                            .tag(priority)
                        }
                    }
                }
                
                Section("Due Date") {
                    Toggle("Set due date", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("Due date", selection: Binding(
                            get: { dueDate ?? Date() },
                            set: { dueDate = $0 }
                        ), displayedComponents: [.date])
                    }
                }
            }
            .navigationTitle("Edit Item")
            #if os(iOS) || os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                        dismiss()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveItem() {
        var updatedItem = item
        updatedItem.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedItem.notes = notes
        updatedItem.categoryId = selectedCategoryId
        updatedItem.priority = priority
        updatedItem.dueDate = hasDueDate ? dueDate : nil
        viewModel.updateItem(updatedItem)
    }
}

