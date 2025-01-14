//
//  AdManager.swift
//  AdmobTest
//
//  Created by Haider on 14/01/2025.
//

import Foundation
import GoogleMobileAds
import UIKit

// MARK: - Ad Configuration
struct AdMobConfig {
    static let appOpenAdUnitID = "ca-app-pub-3940256099942544/5575463023"
    static let bannerAdUnitID = "ca-app-pub-3940256099942544/2435281174"
    static let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"
    static let rewardedAdUnitID = "ca-app-pub-3940256099942544/1712485313"
    static let nativeAdUnitID = "ca-app-pub-3940256099942544/3986624511"
}

// MARK: - Ad Manager
class AdManager: NSObject {
    static let shared = AdManager()
    
    // Ad Properties
    var appOpenAd: GADAppOpenAd?
    var interstitialAd: GADInterstitialAd?
    var rewardedAd: GADRewardedAd?
    var nativeAd: GADNativeAd?
    
    // State Management
    private var isLoadingAppOpenAd = false
    private var isLoadingInterstitial = false
    private var isLoadingRewarded = false
    private var isShowingAd = false
    
    // Completion Handlers
    private var rewardCompletion: ((Bool) -> Void)?
    
    private override init() {
        super.init()
        setupAds()
    }
    
    // MARK: - Setup
    private func setupAds() {
        print("📱 Setting up AdMob...")
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ GADSimulatorID ]
        
        GADMobileAds.sharedInstance().start { [weak self] status in
            print("📱 AdMob SDK initialization completed")
            self?.loadAllAds()
        }
    }
    
    private func loadAllAds() {
        print("📱 Starting to load all ads")
        loadInterstitialAd()
        loadRewardedAd()
        loadAppOpenAd()
    }
    
    // MARK: - App Open Ads
    private func loadAppOpenAd() {
        guard !isLoadingAppOpenAd else { return }
        isLoadingAppOpenAd = true
        
        GADAppOpenAd.load(withAdUnitID: AdMobConfig.appOpenAdUnitID,
                         request: GADRequest()) { [weak self] ad, error in
            guard let self = self else { return }
            self.isLoadingAppOpenAd = false
            
            if let error = error {
                print("❌ Failed to load app open ad: \(error.localizedDescription)")
                return
            }
            print("✅ App Open ad loaded successfully")
            self.appOpenAd = ad
        }
    }
    
    func showAppOpenAd(from viewController: UIViewController) {
        guard let appOpenAd = appOpenAd, !isShowingAd else { return }
        
        appOpenAd.fullScreenContentDelegate = self
        appOpenAd.present(fromRootViewController: viewController)
        isShowingAd = true
        loadAppOpenAd() // Preload next ad
    }
    
    // MARK: - Interstitial Ads
    private func loadInterstitialAd() {
        guard !isLoadingInterstitial else { return }
        isLoadingInterstitial = true
        print("📱 Loading Interstitial Ad...")
        
        GADInterstitialAd.load(withAdUnitID: AdMobConfig.interstitialAdUnitID,
                              request: GADRequest()) { [weak self] ad, error in
            guard let self = self else { return }
            self.isLoadingInterstitial = false
            
            if let error = error {
                print("❌ Failed to load interstitial ad: \(error.localizedDescription)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.loadInterstitialAd()
                }
                return
            }
            print("✅ Interstitial ad loaded successfully")
            self.interstitialAd = ad
        }
    }
    
    func showInterstitial(from viewController: UIViewController) {
        guard let interstitialAd = interstitialAd, !isShowingAd else { return }
        
        interstitialAd.fullScreenContentDelegate = self
        interstitialAd.present(fromRootViewController: viewController)
        isShowingAd = true
        loadInterstitialAd() // Preload next ad
    }
    
    // MARK: - Rewarded Ads
    private func loadRewardedAd() {
        guard !isLoadingRewarded else { return }
        isLoadingRewarded = true
        print("📱 Loading Rewarded Ad...")
        
        GADRewardedAd.load(withAdUnitID: AdMobConfig.rewardedAdUnitID,
                          request: GADRequest()) { [weak self] ad, error in
            guard let self = self else { return }
            self.isLoadingRewarded = false
            
            if let error = error {
                print("❌ Failed to load rewarded ad: \(error.localizedDescription)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.loadRewardedAd()
                }
                return
            }
            print("✅ Rewarded ad loaded successfully")
            self.rewardedAd = ad
        }
    }
    
    func showRewardedAd(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        guard let rewardedAd = rewardedAd, !isShowingAd else {
            completion(false)
            return
        }
        
        self.rewardCompletion = completion
        rewardedAd.fullScreenContentDelegate = self
        rewardedAd.present(fromRootViewController: viewController) { [weak self] in
            self?.rewardCompletion?(true)
            self?.rewardCompletion = nil
        }
        isShowingAd = true
        loadRewardedAd() // Preload next ad
    }
    
    // MARK: - Banner Ads
    func createBannerView(in viewController: UIViewController) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = AdMobConfig.bannerAdUnitID
        bannerView.rootViewController = viewController
        bannerView.load(GADRequest())
        return bannerView
    }
}

// MARK: - GADFullScreenContentDelegate
extension AdManager: GADFullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        isShowingAd = false
        
        // Ensure we have ads ready for next time
        if interstitialAd == nil {
            loadInterstitialAd()
        }
        if rewardedAd == nil {
            loadRewardedAd()
        }
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        isShowingAd = false
        print("❌ Failed to present ad: \(error.localizedDescription)")
        
        // Reload the failed ad type
        if ad is GADInterstitialAd {
            loadInterstitialAd()
        } else if ad is GADRewardedAd {
            loadRewardedAd()
        }
    }
}
