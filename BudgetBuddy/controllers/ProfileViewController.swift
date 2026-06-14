// Controllers/ProfileViewController.swift

import UIKit

final class ProfileViewController: UIViewController {

    private let store = LedgerStore.shared

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let profileCard = ProfileViewController.makeCard()
    private let summaryCard = ProfileViewController.makeCard()
    private let settingsCard = ProfileViewController.makeCard()

    private let savingsGoalCountLabel = ProfileViewController.makeValueLabel()
    private let targetZeroDaysLabel = ProfileViewController.makeValueLabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "프로필"
        setupLayout()
        updateSummary()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSummary()
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -32),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
        ])

        setupProfileCard()
        setupSummaryCard()
        setupSettingsCard()
    }

    private func setupProfileCard() {
        let avatarView = UIView()
        avatarView.backgroundColor = UIColor.bbLeafTint(0.16)
        avatarView.layer.cornerRadius = 34
        avatarView.translatesAutoresizingMaskIntoConstraints = false

        let avatarIcon = UIImageView(image: UIImage(systemName: "person.fill"))
        avatarIcon.tintColor = .bbLeaf
        avatarIcon.contentMode = .scaleAspectFit
        avatarIcon.translatesAutoresizingMaskIntoConstraints = false
        avatarView.addSubview(avatarIcon)

        let titleLabel = UILabel()
        titleLabel.text = "BudgetBuddy 사용자"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.text = "나의 소비 습관과 목표를 관리해요"
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 5
        textStack.translatesAutoresizingMaskIntoConstraints = false

        profileCard.addSubview(avatarView)
        profileCard.addSubview(textStack)

        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: profileCard.topAnchor, constant: 18),
            avatarView.leadingAnchor.constraint(equalTo: profileCard.leadingAnchor, constant: 18),
            avatarView.bottomAnchor.constraint(equalTo: profileCard.bottomAnchor, constant: -18),
            avatarView.widthAnchor.constraint(equalToConstant: 68),
            avatarView.heightAnchor.constraint(equalToConstant: 68),

            avatarIcon.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarIcon.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            avatarIcon.widthAnchor.constraint(equalToConstant: 30),
            avatarIcon.heightAnchor.constraint(equalToConstant: 30),

            textStack.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 14),
            textStack.trailingAnchor.constraint(equalTo: profileCard.trailingAnchor, constant: -18),
            textStack.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
        ])

        contentStack.addArrangedSubview(profileCard)
    }

    private func setupSummaryCard() {
        let titleLabel = makeSectionTitle("내 정보")
        let rows = UIStackView(arrangedSubviews: [
            makeInfoRow(title: "저축 목표", valueLabel: savingsGoalCountLabel),
            makeInfoRow(title: "무지출 목표", valueLabel: targetZeroDaysLabel)
        ])
        rows.axis = .vertical
        rows.spacing = 12
        rows.translatesAutoresizingMaskIntoConstraints = false

        summaryCard.addSubview(titleLabel)
        summaryCard.addSubview(rows)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: summaryCard.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -16),

            rows.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            rows.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 16),
            rows.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -16),
            rows.bottomAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: -16),
        ])

        contentStack.addArrangedSubview(summaryCard)
    }

    private func setupSettingsCard() {
        let titleLabel = makeSectionTitle("설정")
        let rows = UIStackView(arrangedSubviews: [
            makeSettingRow(iconName: "bell", title: "알림 설정"),
            makeSettingRow(iconName: "lock", title: "개인정보 보호"),
            makeSettingRow(iconName: "questionmark.circle", title: "도움말")
        ])
        rows.axis = .vertical
        rows.spacing = 2
        rows.translatesAutoresizingMaskIntoConstraints = false

        settingsCard.addSubview(titleLabel)
        settingsCard.addSubview(rows)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: settingsCard.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: settingsCard.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: settingsCard.trailingAnchor, constant: -16),

            rows.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            rows.leadingAnchor.constraint(equalTo: settingsCard.leadingAnchor),
            rows.trailingAnchor.constraint(equalTo: settingsCard.trailingAnchor),
            rows.bottomAnchor.constraint(equalTo: settingsCard.bottomAnchor, constant: -8),
        ])

        contentStack.addArrangedSubview(settingsCard)
    }

    private func updateSummary() {
        savingsGoalCountLabel.text = "\(store.savingsGoals.count)개"
        targetZeroDaysLabel.text = "\(store.targetZeroDays)일"
    }

    private static func makeCard() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func makeSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func makeInfoRow(title: String, valueLabel: UILabel) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(titleLabel)
        container.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 48),

            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])

        return container
    }

    private func makeSettingRow(iconName: String, title: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.tintColor = .bbLeaf
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronView.tintColor = .tertiaryLabel
        chevronView.contentMode = .scaleAspectFit
        chevronView.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(iconView)
        container.addSubview(titleLabel)
        container.addSubview(chevronView)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 48),

            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronView.leadingAnchor, constant: -12),

            chevronView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            chevronView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: 12),
            chevronView.heightAnchor.constraint(equalToConstant: 12),
        ])

        return container
    }

    private static func makeValueLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .bbLeafDark
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
