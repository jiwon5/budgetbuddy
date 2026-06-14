// Controllers/SplashViewController.swift

import UIKit

final class SplashViewController: UIViewController {

    var onFinish: (() -> Void)?

    private let logoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 34
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.layer.shadowRadius = 18
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "leaf.fill"))
        imageView.tintColor = .bbLeaf
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "BudgetBuddy"
        label.font = .systemFont(ofSize: 32, weight: .heavy)
        label.textColor = .bbLeafDark
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘의 소비를 가볍게 기록해요"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .bbLeaf
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bbAppBackground
        setupLayout()
        activityIndicator.startAnimating()
        animateIntro()
        finishAfterDelay()
    }

    private func setupLayout() {
        view.addSubview(logoContainerView)
        logoContainerView.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            logoContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -78),
            logoContainerView.widthAnchor.constraint(equalToConstant: 96),
            logoContainerView.heightAnchor.constraint(equalToConstant: 96),

            logoImageView.centerXAnchor.constraint(equalTo: logoContainerView.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: logoContainerView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 46),
            logoImageView.heightAnchor.constraint(equalToConstant: 46),

            titleLabel.topAnchor.constraint(equalTo: logoContainerView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            activityIndicator.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 34),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    private func animateIntro() {
        logoContainerView.alpha = 0
        titleLabel.alpha = 0
        subtitleLabel.alpha = 0
        logoContainerView.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)

        UIView.animate(withDuration: 0.55, delay: 0.12, options: [.curveEaseOut]) {
            self.logoContainerView.alpha = 1
            self.logoContainerView.transform = .identity
        }

        UIView.animate(withDuration: 0.45, delay: 0.34, options: [.curveEaseOut]) {
            self.titleLabel.alpha = 1
            self.subtitleLabel.alpha = 1
        }
    }

    private func finishAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.onFinish?()
        }
    }
}
