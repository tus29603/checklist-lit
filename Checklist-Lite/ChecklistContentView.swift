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
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 15, weight: .medium))
            
            TextField("Search items...", text: Binding(
                get: { viewModel.searchText },
                set: { viewModel.updateSearchText($0) }
            ))
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .focused($isSearchFocused)
                #if os(iOS) || os(visionOS)
                .textInputAutocapitalization(.never)
                #endif
            
            if !viewModel.searchText.isEmpty {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.updateSearchText("")
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.systemGray6)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSearchFocused ? Color.primaryAccent.opacity(0.3) : Color.clear, lineWidth: 1.5)
        )
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 4)
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.searchText.isEmpty)
    }
}

// MARK: - Filter Section View
struct FilterSectionView: View {
    @ObservedObject var viewModel: ChecklistViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // Category filter
                Menu {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.selectedCategoryId = nil
                        }
                    } label: {
                        Label("All Categories", systemImage: viewModel.selectedCategoryId == nil ? "checkmark" : "")
                    }
                    
                    Divider()
                    
                    ForEach(viewModel.categoryManager.categories) { category in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.selectedCategoryId = category.id
                            }
                        } label: {
                            Label(category.name, systemImage: viewModel.selectedCategoryId == category.id ? "checkmark" : "")
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        if let categoryId = viewModel.selectedCategoryId,
                           let category = viewModel.categoryManager.categories.first(where: { $0.id == categoryId }) {
                            Circle()
                                .fill(Color(hex: category.color) ?? .blue)
                                .frame(width: 8, height: 8)
                        } else {
                            Image(systemName: "folder.fill")
                                .font(.system(size: 11))
                        }
                        
                        Text(viewModel.selectedCategoryId == nil ? "All Categories" : viewModel.categoryManager.category(for: viewModel.selectedCategoryId ?? UUID()).name)
                            .font(.system(size: 13, weight: .medium))
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(viewModel.selectedCategoryId == nil ? Color.primaryAccent.opacity(0.1) : Color.systemGray6)
                    )
                    .foregroundColor(viewModel.selectedCategoryId == nil ? .primaryAccent : .primary)
                }
                .buttonStyle(.plain)
                
                // Status filter
                Picker("Status", selection: $viewModel.statusFilter) {
                    ForEach(StatusFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 220)
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 10)
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
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                MultiLineTextField(
                    text: $inputText,
                    placeholder: "What needs to be done?",
                    onPaste: onMultiLinePaste,
                    onTextChange: { newValue in
                        let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                        isButtonDisabled = trimmed.isEmpty
                    },
                    isFocused: isTextFieldFocused
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .frame(minHeight: 50)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.systemGroupedBackground)
                        .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isTextFieldFocused.wrappedValue ? Color.primaryAccent.opacity(0.4) : Color.systemGray4.opacity(0.5), lineWidth: isTextFieldFocused.wrappedValue ? 2 : 1)
                )
                .accessibilityLabel("New item text field")
                .accessibilityHint("Enter the text for your new checklist item or paste multiple items")
                .onTapGesture {
                    isTextFieldFocused.wrappedValue = true
                }
                
                Button(action: onAddItem) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(isButtonDisabled ? Color.secondaryGray : Color.primaryAccent)
                                .shadow(color: isButtonDisabled ? .clear : Color.primaryAccent.opacity(0.3), radius: 4, x: 0, y: 2)
                        )
                }
                .disabled(isButtonDisabled)
                .buttonStyle(.plain)
                .scaleEffect(isButtonDisabled ? 0.95 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isButtonDisabled)
                .accessibilityLabel("Add item")
                .accessibilityHint("Adds the new item to your checklist")
            }
            
            // Category and Priority selection for new item
            HStack(spacing: 10) {
                Menu {
                    ForEach(viewModel.categoryManager.categories) { category in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedCategoryForNewItem = category.id
                            }
                        } label: {
                            Label(category.name, systemImage: selectedCategoryForNewItem == category.id ? "checkmark" : "")
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        if let categoryId = selectedCategoryForNewItem,
                           let category = viewModel.categoryManager.categories.first(where: { $0.id == categoryId }) {
                            Circle()
                                .fill(Color(hex: category.color) ?? .blue)
                                .frame(width: 8, height: 8)
                        } else {
                            Image(systemName: "folder.fill")
                                .font(.system(size: 11))
                        }
                        
                        Text(selectedCategoryForNewItem == nil ? "General" : viewModel.categoryManager.category(for: selectedCategoryForNewItem ?? UUID()).name)
                            .font(.system(size: 12, weight: .medium))
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.systemGray6)
                    )
                }
                .buttonStyle(.plain)
                
                Menu {
                    ForEach(Priority.allCases, id: \.self) { priority in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.selectedPriority = priority
                            }
                        } label: {
                            Label(priority.rawValue, systemImage: priority.icon)
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: viewModel.selectedPriority.icon)
                            .font(.system(size: 11))
                            .foregroundColor(viewModel.selectedPriority != .none ? viewModel.selectedPriority.color : .secondary)
                        
                        Text(viewModel.selectedPriority.rawValue)
                            .font(.system(size: 12, weight: .medium))
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.systemGray6)
                    )
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: -2)
        )
    }
}

// MARK: - Counter Section View
struct CounterSectionView: View {
    @ObservedObject var viewModel: ChecklistViewModel
    var onClearAll: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.successGreen)
                    
                    Text("\(viewModel.completedCount) of \(viewModel.totalCount) completed")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .contentTransition(.numericText())
                }
                
                Spacer()
                
                // Sort menu
                if !viewModel.items.isEmpty {
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.sortOption = option
                                }
                            } label: {
                                Label(option.rawValue, systemImage: viewModel.sortOption == option ? "checkmark" : "")
                            }
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 11, weight: .medium))
                            Text(viewModel.sortOption.rawValue)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.systemGray6)
                        )
                    }
                    .buttonStyle(.plain)
                }
                
                // Clear All button
                if viewModel.totalCount > 0 {
                    Button(action: onClearAll) {
                        Text("Clear All")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.red)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.red.opacity(0.1))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Progress bar
            if viewModel.totalCount > 0 {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.systemGray5)
                            .frame(height: 4)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.primaryAccent, Color.primaryAccent.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: max(4, geometry.size.width * CGFloat(viewModel.completedCount) / CGFloat(viewModel.totalCount)),
                                height: 4
                            )
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.completedCount)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.completedCount)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.totalCount)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    @ObservedObject var viewModel: ChecklistViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.primaryAccent.opacity(0.1))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: viewModel.debouncedSearchText.isEmpty ? "checklist" : "magnifyingglass")
                        .font(.system(size: 50, weight: .light))
                        .foregroundColor(.primaryAccent.opacity(0.6))
                        .symbolEffect(.pulse, options: .repeating.speed(0.5))
                }
                
                VStack(spacing: 8) {
                    Text(viewModel.debouncedSearchText.isEmpty ? "No items yet" : "No items found")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(viewModel.debouncedSearchText.isEmpty ? 
                         "Start by adding your first task above" :
                         "Try adjusting your search or filters")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 50)
                        .lineSpacing(4)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.clear)
                        .padding(.horizontal, 4)
                )
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

