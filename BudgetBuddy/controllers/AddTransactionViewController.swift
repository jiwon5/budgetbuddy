// Controllers/AddTransactionViewController.swift

import UIKit

// MARK: - Delegate Protocol (입력 완료 후 부모 VC에 데이터 전달)
protocol AddTransactionDelegate: AnyObject {
    func didAddTransaction(_ transaction: Transaction)
}

class AddTransactionViewController: UIViewController {

    // MARK: - Properties
    weak var delegate: AddTransactionDelegate?
    private var selectedType: TransactionType = .expense
    private var selectedCategory: Category = .food
    private var selectedPayment: PaymentMethod = .creditCard
    private var selectedDate: Date = Date()

    // MARK: - UI Components

    // 상단 세그먼트 (수입 / 지출)
    private let typeSegmentControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["지출", "수입"])
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = .systemRed
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    // 금액 입력 필드
    private let amountTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "금액을 입력하세요"
        tf.keyboardType = .numberPad
        tf.font = .systemFont(ofSize: 28, weight: .bold)
        tf.textAlignment = .center
        tf.borderStyle = .none
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let amountUnderlineView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemGray4
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let wonLabel: UILabel = {
        let l = UILabel()
        l.text = "원"
        l.font = .systemFont(ofSize: 20, weight: .medium)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // 날짜 선택
    private let datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        dp.preferredDatePickerStyle = .compact
        dp.locale = Locale(identifier: "ko_KR")
        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }()

    // 카테고리 선택 버튼
    private let categoryButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("🍽️  식비", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        btn.contentHorizontalAlignment = .left
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // 결제 수단 선택 버튼
    private let paymentButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("💳  신용카드", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        btn.contentHorizontalAlignment = .left
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // 메모 입력 필드
    private let memoTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "메모 (선택)"
        tf.font = .systemFont(ofSize: 15)
        tf.borderStyle = .none
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    // 저장 버튼
    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("저장하기", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemRed
        btn.layer.cornerRadius = 14
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - 섹션 카드 뷰 (배경 흰색 카드)
    private func makeCardView() -> UIView {
        let v = UIView()
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }

    private func makeRowLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 14, weight: .medium)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private func makeSeparator() -> UIView {
        let v = UIView()
        v.backgroundColor = .systemGray5
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "내역 추가"
        setupNavigationBar()
        setupLayout()
        setupActions()
    }

    // MARK: - Navigation Bar
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(didTapCancel)
        )
    }

    // MARK: - Layout
    private func setupLayout() {
        // --- 금액 카드 ---
        let amountCard = makeCardView()
        view.addSubview(amountCard)

        let amountRow = UIView()
        amountRow.translatesAutoresizingMaskIntoConstraints = false
        amountCard.addSubview(typeSegmentControl)
        amountCard.addSubview(amountRow)

        amountRow.addSubview(amountTextField)
        amountRow.addSubview(wonLabel)
        amountCard.addSubview(amountUnderlineView)

        NSLayoutConstraint.activate([
            amountCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            amountCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            amountCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            typeSegmentControl.topAnchor.constraint(equalTo: amountCard.topAnchor, constant: 16),
            typeSegmentControl.leadingAnchor.constraint(equalTo: amountCard.leadingAnchor, constant: 16),
            typeSegmentControl.trailingAnchor.constraint(equalTo: amountCard.trailingAnchor, constant: -16),
            typeSegmentControl.heightAnchor.constraint(equalToConstant: 36),

            amountRow.topAnchor.constraint(equalTo: typeSegmentControl.bottomAnchor, constant: 16),
            amountRow.leadingAnchor.constraint(equalTo: amountCard.leadingAnchor, constant: 16),
            amountRow.trailingAnchor.constraint(equalTo: amountCard.trailingAnchor, constant: -16),
            amountRow.heightAnchor.constraint(equalToConstant: 44),

            amountTextField.leadingAnchor.constraint(equalTo: amountRow.leadingAnchor),
            amountTextField.centerYAnchor.constraint(equalTo: amountRow.centerYAnchor),
            amountTextField.trailingAnchor.constraint(equalTo: wonLabel.leadingAnchor, constant: -4),

            wonLabel.trailingAnchor.constraint(equalTo: amountRow.trailingAnchor),
            wonLabel.centerYAnchor.constraint(equalTo: amountRow.centerYAnchor),
            wonLabel.widthAnchor.constraint(equalToConstant: 24),

            amountUnderlineView.topAnchor.constraint(equalTo: amountRow.bottomAnchor, constant: 4),
            amountUnderlineView.leadingAnchor.constraint(equalTo: amountCard.leadingAnchor, constant: 16),
            amountUnderlineView.trailingAnchor.constraint(equalTo: amountCard.trailingAnchor, constant: -16),
            amountUnderlineView.heightAnchor.constraint(equalToConstant: 1),
            amountUnderlineView.bottomAnchor.constraint(equalTo: amountCard.bottomAnchor, constant: -16),
        ])

        // --- 상세 정보 카드 ---
        let infoCard = makeCardView()
        view.addSubview(infoCard)

        let dateLabel = makeRowLabel("날짜")
        let sep1 = makeSeparator()
        let categoryLabel = makeRowLabel("카테고리")
        let sep2 = makeSeparator()
        let paymentLabel = makeRowLabel("결제 수단")
        let sep3 = makeSeparator()
        let memoLabel = makeRowLabel("메모")

        for sub in [dateLabel, datePicker, sep1,
                    categoryLabel, categoryButton, sep2,
                    paymentLabel, paymentButton, sep3,
                    memoLabel, memoTextField] {
            infoCard.addSubview(sub)
        }

        NSLayoutConstraint.activate([
            infoCard.topAnchor.constraint(equalTo: amountCard.bottomAnchor, constant: 16),
            infoCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            infoCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // 날짜 행
            dateLabel.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 14),
            dateLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            datePicker.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),

            sep1.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 14),
            sep1.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            sep1.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor),
            sep1.heightAnchor.constraint(equalToConstant: 0.5),

            // 카테고리 행
            categoryLabel.topAnchor.constraint(equalTo: sep1.bottomAnchor, constant: 14),
            categoryLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            categoryButton.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),

            sep2.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 14),
            sep2.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            sep2.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor),
            sep2.heightAnchor.constraint(equalToConstant: 0.5),

            // 결제 수단 행
            paymentLabel.topAnchor.constraint(equalTo: sep2.bottomAnchor, constant: 14),
            paymentLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            paymentButton.centerYAnchor.constraint(equalTo: paymentLabel.centerYAnchor),
            paymentButton.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),

            sep3.topAnchor.constraint(equalTo: paymentLabel.bottomAnchor, constant: 14),
            sep3.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            sep3.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor),
            sep3.heightAnchor.constraint(equalToConstant: 0.5),

            // 메모 행
            memoLabel.topAnchor.constraint(equalTo: sep3.bottomAnchor, constant: 14),
            memoLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 16),
            memoTextField.centerYAnchor.constraint(equalTo: memoLabel.centerYAnchor),
            memoTextField.leadingAnchor.constraint(equalTo: memoLabel.trailingAnchor, constant: 12),
            memoTextField.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -16),
            memoTextField.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -14),
        ])

        // --- 저장 버튼 ---
        view.addSubview(saveButton)
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 54),
        ])
    }

    // MARK: - Actions
    private func setupActions() {
        typeSegmentControl.addTarget(self, action: #selector(typeChanged), for: .valueChanged)
        categoryButton.addTarget(self, action: #selector(didTapCategory), for: .touchUpInside)
        paymentButton.addTarget(self, action: #selector(didTapPayment), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)

        // 빈 화면 탭 시 키보드 내리기
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func typeChanged() {
        selectedType = typeSegmentControl.selectedSegmentIndex == 0 ? .expense : .income
        let accentColor = selectedType == .expense ? UIColor.systemRed : UIColor.bbLeaf
        typeSegmentControl.selectedSegmentTintColor = accentColor
        saveButton.backgroundColor = accentColor

        let availableCategories = Category.allCases.filter { $0.transactionType == selectedType }
        if let first = availableCategories.first, !availableCategories.contains(selectedCategory) {
            selectedCategory = first
            categoryButton.setTitle("\(first.icon)  \(first.rawValue)", for: .normal)
        }
    }

    @objc private func didTapCategory() {
        let alert = UIAlertController(title: "카테고리 선택", message: nil, preferredStyle: .actionSheet)
        for cat in Category.allCases where cat.transactionType == selectedType {
            alert.addAction(UIAlertAction(title: "\(cat.icon)  \(cat.rawValue)", style: .default) { [weak self] _ in
                self?.selectedCategory = cat
                self?.categoryButton.setTitle("\(cat.icon)  \(cat.rawValue)", for: .normal)
            })
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func didTapPayment() {
        let alert = UIAlertController(title: "결제 수단 선택", message: nil, preferredStyle: .actionSheet)
        for method in PaymentMethod.allCases {
            alert.addAction(UIAlertAction(title: "\(method.icon)  \(method.rawValue)", style: .default) { [weak self] _ in
                self?.selectedPayment = method
                self?.paymentButton.setTitle("\(method.icon)  \(method.rawValue)", for: .normal)
            })
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func didTapSave() {
        guard let amountText = amountTextField.text,
              let amount = Int(amountText.replacingOccurrences(of: ",", with: "")),
              amount > 0 else {
            showAmountError()
            return
        }

        let transaction = Transaction(
            type: selectedType,
            amount: amount,
            date: datePicker.date,
            category: selectedCategory,
            paymentMethod: selectedPayment,
            memo: memoTextField.text ?? ""
        )

        delegate?.didAddTransaction(transaction)
        dismiss(animated: true)
    }

    @objc private func didTapCancel() {
        dismiss(animated: true)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - 금액 미입력 오류 알림
    private func showAmountError() {
        let alert = UIAlertController(title: "금액을 입력해주세요", message: "0보다 큰 금액을 입력해야 합니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)

        // 언더라인 빨간색으로 강조
        amountUnderlineView.backgroundColor = .systemRed
        UIView.animate(withDuration: 0.3, delay: 1.0) {
            self.amountUnderlineView.backgroundColor = .systemGray4
        }
    }
}
