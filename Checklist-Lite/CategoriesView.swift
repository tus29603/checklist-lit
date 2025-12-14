//
//  CategoriesView.swift
//  Checklist-Lite
//
//  Created by Tesfaldet Haileab on 12/12/25.
//

import SwiftUI

struct CategoriesView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var categoryManager: CategoryManager
    @State private var showAddCategory = false
    @State private var editingCategory: Category?
    
    var body: some View {
        List {
            ForEach(categoryManager.categories) { category in
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(hex: category.color) ?? .blue)
                        .frame(width: 24, height: 24)
                        .shadow(color: Color(hex: category.color)?.opacity(0.3) ?? .clear, radius: 4, x: 0, y: 2)
                    
                    Text(category.name)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                    
                    Spacer()
                    
                    if category.id != Category.general.id {
                        Button {
                            editingCategory = category
                        } label: {
                            Image(systemName: "pencil")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 8)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    if category.id != Category.general.id {
                        Button(role: .destructive) {
                            categoryManager.deleteCategory(category)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        #if os(iOS) || os(visionOS)
        .listStyle(.insetGrouped)
        #else
        .listStyle(.sidebar)
        #endif
        .navigationTitle("Categories")
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
                        Text("Back")
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
                            Image(systemName: "chevron.left")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.blue)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.regular)
                }
                #endif
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddCategory = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .medium))
                }
            }
        }
        #if os(iOS) || os(visionOS)
        .fullScreenCover(isPresented: $showAddCategory) {
            AddEditCategoryView(
                categoryManager: categoryManager,
                category: nil
            )
        }
        .fullScreenCover(item: $editingCategory) { category in
            AddEditCategoryView(
                categoryManager: categoryManager,
                category: category
            )
        }
        #else
        .sheet(isPresented: $showAddCategory) {
            AddEditCategoryView(
                categoryManager: categoryManager,
                category: nil
            )
        }
        .sheet(item: $editingCategory) { category in
            AddEditCategoryView(
                categoryManager: categoryManager,
                category: category
            )
        }
        #endif
    }
}

struct AddEditCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var categoryManager: CategoryManager
    let category: Category?
    
    @State private var name: String = ""
    @State private var selectedColor: String = "#007AFF"
    
    let availableColors = [
        "#007AFF", "#34C759", "#FF9500", "#FF3B30",
        "#AF52DE", "#FF2D55", "#5856D6", "#5AC8FA"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Category Name", text: $name)
                        .font(.system(size: 17, design: .rounded))
                } header: {
                    Text("Name")
                }
                
                Section {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(availableColors, id: \.self) { colorHex in
                            Button {
                                selectedColor = colorHex
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: colorHex) ?? .blue)
                                        .frame(width: 44, height: 44)
                                    
                                    if selectedColor == colorHex {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Color")
                }
            }
            .navigationTitle(category == nil ? "New Category" : "Edit Category")
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
                        .foregroundColor(.red)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        saveCategory()
                    } label: {
                        Text("Save")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                #else
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14, weight: .medium))
                            Text("Cancel")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.red)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.regular)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveCategory()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14, weight: .medium))
                            Text("Save")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                }
                #endif
            }
            .onAppear {
                if let category = category {
                    name = category.name
                    selectedColor = category.color
                }
            }
        }
        #if os(macOS)
        .frame(width: 400, height: 500)
        #endif
    }
    
    private func saveCategory() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        if let existingCategory = category {
            let updated = Category(id: existingCategory.id, name: trimmedName, color: selectedColor)
            categoryManager.updateCategory(updated)
        } else {
            let newCategory = Category(name: trimmedName, color: selectedColor)
            categoryManager.addCategory(newCategory)
        }
        
        dismiss()
    }
}


#Preview {
    NavigationStack {
        CategoriesView(categoryManager: CategoryManager())
    }
}

