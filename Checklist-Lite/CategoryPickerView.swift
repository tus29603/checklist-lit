//
//  CategoryPickerView.swift
//  Checklist-Lite
//
//  Created by Tesfaldet Haileab on 12/12/25.
//

import SwiftUI

struct CategoryPickerView: View {
    @ObservedObject var categoryManager: CategoryManager
    @Binding var selectedCategoryId: UUID?
    
    var body: some View {
        Menu {
            Button {
                selectedCategoryId = nil
            } label: {
                Label("All Categories", systemImage: selectedCategoryId == nil ? "checkmark" : "")
            }
            
            Divider()
            
            ForEach(categoryManager.categories) { category in
                Button {
                    selectedCategoryId = category.id
                } label: {
                    Label(category.name, systemImage: selectedCategoryId == category.id ? "checkmark" : "")
                }
            }
        } label: {
            HStack(spacing: 6) {
                if let categoryId = selectedCategoryId,
                   let category = categoryManager.categories.first(where: { $0.id == categoryId }) {
                    Circle()
                        .fill(Color(hex: category.color) ?? .blue)
                        .frame(width: 10, height: 10)
                    
                    Text(category.name)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                } else {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 11))
                    
                    Text("Category")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                }
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .semibold))
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
    }
}


#Preview {
    CategoryPickerView(
        categoryManager: CategoryManager(),
        selectedCategoryId: .constant(nil)
    )
}

