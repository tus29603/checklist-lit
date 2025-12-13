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
            contentView
                .navigationTitle("Checklist")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.large)
                #endif
                .toolbar {
                    toolbarContent
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
                .onAppear {
                    if viewModel.debouncedSearchText != viewModel.searchText {
                        viewModel.updateSearchText(viewModel.searchText)
                    }
                }
        }
    }
    
    private var contentView: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissKeyboard()
                }
                .ignoresSafeArea()
            
            mainContent
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
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
    
    private var mainContent: some View {
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
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 14) {
                // Checkbox
                ZStack {
                    Circle()
                        .fill(item.isChecked ? Color.successGreen : Color.clear)
                        .frame(width: 26, height: 26)
                        .overlay(
                            Circle()
                                .stroke(item.isChecked ? Color.successGreen : Color.secondaryGray.opacity(0.4), lineWidth: 2)
                        )
                    
                    if item.isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .symbolEffect(.bounce, value: item.isChecked)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: item.isChecked)
                .accessibilityLabel(item.isChecked ? "Completed" : "Not completed")
                .padding(.top, 2)
                
                // Main content
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 8) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.text)
                                .font(.system(size: 16, weight: item.isChecked ? .regular : .medium))
                                .foregroundColor(item.isChecked ? .secondary : (item.status == .archived ? .secondary : .primary))
                                .strikethrough(item.isChecked, color: .secondary)
                                .multilineTextAlignment(.leading)
                                .lineSpacing(2)
                            
                            // Metadata row
                            HStack(spacing: 6) {
                                // Category badge
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(Color(hex: category.color) ?? .blue)
                                        .frame(width: 6, height: 6)
                                    
                                    Text(category.name)
                                        .font(.system(size: 11, weight: .medium))
                                }
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.systemGray6)
                                )
                                
                                // Priority indicator
                                if item.priority != .none {
                                    HStack(spacing: 4) {
                                        Image(systemName: item.priority.icon)
                                            .font(.system(size: 10, weight: .medium))
                                        Text(item.priority.rawValue)
                                            .font(.system(size: 11, weight: .medium))
                                    }
                                    .foregroundColor(item.priority.color)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(item.priority.color.opacity(0.15))
                                    )
                                }
                                
                                // Status indicators
                                if item.status == .archived {
                                    HStack(spacing: 4) {
                                        Image(systemName: "archivebox.fill")
                                            .font(.system(size: 10, weight: .medium))
                                        Text("Archived")
                                            .font(.system(size: 11, weight: .medium))
                                    }
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color.systemGray6)
                                    )
                                }
                                
                                // Due date
                                if let dueDate = item.dueDate {
                                    HStack(spacing: 4) {
                                        Image(systemName: item.isOverdue ? "exclamationmark.triangle.fill" : "calendar")
                                            .font(.system(size: 10, weight: .medium))
                                        Text(dueDate, style: .date)
                                            .font(.system(size: 11, weight: .medium))
                                    }
                                    .foregroundColor(item.isOverdue ? .red : .secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(item.isOverdue ? Color.red.opacity(0.15) : Color.systemGray6)
                                    )
                                }
                                
                                Spacer()
                            }
                        }
                        
                        Spacer()
                        
                        // Edit button
                        Button(action: onEdit) {
                            Image(systemName: "pencil")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(isHovered ? .primaryAccent : .secondary)
                                .frame(width: 28, height: 28)
                                .background(
                                    Circle()
                                        .fill(isHovered ? Color.primaryAccent.opacity(0.1) : Color.clear)
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Edit item")
                        .opacity(isHovered ? 1 : 0.6)
                    }
                    
                    // Notes section
                    if !item.notes.isEmpty {
                        Button(action: { 
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                showNotes.toggle()
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: showNotes ? "chevron.down" : "chevron.right")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.secondary)
                                
                                Text("Notes")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                            }
                            .padding(.top, 4)
                        }
                        .buttonStyle(.plain)
                        
                        if showNotes {
                            Text(item.notes)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .padding(.leading, 16)
                                .padding(.vertical, 8)
                                .padding(.trailing, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.systemGray6.opacity(0.5))
                                )
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isHovered ? Color.systemGray6.opacity(0.3) : Color.clear)
            )
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering
                }
            }
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
