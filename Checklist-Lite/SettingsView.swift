//
//  SettingsView.swift
//  Checklist-Lite
//
//  Created by Tesfaldet Haileab on 12/12/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var categoryManager = CategoryManager()
    @State private var showCategories = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        showCategories = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "folder.fill")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.blue)
                                .frame(width: 24, height: 24)
                            
                            Text("Categories")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary.opacity(0.5))
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                } header: {
                    Text("Organization")
                }
                
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Checklist Lite")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                            
                            Text("Version 1.0.0")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("About")
                }
            }
            #if os(iOS) || os(visionOS)
            .listStyle(.insetGrouped)
            #else
            .listStyle(.sidebar)
            #endif
            .navigationTitle("Settings")
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
                            Text("Close")
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
                            Text("Close")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.blue)
                    }
                    .buttonStyle(.bordered)
                }
                #endif
            }
            #if os(iOS) || os(visionOS)
            .fullScreenCover(isPresented: $showCategories) {
                NavigationStack {
                    CategoriesView(categoryManager: categoryManager)
                }
            }
            #else
            .sheet(isPresented: $showCategories) {
                NavigationStack {
                    CategoriesView(categoryManager: categoryManager)
                }
                .frame(minWidth: 500, minHeight: 600)
            }
            #endif
        }
    }
}

#Preview {
    SettingsView()
}

