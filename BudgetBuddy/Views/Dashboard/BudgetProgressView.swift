// Views/Dashboard/BudgetProgressView.swift

import UIKit

// MARK: - 목표 지출액 게이지 바 (커스텀 UIView)
final class BudgetProgressView: UIView {

    // MARK: - Properties
    private var progressRate: Double = 0.0  // 0.0 ~ 1.0

    // MARK: - UI
    private let trackLayer = CALayer()      // 배경 트랙
    private let fillLayer  = CALayer()      // 채워지는 바

    private let percentLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = .bbLeafDark
        l.setContentHuggingPriority(.required, for: .horizontal)
        l.setContentCompressionResistancePriority(.required, for: .horizontal)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let budgetLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryLabel
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.82
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        setupLabels()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupLayers() {
        trackLayer.backgroundColor = UIColor.systemGray5.cgColor
        trackLayer.cornerRadius = 10
        layer.addSublayer(trackLayer)

        fillLayer.cornerRadius = 10
        fillLayer.backgroundColor = UIColor.bbLeaf.cgColor
        layer.addSublayer(fillLayer)
    }

    private func setupLabels() {
        addSubview(percentLabel)
        addSubview(budgetLabel)
        NSLayoutConstraint.activate([
            percentLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            percentLabel.bottomAnchor.constraint(equalTo: topAnchor, constant: -4),
            budgetLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            budgetLabel.trailingAnchor.constraint(lessThanOrEqualTo: percentLabel.leadingAnchor, constant: -8),
            budgetLabel.bottomAnchor.constraint(equalTo: topAnchor, constant: -4),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let h = bounds.height
        trackLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: h)
        let fillWidth = bounds.width * CGFloat(min(progressRate, 1.0))
        fillLayer.frame = CGRect(x: 0, y: 0, width: fillWidth, height: h)
        updateFillColor()
    }

    // MARK: - Public
    func update(spent: Int, budget: Int) {
        guard budget > 0 else { return }
        progressRate = Double(spent) / Double(budget)

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let spentStr  = formatter.string(from: NSNumber(value: spent))  ?? "0"
        let budgetStr = formatter.string(from: NSNumber(value: budget)) ?? "0"

        percentLabel.text = "\(Int(min(progressRate * 100, 100)))% 사용"
        budgetLabel.text  = "총지출 \(spentStr)원 / 목표 \(budgetStr)원"

        setNeedsLayout()
    }

    private func updateFillColor() {
        switch progressRate {
        case ..<0.5:  fillLayer.backgroundColor = UIColor.bbMint.cgColor
        case ..<0.8:  fillLayer.backgroundColor = UIColor.bbLeaf.cgColor
        default:      fillLayer.backgroundColor = UIColor.bbLeafDark.cgColor
        }
    }
}
