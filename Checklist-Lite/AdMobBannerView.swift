//
//  AdMobBannerView.swift
//  Checklist-Lite
//
//  Created by Tesfaldet Haileab on 12/12/25.
//

import SwiftUI

#if os(iOS) || os(visionOS)
import UIKit
import GoogleMobileAds

struct AdMobBannerView: UIViewRepresentable {
    // Ad unit ID - easily switchable between test and production
    // TEST: ca-app-pub-3940256099942544/2934735716
    // PRODUCTION: ca-app-pub-8853742472105910/4965067318
    private let adUnitID: String
    
    init(adUnitID: String = "ca-app-pub-3940256099942544/2934735716") {
        self.adUnitID = adUnitID
    }
    
    func makeUIView(context: Context) -> BannerView {
        // Use standard banner size (320x50 for iPhone)
        let banner = BannerView(adSize: AdSize(size: CGSize(width: 320, height: 50), flags: 0))
        banner.adUnitID = adUnitID
        
        // Set delegate first
        banner.delegate = context.coordinator
        
        // Don't set root view controller or load ad here - wait for updateUIView
        // This prevents crashes if called before the view hierarchy is ready
        
        return banner
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {
        // Ensure root view controller is set before loading ads
        if uiView.rootViewController == nil {
            setRootViewController(for: uiView)
        }
        
        // Only load ad if:
        // 1. Root view controller is available
        // 2. Ad hasn't been loaded yet
        // 3. Ad unit ID matches
        if uiView.rootViewController != nil && 
           !context.coordinator.hasLoaded && 
           uiView.adUnitID == adUnitID {
            // Delay slightly to ensure SDK is fully initialized
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.loadAd(for: uiView)
            }
        }
        
        // Update ad unit ID if changed
        if uiView.adUnitID != adUnitID {
            uiView.adUnitID = adUnitID
            context.coordinator.hasLoaded = false // Reset loaded state
            if uiView.rootViewController != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.loadAd(for: uiView)
                }
            }
        }
    }
    
    private func setRootViewController(for banner: BannerView) {
        // Safely get root view controller for modern iOS
        guard banner.rootViewController == nil else { return }
        
        // Try to get the key window first (most reliable)
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
           let rootViewController = keyWindow.rootViewController {
            banner.rootViewController = rootViewController
            return
        }
        
        // Fallback: get any foreground window
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
           let rootViewController = windowScene.windows.first?.rootViewController {
            banner.rootViewController = rootViewController
            return
        }
        
        // Last resort: get first available window
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            banner.rootViewController = rootViewController
        }
    }
    
    private func loadAd(for banner: BannerView) {
        // Ensure we have a root view controller before loading
        guard let rootViewController = banner.rootViewController else {
            print("AdMob: Cannot load ad - root view controller not available")
            return
        }
        
        // Ensure banner has an ad unit ID
        guard banner.adUnitID != nil && !banner.adUnitID!.isEmpty else {
            print("AdMob: Cannot load ad - ad unit ID is missing")
            return
        }
        
        // Configure ad request
        let request = Request()
        request.requestAgent = "Checklist-Lite"
        
        // Load the ad once - banner will handle refresh automatically but not aggressively
        banner.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, BannerViewDelegate {
        var hasLoaded = false
        
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            hasLoaded = true
            print("AdMob: Banner ad loaded successfully")
        }
        
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("AdMob: Banner ad failed to load - \(error.localizedDescription)")
        }
        
        func bannerViewWillPresentScreen(_ bannerView: BannerView) {
            print("AdMob: Banner ad will present screen")
        }
        
        func bannerViewWillDismissScreen(_ bannerView: BannerView) {
            print("AdMob: Banner ad will dismiss screen")
        }
        
        func bannerViewDidDismissScreen(_ bannerView: BannerView) {
            print("AdMob: Banner ad did dismiss screen")
        }
    }
}

#Preview {
    AdMobBannerView()
        .frame(height: 50)
        .background(Color.gray.opacity(0.1))
}

#else
// Placeholder for non-iOS platforms
struct AdMobBannerView: View {
    var body: some View {
        EmptyView()
    }
}
#endif

