//
//  SettingsView.swift
//  Checklist-Lite
//
//  Created by Tesfaldet Haileab on 12/12/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ChecklistViewModel
    @State private var showStatistics = false
    @State private var showExportImport = false
    @State private var editingCategory: Category?
    @State private var showAddCategory = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        showStatistics = true
                    } label: {
                        Label("Statistics", systemImage: "chart.bar.fill")
                    }
                    
                    Button {
                        showExportImport = true
                    } label: {
                        Label("Export / Import", systemImage: "square.and.arrow.up.on.square")
                    }
                }
                
                Section("Categories") {
                    ForEach(viewModel.categoryManager.categories) { category in
                        HStack {
                            // Color indicator
                            Circle()
                                .fill(Color(hex: category.color) ?? .blue)
                                .frame(width: 12, height: 12)
                            
                            Text(category.name)
                            
                            Spacer()
                            
                            // Edit button
                            Button {
                                editingCategory = category
                            } label: {
                                Image(systemName: "pencil")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            .buttonStyle(.plain)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingCategory = category
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let category = viewModel.categoryManager.categories[index]
                            // Don't allow deleting the General category
                            if category.id != Category.general.id {
                                viewModel.categoryManager.deleteCategory(category)
                            }
                        }
                    }
                    
                    Button {
                        showAddCategory = true
                    } label: {
                        Label("Add Category", systemImage: "plus.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Settings")
            #if os(iOS) || os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showStatistics) {
                StatisticsView(viewModel: viewModel)
            }
            .sheet(isPresented: $showExportImport) {
                ExportImportView(viewModel: viewModel)
            }
            .sheet(isPresented: $showAddCategory) {
                CategoryEditView(
                    category: nil,
                    categoryManager: viewModel.categoryManager
                )
            }
            .sheet(item: $editingCategory) { category in
                CategoryEditView(
                    category: category,
                    categoryManager: viewModel.categoryManager
                )
            }
            #if os(macOS)
            .frame(width: 400, height: 500)
            #endif
        }
    }
}

struct ExportImportView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ChecklistViewModel
    @State private var showShareSheet = false
    @State private var exportData: Data?
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        exportData = ExportImportManager.exportItems(viewModel.items)
                        showShareSheet = true
                    } label: {
                        Label("Export Checklist", systemImage: "square.and.arrow.up")
                    }
                    
                    Button {
                        // Import functionality would go here
                    } label: {
                        Label("Import Checklist", systemImage: "square.and.arrow.down")
                    }
                }
            }
            .navigationTitle("Export / Import")
            #if os(iOS) || os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            #if os(iOS) || os(visionOS)
            .sheet(isPresented: $showShareSheet) {
                if let data = exportData, let jsonString = String(data: data, encoding: .utf8) {
                    ShareSheet(activityItems: [jsonString])
                }
            }
            #elseif os(macOS)
            .sheet(isPresented: $showShareSheet) {
                if let data = exportData, let jsonString = String(data: data, encoding: .utf8) {
                    macOSShareSheet(content: jsonString)
                }
            }
            #endif
        }
    }
}

#if os(iOS) || os(visionOS)
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif

#if os(macOS)
import AppKit

struct macOSShareSheet: View {
    @Environment(\.dismiss) var dismiss
    let content: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Export Data")
                .font(.headline)
            
            ScrollView {
                Text(content)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 300)
            .border(Color.secondary, width: 1)
            
            HStack {
                Button("Copy to Clipboard") {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(content, forType: .string)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(width: 500, height: 400)
    }
}
#endif

// MARK: - Category Edit View
struct CategoryEditView: View {
    @Environment(\.dismiss) var dismiss
    let category: Category?
    @ObservedObject var categoryManager: CategoryManager
    
    @State private var categoryName: String
    @State private var categoryColor: String
    
    // Predefined colors
    private let predefinedColors: [(name: String, hex: String)] = [
        ("Blue", "#0A84FF"),
        ("Green", "#34C759"),
        ("Orange", "#FF9500"),
        ("Red", "#FF3B30"),
        ("Purple", "#AF52DE"),
        ("Pink", "#FF2D55"),
        ("Yellow", "#FFCC00"),
        ("Teal", "#5AC8FA"),
        ("Indigo", "#5856D6"),
        ("Gray", "#8E8E93")
    ]
    
    init(category: Category?, categoryManager: CategoryManager) {
        self.category = category
        self.categoryManager = categoryManager
        _categoryName = State(initialValue: category?.name ?? "")
        _categoryColor = State(initialValue: category?.color ?? "#0A84FF")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Category Name") {
                    TextField("Category name", text: $categoryName)
                }
                
                Section("Color") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 12) {
                        ForEach(predefinedColors, id: \.hex) { colorOption in
                            Button {
                                categoryColor = colorOption.hex
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: colorOption.hex) ?? .blue)
                                        .frame(width: 40, height: 40)
                                    
                                    if categoryColor == colorOption.hex {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                            .font(.caption)
                                            .fontWeight(.bold)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(category == nil ? "New Category" : "Edit Category")
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
                        saveCategory()
                        dismiss()
                    }
                    .disabled(categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            #if os(macOS)
            .frame(width: 400, height: 400)
            #endif
        }
    }
    
    private func saveCategory() {
        let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        if let existingCategory = category {
            // Update existing category
            var updatedCategory = existingCategory
            updatedCategory.name = trimmedName
            updatedCategory.color = categoryColor
            categoryManager.updateCategory(updatedCategory)
        } else {
            // Create new category
            let newCategory = Category(name: trimmedName, color: categoryColor)
            categoryManager.addCategory(newCategory)
        }
    }
}

// MARK: - Color Extension for Hex
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

