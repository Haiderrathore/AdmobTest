import UIKit
import GoogleMobileAds

class TestViewController: UIViewController {
    private var bannerView: GADBannerView?
    private var isLoadingAd = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AdMob Test"
        setupUI()
        setupBannerAd()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = createTitleLabel()
        let interstitialButton = createStyledButton(title: "Show Interstitial Ad", action: #selector(showInterstitial))
        let rewardedButton = createStyledButton(title: "Show Rewarded Ad", action: #selector(showRewarded))
        let appOpenButton = createStyledButton(title: "Show App Open Ad", action: #selector(showAppOpen))
        
        [titleLabel, interstitialButton, rewardedButton, appOpenButton].forEach {
            stackView.addArrangedSubview($0)
        }
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.text = "AdMob Test App"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }
    
    private func createStyledButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        
        // Configure button appearance
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.cornerStyle = .medium
        configuration.buttonSize = .large
        configuration.baseBackgroundColor = .systemBlue
        configuration.baseForegroundColor = .white
        
        // Add shadow effect
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.2
        
        button.configuration = configuration
        button.addTarget(self, action: action, for: .touchUpInside)
        
        return button
    }
    
    private func setupBannerAd() {
        bannerView = AdManager.shared.createBannerView(in: self)
        guard let bannerView = bannerView else { return }
        
        view.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func showInterstitial() {
        guard AdManager.shared.interstitialAd != nil else {
            showAdNotReadyAlert()
            return
        }
        AdManager.shared.showInterstitial(from: self)
    }
    
    @objc private func showRewarded() {
        guard AdManager.shared.rewardedAd != nil else {
            showAdNotReadyAlert()
            return
        }
        AdManager.shared.showRewardedAd(from: self) { rewarded in
            if rewarded {
                self.showRewardAlert()
            }
        }
    }
    
    @objc private func showAppOpen() {
        guard AdManager.shared.appOpenAd != nil else {
            showAdNotReadyAlert()
            return
        }
        AdManager.shared.showAppOpenAd(from: self)
    }
    
    private func showRewardAlert() {
        let alert = UIAlertController(
            title: "Reward Earned! 🎉",
            message: "You've successfully completed watching the rewarded ad!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showAdNotReadyAlert() {
        let alert = UIAlertController(
            title: "Ad Not Ready",
            message: "Please wait a moment and try again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
} 