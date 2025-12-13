//
//  Priority.swift
//  Checklist-Lite
//
//  Created by Tesfaldet Haileab on 12/12/25.
//

import SwiftUI

enum Priority: String, Codable, CaseIterable, Identifiable {
    case none = "None"
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .none: return "circle"
        case .low: return "arrow.down.circle.fill"
        case .medium: return "minus.circle.fill"
        case .high: return "exclamationmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .none: return .secondaryGray
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
}

