//
//  ChecklistLiteApp.swift
//  Checklist-Lite
//
//  Created by Tesfaldet Haileab on 12/12/25.
//

import SwiftUI

#if os(iOS) || os(visionOS)
import GoogleMobileAds
#endif

@main
struct ChecklistLiteApp: App {
    
    init() {
        #if os(iOS) || os(visionOS)
        // Initialize Google Mobile Ads SDK
        // Note: GADApplicationIdentifier must be set in Info.plist
        MobileAds.shared.start { status in
            print("AdMob SDK initialized with adapter statuses: \(status.adapterStatusesByClassName)")
        }
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
