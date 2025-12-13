//
//  StatisticsView.swift
//  Checklist-Lite
//
//  Created by Tesfaldet Haileab on 12/12/25.
//

import SwiftUI

struct StatisticsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ChecklistViewModel
    
    var body: some View {
        NavigationStack {
            List {
                Section("Overview") {
                    HStack {
                        Text("Total Items")
                        Spacer()
                        Text("\(viewModel.totalCount)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Completed")
                        Spacer()
                        Text("\(viewModel.completedCount)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Active")
                        Spacer()
                        Text("\(viewModel.items.filter { $0.status == .active }.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Archived")
                        Spacer()
                        Text("\(viewModel.items.filter { $0.status == .archived }.count)")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Completion") {
                    HStack {
                        Text("Completion Rate")
                        Spacer()
                        Text("\(Int(viewModel.completionPercentage * 100))%")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Statistics")
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
        }
    }
}

