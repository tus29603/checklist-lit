//
//  EditItemView.swift
//  Checklist-Lite
//
//  Created by Tesfaldet Haileab on 12/12/25.
//

import SwiftUI

#if os(macOS)
import AppKit
#endif

struct EditItemView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var categoryManager: CategoryManager
    
    let item: ChecklistItem
    let onSave: (String, UUID) -> Void
    
    @State private var editedText: String
    @State private var selectedCategoryId: UUID?
    @FocusState private var isTextFieldFocused: Bool
    
    init(item: ChecklistItem, categoryManager: CategoryManager, onSave: @escaping (String, UUID) -> Void) {
        self.item = item
        self.categoryManager = categoryManager
        self.onSave = onSave
        _editedText = State(initialValue: item.text)
        _selectedCategoryId = State(initialValue: item.categoryId)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.systemGroupedBackgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Text input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Item Text")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        TextField("Enter item text", text: $editedText, axis: .vertical)
                            .textFieldStyle(.plain)
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                            .focused($isTextFieldFocused)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.systemBackgroundColor)
                                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        isTextFieldFocused ? Color.blue.opacity(0.4) : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                            .lineLimit(3...10)
                    }
                    
                    // Category picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Category")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        CategoryPickerView(
                            categoryManager: categoryManager,
                            selectedCategoryId: $selectedCategoryId
                        )
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }
            .navigationTitle("Edit Item")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS) || os(visionOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20, weight: .medium))
                            Text("Cancel")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.blue)
                    }
                }
                #else
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                            Text("Cancel")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.blue)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.regular)
                }
                #endif
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        let trimmed = editedText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        
                        let categoryId = selectedCategoryId ?? Category.general.id
                        onSave(trimmed, categoryId)
                        dismiss()
                    } label: {
                        #if os(iOS) || os(visionOS)
                        Text("Save")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.blue)
                        #else
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                            Text("Save")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.blue)
                        #endif
                    }
                    .disabled(editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedCategoryId == nil)
                }
            }
            .onAppear {
                // Focus the text field when the view appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isTextFieldFocused = true
                }
            }
        }
    }
}

#Preview {
    EditItemView(
        item: ChecklistItem(text: "Sample item to edit", categoryId: Category.general.id),
        categoryManager: CategoryManager(),
        onSave: { text, categoryId in
            print("Saved: \(text), category: \(categoryId)")
        }
    )
}

