//
//  ChecklistContentView.swift
//  Checklist-Lite
//
//  Created by Tesfaldet Haileab on 12/12/25.
//

import SwiftUI

// MARK: - Search Bar View
struct SearchBarView: View {
    @ObservedObject var viewModel: ChecklistViewModel
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search items...", text: Binding(
                get: { viewModel.searchText },
                set: { viewModel.updateSearchText($0) }
            ))
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                #if os(iOS) || os(visionOS)
                .textInputAutocapitalization(.never)
                #endif
            
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.updateSearchText("")
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.systemGray6)
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, 8)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// MARK: - Filter Section View
struct FilterSectionView: View {
    @ObservedObject var viewModel: ChecklistViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Category filter
                Menu {
                    Button("All Categories") {
                        viewModel.selectedCategoryId = nil
                    }
                    ForEach(viewModel.categoryManager.categories) { category in
                        Button(category.name) {
                            viewModel.selectedCategoryId = category.id
                        }
                    }
                } label: {
                    HStack {
                        Text(viewModel.selectedCategoryId == nil ? "All Categories" : viewModel.categoryManager.category(for: viewModel.selectedCategoryId ?? UUID()).name)
                        Image(systemName: "chevron.down")
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.primaryAccent.opacity(0.1))
                    .foregroundColor(.primaryAccent)
                    .cornerRadius(8)
                }
                
                // Status filter
                Picker("Status", selection: $viewModel.statusFilter) {
                    ForEach(StatusFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Input Section View
struct InputSectionView: View {
    @ObservedObject var viewModel: ChecklistViewModel
    @Binding var inputText: String
    @Binding var isButtonDisabled: Bool
    var isTextFieldFocused: Binding<Bool>
    @Binding var selectedCategoryForNewItem: UUID?
    var onAddItem: () -> Void
    var onMultiLinePaste: ([String]) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                MultiLineTextField(
                    text: $inputText,
                    placeholder: "New item",
                    onPaste: onMultiLinePaste,
                    onTextChange: { newValue in
                        let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                        isButtonDisabled = trimmed.isEmpty
                    },
                    isFocused: isTextFieldFocused
                )
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .frame(minHeight: 44)
                .background(Color.systemGroupedBackground)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.systemGray4, lineWidth: 0.5)
                )
                .accessibilityLabel("New item text field")
                .accessibilityHint("Enter the text for your new checklist item or paste multiple items")
                .onTapGesture {
                    isTextFieldFocused.wrappedValue = true
                }
                
                Button(action: onAddItem) {
                    Text("Add")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(minHeight: 44)
                        .padding(.horizontal, 20)
                        .background(isButtonDisabled ? Color.secondaryGray : Color.primaryAccent)
                        .cornerRadius(11)
                }
                .disabled(isButtonDisabled)
                .accessibilityLabel("Add item")
                .accessibilityHint("Adds the new item to your checklist")
            }
            
