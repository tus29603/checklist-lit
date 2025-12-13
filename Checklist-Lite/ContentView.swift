//
//  ContentView.swift
//  Checklist-Lite
//
//  Created by Tesfaldet Haileab on 12/12/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChecklistViewModel()
    @FocusState private var isTextFieldFocused: Bool
    @State private var showClearCompletedAlert = false
    @State private var showClearAllAlert = false
    @State private var showSettings = false
    @State private var editingItem: ChecklistItem?
    @State private var selectedCategoryForNewItem: UUID?
    
    // Move input text to view level to avoid ViewModel updates on every keystroke
    @State private var inputText: String = ""
    @State private var isButtonDisabled: Bool = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background tap area for dismissing keyboard
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        dismissKeyboard()
                    }
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    if !viewModel.items.isEmpty {
                        SearchBarView(viewModel: viewModel)
                    }
                    
                    // Category and Status Filters
                    if !viewModel.items.isEmpty {
                        FilterSectionView(viewModel: viewModel)
                    }
                    
                    // Input section
                    InputSectionView(
                        viewModel: viewModel,
                        inputText: $inputText,
                        isButtonDisabled: $isButtonDisabled,
                        isTextFieldFocused: Binding(
                            get: { isTextFieldFocused },
                            set: { isTextFieldFocused = $0 }
                        ),
                        selectedCategoryForNewItem: $selectedCategoryForNewItem,
                        onAddItem: addItem,
                        onMultiLinePaste: handleMultiLinePaste
                    )
                    
                    // Item counter and sort
                    CounterSectionView(viewModel: viewModel) {
                        #if os(iOS)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        #endif
                        showClearAllAlert = true
                    }
                    
                    // List section
                    if viewModel.filteredAndSortedItems.isEmpty {
                        EmptyStateView(viewModel: viewModel)
                    } else {
                        ListSectionView(
                            viewModel: viewModel,
                            onEditItem: { item in
                                editingItem = item
                            },
                            onDeleteItems: deleteItems,
                            onDismissKeyboard: dismissKeyboard
                        )
                    }
                }
            }
            .navigationTitle("Checklist")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .onAppear {
                // Initialize debounced search text
                if viewModel.debouncedSearchText != viewModel.searchText {
                    viewModel.updateSearchText(viewModel.searchText)
                }
            }
            .toolbar {
                #if os(iOS) || os(visionOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundColor(.primary.opacity(0.7))
                    }
                    .accessibilityLabel("Settings")
                    .frame(minWidth: 44, minHeight: 44)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if viewModel.hasCompletedItems {
                            Button(role: .destructive, action: {
                                showClearCompletedAlert = true
                            }) {
                                Label("Clear Completed", systemImage: "checkmark.circle")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.primary.opacity(0.7))
                    }
                    .accessibilityLabel("More options")
                    .frame(minWidth: 44, minHeight: 44)
                }
                #elseif os(macOS)
                ToolbarItem(placement: .automatic) {
                    HStack {
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .foregroundColor(.primary.opacity(0.7))
                        }
                        .accessibilityLabel("Settings")
                        
                        Menu {
                            if viewModel.hasCompletedItems {
                                Button(role: .destructive, action: {
                                    showClearCompletedAlert = true
                                }) {
                                    Label("Clear Completed", systemImage: "checkmark.circle")
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(.primary.opacity(0.7))
                        }
                        .accessibilityLabel("More options")
                    }
                }
                #endif
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(viewModel: viewModel)
            }
            .sheet(item: $editingItem) { item in
                EditItemView(item: item, viewModel: viewModel)
            }
            .alert("Clear completed items?", isPresented: $showClearCompletedAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    viewModel.clearCompleted()
                }
            }
            .alert("Delete all checklist items?", isPresented: $showClearAllAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.clearAll()
                }
            }
        }
    }
    
    
    private func deleteItems(at offsets: IndexSet) {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
        let itemsToDelete = offsets.map { viewModel.filteredAndSortedItems[$0] }
        for item in itemsToDelete {
            viewModel.deleteItem(item)
        }
    }
    
    private func addItem() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        
        // Update ViewModel only when adding, not on every keystroke
        viewModel.newItemText = trimmedText
        viewModel.addItem(categoryId: selectedCategoryForNewItem)
        
        // Clear input and maintain focus
        inputText = ""
        isButtonDisabled = true
        
        // Small delay to ensure keyboard stays open
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isTextFieldFocused = true
        }
    }
    
    private func handleMultiLinePaste(_ items: [String]) {
        guard !items.isEmpty else { return }
        
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
        
        // Add all items
        for itemText in items {
            viewModel.newItemText = itemText
            viewModel.addItem(categoryId: selectedCategoryForNewItem)
        }
        
        // Clear input and dismiss keyboard
        inputText = ""
        isButtonDisabled = true
        dismissKeyboard()
    }
    
    private func dismissKeyboard() {
        isTextFieldFocused = false
        #if os(iOS)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }
}

struct ChecklistItemRow: View {
    let item: ChecklistItem
    let category: Category
    let onTap: () -> Void
    let onEdit: () -> Void
    let onArchive: () -> Void
    @State private var showNotes = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    // Checkbox
                    Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(item.isChecked ? .successGreen : .secondaryGray)
                        .font(.title3)
                        .symbolEffect(.bounce, value: item.isChecked)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: item.isChecked)
                        .accessibilityLabel(item.isChecked ? "Completed" : "Not completed")
                    
                    // Main content
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .top, spacing: 6) {
                            Text(item.text)
                                .font(.system(size: 17))
                                .foregroundColor(item.isChecked ? .secondaryGray : (item.status == .archived ? .secondaryGray : .primary))
                                .strikethrough(item.isChecked, color: .secondaryGray)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            // Priority indicator
                            if item.priority != .none {
                                Image(systemName: item.priority.icon)
                                    .foregroundColor(item.priority.color)
                                    .font(.caption)
                                    .accessibilityLabel("Priority: \(item.priority.rawValue)")
                            }
                            
                            // Edit button
                            Button(action: onEdit) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Edit item")
                        }
                        
                        // Metadata row
                        HStack(spacing: 8) {
                            // Category badge
                            HStack(spacing: 4) {
                                Image(systemName: "folder.fill")
                                    .font(.caption2)
                                Text(category.name)
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.systemGray6)
                            .cornerRadius(4)
                            
                            // Status indicators
                            if item.status == .archived {
                                HStack(spacing: 4) {
                                    Image(systemName: "archivebox.fill")
                                        .font(.caption2)
                                    Text("Archived")
                                        .font(.caption)
                                }
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.systemGray6)
                                .cornerRadius(4)
                            }
                            
                            // Due date
                            if let dueDate = item.dueDate {
                                HStack(spacing: 4) {
                                    Image(systemName: item.isOverdue ? "exclamationmark.triangle.fill" : "calendar")
                                        .font(.caption2)
                                    Text(dueDate, style: .date)
                                        .font(.caption)
                                }
                                .foregroundColor(item.isOverdue ? .red : .secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(item.isOverdue ? Color.red.opacity(0.1) : Color.systemGray6)
                                .cornerRadius(4)
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                // Notes section
                if !item.notes.isEmpty {
                    Button(action: { 
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showNotes.toggle()
                        }
                    }) {
                        HStack {
                            Image(systemName: showNotes ? "chevron.down" : "chevron.right")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("Notes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                    
                    if showNotes {
                        Text(item.notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 20)
                            .padding(.vertical, 4)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.isChecked ? "Completed: \(item.text)" : item.text)
        .accessibilityHint("Double tap to toggle completion")
    }
}

#Preview {
    ContentView()
}
