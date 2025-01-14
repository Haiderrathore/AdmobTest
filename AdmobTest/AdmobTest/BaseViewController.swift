//
//  BaseViewController.swift
//  AdmobTest
//
//  Created by Haider on 14/01/2025.
//

import UIKit
import GoogleMobileAds

class BaseViewController: UIViewController {
    private var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = AdMobConfig.bannerAdUnitID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        
        // Constraints
        NSLayoutConstraint.activate([
            bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
