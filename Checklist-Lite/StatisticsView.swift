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
                Section {
                    StatRow(
                        icon: "list.bullet",
                        iconColor: .primaryAccent,
                        title: "Total Items",
                        value: "\(viewModel.totalCount)"
                    )
                    
                    StatRow(
                        icon: "checkmark.circle.fill",
                        iconColor: .successGreen,
                        title: "Completed",
                        value: "\(viewModel.completedCount)"
                    )
                    
                    StatRow(
                        icon: "circle",
                        iconColor: .orange,
                        title: "Active",
                        value: "\(viewModel.items.filter { $0.status == .active }.count)"
                    )
                    
                    StatRow(
                        icon: "archivebox.fill",
                        iconColor: .secondaryGray,
                        title: "Archived",
                        value: "\(viewModel.items.filter { $0.status == .archived }.count)"
                    )
                } header: {
                    Text("Overview")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.primaryAccent)
                            .frame(width: 24, height: 24)
                        
                        Text("Completion Rate")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(Int(viewModel.completionPercentage * 100))%")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.primaryAccent)
                    }
                    .padding(.vertical, 4)
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.systemGray5)
                                .frame(height: 6)
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.primaryAccent, Color.primaryAccent.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(
                                    width: max(6, geometry.size.width * CGFloat(viewModel.completionPercentage)),
                                    height: 6
                                )
                                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.completionPercentage)
                        }
                    }
                    .frame(height: 6)
                    .padding(.vertical, 8)
                } header: {
                    Text("Completion")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            #if os(iOS) || os(visionOS)
            .listStyle(.insetGrouped)
            #elseif os(macOS)
            .listStyle(.sidebar)
            #endif
            .navigationTitle("Statistics")
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
        }
    }
}

struct StatRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary.opacity(0.8))
        }
        .padding(.vertical, 4)
    }
}

