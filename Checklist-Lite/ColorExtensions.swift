//
//  ColorExtensions.swift
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

// Design System Colors
extension Color {
    static let primaryAccent = Color(red: 0.04, green: 0.52, blue: 1.0) // #0A84FF
    static let successGreen = Color(red: 0.20, green: 0.78, blue: 0.35) // #34C759
    static let secondaryGray = Color(red: 0.56, green: 0.56, blue: 0.58) // #8E8E93
    static let systemGroupedBackground = Color(red: 0.95, green: 0.95, blue: 0.97) // #F2F2F7
    
    // Platform-specific system colors
    #if os(iOS) || os(visionOS)
    static let systemGray4 = Color(uiColor: .systemGray4)
    static let systemGray5 = Color(uiColor: .systemGray5)
    static let systemGray6 = Color(uiColor: .systemGray6)
    #elseif os(macOS)
    static let systemGray4 = Color(nsColor: .separatorColor)
    static let systemGray5 = Color(nsColor: .controlBackgroundColor)
    static let systemGray6 = Color(nsColor: .controlBackgroundColor).opacity(0.5)
    #else
    static let systemGray4 = Color.gray.opacity(0.3)
    static let systemGray5 = Color.gray.opacity(0.2)
    static let systemGray6 = Color.gray.opacity(0.1)
    #endif
}