            // Category and Priority selection for new item
            HStack(spacing: 12) {
                Menu {
                    ForEach(viewModel.categoryManager.categories) { category in
                        Button(category.name) {
                            selectedCategoryForNewItem = category.id
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "folder")
                        Text(selectedCategoryForNewItem == nil ? "General" : viewModel.categoryManager.category(for: selectedCategoryForNewItem ?? UUID()).name)
                        Image(systemName: "chevron.down")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Menu {
                    ForEach(Priority.allCases, id: \.self) { priority in
                        Button {
                            viewModel.selectedPriority = priority
                        } label: {
                            HStack {
                                Image(systemName: priority.icon)
                                Text(priority.rawValue)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: viewModel.selectedPriority.icon)
                        Text(viewModel.selectedPriority.rawValue)
                        Image(systemName: "chevron.down")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
    }
}

// MARK: - Counter Section View
struct CounterSectionView: View {
    @ObservedObject var viewModel: ChecklistViewModel
    var onClearAll: () -> Void
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text("\(viewModel.completedCount) of \(viewModel.totalCount) completed")
                    .font(.caption)
                    .foregroundColor(.secondaryGray)
                    .contentTransition(.numericText())
                
                Spacer()
                
                // Sort menu
                if !viewModel.items.isEmpty {
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button(option.rawValue) {
                                viewModel.sortOption = option
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.up.arrow.down")
                            Text(viewModel.sortOption.rawValue)
                        }
                        .font(.caption)
                        .foregroundColor(.secondaryGray)
                    }
                }
                
                // Clear All button
                if viewModel.totalCount > 0 {
                    Button(action: onClearAll) {
                        Text("Clear All")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            
            // Progress bar
            if viewModel.totalCount > 0 {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color.systemGray5)
                            .frame(height: 2)
                        
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Color.primaryAccent)
                            .frame(
                                width: geometry.size.width * CGFloat(viewModel.completedCount) / CGFloat(viewModel.totalCount),
                                height: 2
                            )
                            .animation(.easeInOut(duration: 0.2), value: viewModel.completedCount)
                    }
                }
                .frame(height: 2)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .animation(.easeInOut(duration: 0.2), value: viewModel.completedCount)
        .animation(.easeInOut(duration: 0.2), value: viewModel.totalCount)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    @ObservedObject var viewModel: ChecklistViewModel
    
    var body: some View {
        Spacer()
        VStack(spacing: 16) {
            Image(systemName: viewModel.debouncedSearchText.isEmpty ? "checklist" : "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondaryGray.opacity(0.4))
                .symbolEffect(.pulse, options: .repeating)
            
            VStack(spacing: 6) {
                Text(viewModel.debouncedSearchText.isEmpty ? "No items yet" : "No items found")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(viewModel.debouncedSearchText.isEmpty ? 
                     "Add your first task above" :
                     "Try adjusting your search or filters")
                    .font(.subheadline)
                    .foregroundColor(.secondaryGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .padding()
        Spacer()
    }
}

// MARK: - List Section View
struct ListSectionView: View {
    @ObservedObject var viewModel: ChecklistViewModel
    var onEditItem: (ChecklistItem) -> Void
    var onDeleteItems: (IndexSet) -> Void
    var onDismissKeyboard: () -> Void
    
    var body: some View {
        List {
            ForEach(viewModel.filteredAndSortedItems) { item in
                ChecklistItemRow(
                    item: item,
                    category: viewModel.categoryManager.category(for: item.categoryId),
                    onTap: {
                        #if os(iOS)
                        UISelectionFeedbackGenerator().selectionChanged()
                        #endif
                        onDismissKeyboard()
                        viewModel.toggleItem(item)
                    },
                    onEdit: {
                        onDismissKeyboard()
                        onEditItem(item)
                    },
                    onArchive: {
                        if item.status == .archived {
                            viewModel.unarchiveItem(item)
                        } else {
                            viewModel.archiveItem(item)
                        }
                    }
                )
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    if !item.isChecked {
                        Button {
                            #if os(iOS)
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            #endif
                            viewModel.toggleItem(item)
                        } label: {
                            Label("Complete", systemImage: "checkmark.circle.fill")
                        }
                        .tint(.successGreen)
                    } else {
                        Button {
                            #if os(iOS)
                            UISelectionFeedbackGenerator().selectionChanged()
                            #endif
                            viewModel.toggleItem(item)
                        } label: {
                            Label("Uncomplete", systemImage: "circle")
                        }
                        .tint(.orange)
                    }
                    
                    if item.status != .archived {
                        Button {
                            viewModel.archiveItem(item)
                        } label: {
                            Label("Archive", systemImage: "archivebox")
                        }
                        .tint(.blue)
                    } else {
                        Button {
                            viewModel.unarchiveItem(item)
                        } label: {
                            Label("Unarchive", systemImage: "tray.and.arrow.up")
                        }
                        .tint(.green)
                    }
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                .listRowSeparator(.hidden)
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
            }
            .onDelete(perform: onDeleteItems)
            .onMove(perform: viewModel.moveItems)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .environment(\.defaultMinListRowHeight, 60)
        .background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    onDismissKeyboard()
                }
        )
    }
}

