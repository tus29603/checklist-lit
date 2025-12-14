//
//  ContentView.swift
//  Checklist-Lite
//
//  Created by Tesfaldet Haileab on 12/12/25.
//

import SwiftUI

#if os(iOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension Color {
    static var systemBackgroundColor: Color {
        #if os(iOS) || os(visionOS)
        return Color(.systemBackground)
        #elseif os(macOS)
        return Color(NSColor.textBackgroundColor)
        #else
        return Color.white
        #endif
    }
    
    static var systemGroupedBackgroundColor: Color {
        #if os(iOS) || os(visionOS)
        return Color(.systemGroupedBackground)
        #elseif os(macOS)
        return Color(NSColor.controlBackgroundColor)
        #else
        return Color.gray.opacity(0.1)
        #endif
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ChecklistViewModel()
    @State private var newItemText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var showSettings = false
    @State private var selectedCategoryId: UUID? = nil // For filtering
    @State private var newItemCategoryId: UUID? = nil // For assigning to new items
    @State private var showClearAllConfirmation = false
    
    // Computed property for filtered items
    private var filteredItems: [ChecklistItem] {
        if let categoryId = selectedCategoryId {
            return viewModel.items.filter { $0.categoryId == categoryId }
        } else {
            return viewModel.items
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.systemGroupedBackgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Input section
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            TextField("What needs to be done?", text: $newItemText)
                                .textFieldStyle(.plain)
                                .font(.system(size: 17, weight: .regular, design: .rounded))
                                .focused($isTextFieldFocused)
                                .onSubmit {
                                    addItem()
                                }
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
                            
                            Button(action: addItem) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 44, weight: .medium))
                                    .foregroundColor(newItemText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray.opacity(0.3) : .blue)
                                    .shadow(
                                        color: newItemText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                        ? .clear
                                        : Color.blue.opacity(0.3),
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                            }
                            .disabled(newItemText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .buttonStyle(.plain)
                            .scaleEffect(newItemText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.95 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: newItemText.isEmpty)
                        }
                        
                        // Category filter and assignment
                        HStack(spacing: 12) {
                            // Filter picker
                            Menu {
                                Button {
                                    selectedCategoryId = nil
                                } label: {
                                    Label("All Categories", systemImage: selectedCategoryId == nil ? "checkmark" : "")
                                }
                                
                                Divider()
                                
                                ForEach(viewModel.categoryManager.categories) { category in
                                    Button {
                                        selectedCategoryId = category.id
                                    } label: {
                                        Label(category.name, systemImage: selectedCategoryId == category.id ? "checkmark" : "")
                                    }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                        .font(.system(size: 12))
                                    
                                    if let categoryId = selectedCategoryId,
                                       let category = viewModel.categoryManager.categories.first(where: { $0.id == categoryId }) {
                                        Circle()
                                            .fill(Color(hex: category.color) ?? .blue)
                                            .frame(width: 8, height: 8)
                                        
                                        Text(category.name)
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                    } else {
                                        Text("Filter")
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                    }
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 8, weight: .semibold))
                                }
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.gray.opacity(0.1))
                                )
                            }
                            .buttonStyle(.plain)
                            
                            // Category assignment for new items
                            CategoryPickerView(
                                categoryManager: viewModel.categoryManager,
                                selectedCategoryId: $newItemCategoryId
                            )
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                    .background(
                        Rectangle()
                            .fill(Color.systemBackgroundColor)
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    )
                    
                    // List of items
                    if viewModel.items.isEmpty {
                        Spacer()
                        VStack(spacing: 24) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "checklist")
                                    .font(.system(size: 56, weight: .ultraLight, design: .rounded))
                                    .foregroundColor(.blue.opacity(0.6))
                            }
                            
                            VStack(spacing: 8) {
                                Text("Your list is empty")
                                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text("Add your first task to get started")
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .transition(.opacity.combined(with: .scale))
                        Spacer()
                    } else if filteredItems.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "tray")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(.secondary.opacity(0.5))
                            
                            Text("No items in this category")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            if selectedCategoryId != nil {
                                Button {
                                    selectedCategoryId = nil
                                } label: {
                                    Text("Show All Categories")
                                        .font(.system(size: 15, weight: .medium, design: .rounded))
                                        .foregroundColor(.blue)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(Color.blue.opacity(0.1))
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.opacity.combined(with: .scale))
                    } else {
                        List {
                            ForEach(filteredItems) { item in
                                ChecklistItemRow(
                                    item: item,
                                    category: viewModel.categoryManager.category(for: item.categoryId),
                                    onToggle: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            viewModel.toggleItem(item)
                                        }
                                    }
                                )
                                .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                            .onDelete { indexSet in
                                // Map filtered indices to actual indices
                                let actualIndices = IndexSet(
                                    indexSet.map { filteredItems[$0].id }
                                        .compactMap { itemId in
                                            viewModel.items.firstIndex(where: { $0.id == itemId })
                                        }
                                )
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    viewModel.deleteItems(at: actualIndices)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Checklist")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        if !viewModel.items.isEmpty {
                            Button(role: .destructive) {
                                showClearAllConfirmation = true
                            } label: {
                                Label("Clear All Items", systemImage: "trash")
                            }
                            
                            Divider()
                        }
                        
                        Button {
                            showSettings = true
                        } label: {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.blue)
                    }
                }
            }
            .confirmationDialog(
                "Clear All Items",
                isPresented: $showClearAllConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All", role: .destructive) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.clearAllItems()
                    }
                    
                    #if os(iOS) || os(visionOS)
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    #endif
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete all \(viewModel.items.count) item\(viewModel.items.count == 1 ? "" : "s")? This action cannot be undone.")
            }
            #if os(iOS) || os(visionOS)
            .fullScreenCover(isPresented: $showSettings) {
                SettingsView()
            }
            #else
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .frame(minWidth: 500, minHeight: 600)
            }
            #endif
        }
    }
    
    private func addItem() {
        let trimmed = newItemText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        #if os(iOS) || os(visionOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            viewModel.addItem(text: trimmed, categoryId: newItemCategoryId)
        }
        
        newItemText = ""
        isTextFieldFocused = true
    }
}

struct ChecklistItemRow: View {
    let item: ChecklistItem
    let category: Category
    let onToggle: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: {
                #if os(iOS) || os(visionOS)
                let generator = UISelectionFeedbackGenerator()
                generator.selectionChanged()
                #endif
                onToggle()
            }) {
                ZStack {
                    Circle()
                        .fill(item.isCompleted ? Color.green : Color.clear)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(
                                    item.isCompleted ? Color.green : Color.gray.opacity(0.4),
                                    lineWidth: 2.5
                                )
                        )
                    
                    if item.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
            }
            .buttonStyle(.plain)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.text)
                    .font(.system(size: 17, weight: item.isCompleted ? .regular : .medium, design: .rounded))
                    .strikethrough(item.isCompleted)
                    .foregroundColor(item.isCompleted ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onToggle()
                    }
                
                // Category badge
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color(hex: category.color) ?? .blue)
                        .frame(width: 6, height: 6)
                    
                    Text(category.name)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill((Color(hex: category.color) ?? .blue).opacity(0.1))
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.systemBackgroundColor)
                .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
        )
        .opacity(item.isCompleted ? 0.7 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: item.isCompleted)
    }
}

#Preview {
    ContentView()
}
