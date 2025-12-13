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
                        HStack(spacing: 12) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.primaryAccent)
                                .frame(width: 24, height: 24)
                            
                            Text("Statistics")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary.opacity(0.5))
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        showExportImport = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "square.and.arrow.up.on.square")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.primaryAccent)
                                .frame(width: 24, height: 24)
                            
                            Text("Export / Import")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary.opacity(0.5))
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                } header: {
                    Text("Actions")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Section {
                    ForEach(viewModel.categoryManager.categories) { category in
                        HStack(spacing: 12) {
                            // Color indicator with shadow
                            ZStack {
                                Circle()
                                    .fill(Color(hex: category.color) ?? .blue)
                                    .frame(width: 16, height: 16)
                                    .shadow(color: (Color(hex: category.color) ?? .blue).opacity(0.4), radius: 3, x: 0, y: 1)
                                
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    .frame(width: 16, height: 16)
                            }
                            
                            Text(category.name)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            // Edit button
                            Button {
                                editingCategory = category
                            } label: {
                                Image(systemName: "pencil")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary.opacity(0.7))
                                    .frame(width: 28, height: 28)
                                    .background(
                                        Circle()
                                            .fill(Color.secondary.opacity(0.1))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 6)
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
                        HStack(spacing: 10) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.primaryAccent)
                            
                            Text("Add Category")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.primaryAccent)
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                } header: {
                    Text("Categories")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Section {
                    HStack(spacing: 12) {
                        Text("Version")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("1.0")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Tagline")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("A simple, focused checklist.")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("About")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            #if os(iOS) || os(visionOS)
            .listStyle(.insetGrouped)
            #elseif os(macOS)
            .listStyle(.sidebar)
            #endif
            .navigationTitle("Settings")
            #if os(iOS) || os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.primaryAccent)
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
                        HStack(spacing: 12) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.primaryAccent)
                                .frame(width: 24, height: 24)
                            
                            Text("Export Checklist")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        // Import functionality would go here
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.primaryAccent)
                                .frame(width: 24, height: 24)
                            
                            Text("Import Checklist")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                } header: {
                    Text("Data Management")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                } footer: {
                    Text("Export your checklist data as JSON to backup or share with others.")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary.opacity(0.7))
                }
            }
            #if os(iOS) || os(visionOS)
            .listStyle(.insetGrouped)
            #elseif os(macOS)
            .listStyle(.sidebar)
            #endif
            .navigationTitle("Export / Import")
            #if os(iOS) || os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.primaryAccent)
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
                Section {
                    TextField("Category name", text: $categoryName)
                        .font(.system(size: 16, design: .rounded))
                } header: {
                    Text("Category Name")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Section {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 16) {
                        ForEach(predefinedColors, id: \.hex) { colorOption in
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    categoryColor = colorOption.hex
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: colorOption.hex) ?? .blue)
                                        .frame(width: 44, height: 44)
                                        .shadow(color: (Color(hex: colorOption.hex) ?? .blue).opacity(0.3), radius: 4, x: 0, y: 2)
                                    
                                    if categoryColor == colorOption.hex {
                                        Circle()
                                            .stroke(Color.white, lineWidth: 3)
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Color")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(category == nil ? "New Category" : "Edit Category")
            #if os(iOS) || os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 17, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveCategory()
                        dismiss()
                    } label: {
                        Text("Save")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.primaryAccent)
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

