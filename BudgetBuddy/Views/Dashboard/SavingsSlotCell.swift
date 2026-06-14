// Views/Dashboard/SavingsSlotCell.swift

import UIKit

// MARK: - Delegate
protocol SavingsSlotCellDelegate: AnyObject {
    func didTapQuickAdd(goalID: UUID, amount: Int)
}

final class SavingsSlotCell: UITableViewCell {

    static let reuseID = "SavingsSlotCell"
    weak var delegate: SavingsSlotCellDelegate?
    private var goalID: UUID?

    // MARK: - UI
    private let emojiLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 28)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let remainLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let progressBar: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .default)
        pv.trackTintColor = .systemGray5
        pv.progressTintColor = .bbLeaf
        pv.layer.cornerRadius = 3
        pv.clipsToBounds = true
        pv.translatesAutoresizingMaskIntoConstraints = false
        return pv
    }()

    private let percentLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .bold)
        l.textColor = .bbLeaf
        l.textAlignment = .right
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let quickAddStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 6
        sv.distribution = .fillEqually
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let completedBadge: UILabel = {
        let l = UILabel()
        l.text = "🎉 달성 완료!"
        l.font = .systemFont(ofSize: 13, weight: .bold)
        l.textColor = .bbLeaf
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupLayout()
        buildQuickAddButtons()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupLayout() {
        contentView.addSubview(emojiLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(remainLabel)
        contentView.addSubview(progressBar)
        contentView.addSubview(percentLabel)
        contentView.addSubview(quickAddStack)
        contentView.addSubview(completedBadge)

        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiLabel.widthAnchor.constraint(equalToConstant: 36),

            titleLabel.topAnchor.constraint(equalTo: emojiLabel.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: percentLabel.leadingAnchor, constant: -8),

            percentLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            percentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            percentLabel.widthAnchor.constraint(equalToConstant: 44),

            remainLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            remainLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            progressBar.topAnchor.constraint(equalTo: remainLabel.bottomAnchor, constant: 8),
            progressBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            progressBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            progressBar.heightAnchor.constraint(equalToConstant: 6),

            quickAddStack.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 10),
            quickAddStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            quickAddStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            quickAddStack.heightAnchor.constraint(equalToConstant: 30),
            quickAddStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),

            completedBadge.centerYAnchor.constraint(equalTo: quickAddStack.centerYAnchor),
            completedBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }

    private func buildQuickAddButtons() {
        SavingsGoal.quickAddAmounts.forEach { amount in
            let btn = UIButton(type: .system)
            let title = amount >= 10_000 ? "+\(amount/10_000)만" : "+\(amount/1_000)천"
            btn.setTitle(title, for: .normal)
            btn.setTitleColor(.bbLeaf, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
            btn.backgroundColor = UIColor.bbLeafTint(0.10)
            btn.layer.cornerRadius = 8
            btn.tag = amount
            btn.addTarget(self, action: #selector(didTapQuickAdd(_:)), for: .touchUpInside)
            quickAddStack.addArrangedSubview(btn)
        }
    }

    @objc private func didTapQuickAdd(_ sender: UIButton) {
        guard let id = goalID else { return }
        delegate?.didTapQuickAdd(goalID: id, amount: sender.tag)
    }

    // MARK: - Configure
    func configure(with goal: SavingsGoal) {
        goalID = goal.id
        emojiLabel.text   = goal.emoji
        titleLabel.text   = goal.title
        remainLabel.text  = goal.formattedRemainingAmount
        percentLabel.text = goal.progressPercentText
        progressBar.setProgress(Float(goal.progressRate), animated: false)

        let completed = goal.isCompleted
        quickAddStack.isHidden  = completed
        completedBadge.isHidden = !completed
    }
}
