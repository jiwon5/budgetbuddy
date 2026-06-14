// Controllers/LedgerViewController.swift

import UIKit

class LedgerViewController: UIViewController {

    // MARK: - Data
    private let store = LedgerStore.shared
    private var allTransactions: [Transaction] { store.transactions }
    private var filteredTransactions: [Transaction] = []

    private var currentYear: Int = Calendar.current.component(.year, from: Date())
    private var currentMonth: Int = Calendar.current.component(.month, from: Date())
    private var currentTypeFilter: TransactionType? = nil   // nil = 전체
    private var currentCategory: Category? = nil            // nil = 전체
    private var currentSearchText: String = ""
    private let monthNavigationView = MonthNavigationView()

    // MARK: - UI Components

    // 검색/필터 카드
    private let filterCard: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 22
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 8
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let searchContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.separator.withAlphaComponent(0.5).cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let searchIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        iv.tintColor = .secondaryLabel
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let searchTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "처방 병원, 마트, 식사 세부 명칭 검색..."
        tf.font = .systemFont(ofSize: 15, weight: .semibold)
        tf.textColor = .label
        tf.clearButtonMode = .whileEditing
        tf.returnKeyType = .search
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let filterButtonStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.distribution = .fillEqually
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private lazy var allButton = makeTypeFilterButton(title: "전체 보기", tag: -1)
    private lazy var expenseOnlyButton = makeTypeFilterButton(title: "지출만", tag: 101)
    private lazy var incomeOnlyButton = makeTypeFilterButton(title: "수입만", tag: 100)

    private let categoryFilterRow: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let categoryFilterIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "line.3.horizontal.decrease"))
        iv.tintColor = .secondaryLabel
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let categoryFilterLabel: UILabel = {
        let l = UILabel()
        l.text = "카테고리 필터"
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let categoryButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        btn.contentHorizontalAlignment = .left
        btn.backgroundColor = .secondarySystemGroupedBackground
        btn.layer.cornerRadius = 14
        btn.layer.borderWidth = 0
        btn.tintColor = .label
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // 합산 요약 바
    private let summaryView: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemBackground
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let incomeLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = .bbLeaf
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let expenseLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = .systemRed
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let balanceLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .bold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // 테이블뷰
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .systemGroupedBackground
        tv.separatorStyle = .none
        tv.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.reuseID)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    // 내역 없을 때 빈 화면
    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "내역이 없습니다 🗒️"
        l.textColor = .tertiaryLabel
        l.font = .systemFont(ofSize: 16)
        l.textAlignment = .center
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "장부"
        setupNavigationBar()
        setupLayout()
        setupActions()
        updateFilterControls()
        applyFilters()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyFilters()
    }

    // MARK: - Navigation Bar
    private func setupNavigationBar() {
        navigationItem.titleView = monthNavigationView
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAdd)
        )
        monthNavigationView.onPrevious = { [weak self] in self?.moveMonth(by: -1) }
        monthNavigationView.onNext = { [weak self] in self?.moveMonth(by: 1) }
    }

    // MARK: - Layout
    private func setupLayout() {
        // 검색/필터 카드
        view.addSubview(filterCard)
        filterCard.addSubview(searchContainer)
        searchContainer.addSubview(searchIconView)
        searchContainer.addSubview(searchTextField)

        filterButtonStack.addArrangedSubview(allButton)
        filterButtonStack.addArrangedSubview(expenseOnlyButton)
        filterButtonStack.addArrangedSubview(incomeOnlyButton)
        filterCard.addSubview(filterButtonStack)

        filterCard.addSubview(categoryFilterRow)
        categoryFilterRow.addSubview(categoryFilterIcon)
        categoryFilterRow.addSubview(categoryFilterLabel)
        categoryFilterRow.addSubview(categoryButton)

        NSLayoutConstraint.activate([
            filterCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            filterCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            searchContainer.topAnchor.constraint(equalTo: filterCard.topAnchor, constant: 16),
            searchContainer.leadingAnchor.constraint(equalTo: filterCard.leadingAnchor, constant: 16),
            searchContainer.trailingAnchor.constraint(equalTo: filterCard.trailingAnchor, constant: -16),
            searchContainer.heightAnchor.constraint(equalToConstant: 50),

            searchIconView.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor, constant: 14),
            searchIconView.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
            searchIconView.widthAnchor.constraint(equalToConstant: 22),
            searchIconView.heightAnchor.constraint(equalToConstant: 22),

            searchTextField.leadingAnchor.constraint(equalTo: searchIconView.trailingAnchor, constant: 10),
            searchTextField.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor, constant: -12),
            searchTextField.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),

            filterButtonStack.topAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: 14),
            filterButtonStack.leadingAnchor.constraint(equalTo: filterCard.leadingAnchor, constant: 16),
            filterButtonStack.trailingAnchor.constraint(equalTo: filterCard.trailingAnchor, constant: -16),
            filterButtonStack.heightAnchor.constraint(equalToConstant: 48),

            categoryFilterRow.topAnchor.constraint(equalTo: filterButtonStack.bottomAnchor, constant: 14),
            categoryFilterRow.leadingAnchor.constraint(equalTo: filterCard.leadingAnchor, constant: 16),
            categoryFilterRow.trailingAnchor.constraint(equalTo: filterCard.trailingAnchor, constant: -16),
            categoryFilterRow.bottomAnchor.constraint(equalTo: filterCard.bottomAnchor, constant: -16),
            categoryFilterRow.heightAnchor.constraint(equalToConstant: 48),

            categoryFilterIcon.leadingAnchor.constraint(equalTo: categoryFilterRow.leadingAnchor),
            categoryFilterIcon.centerYAnchor.constraint(equalTo: categoryFilterRow.centerYAnchor),
            categoryFilterIcon.widthAnchor.constraint(equalToConstant: 18),
            categoryFilterIcon.heightAnchor.constraint(equalToConstant: 18),

            categoryFilterLabel.leadingAnchor.constraint(equalTo: categoryFilterIcon.trailingAnchor, constant: 8),
            categoryFilterLabel.centerYAnchor.constraint(equalTo: categoryFilterRow.centerYAnchor),
            categoryFilterLabel.widthAnchor.constraint(equalToConstant: 112),

            categoryButton.leadingAnchor.constraint(equalTo: categoryFilterLabel.trailingAnchor, constant: 10),
            categoryButton.trailingAnchor.constraint(equalTo: categoryFilterRow.trailingAnchor),
            categoryButton.topAnchor.constraint(equalTo: categoryFilterRow.topAnchor),
            categoryButton.bottomAnchor.constraint(equalTo: categoryFilterRow.bottomAnchor),
        ])

        // 요약 바
        view.addSubview(summaryView)
        summaryView.addSubview(incomeLabel)
        summaryView.addSubview(expenseLabel)
        summaryView.addSubview(balanceLabel)
        NSLayoutConstraint.activate([
            summaryView.topAnchor.constraint(equalTo: filterCard.bottomAnchor, constant: 12),
            summaryView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            summaryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            summaryView.heightAnchor.constraint(equalToConstant: 40),

            incomeLabel.leadingAnchor.constraint(equalTo: summaryView.leadingAnchor, constant: 16),
            incomeLabel.centerYAnchor.constraint(equalTo: summaryView.centerYAnchor),

            balanceLabel.centerXAnchor.constraint(equalTo: summaryView.centerXAnchor),
            balanceLabel.centerYAnchor.constraint(equalTo: summaryView.centerYAnchor),

            expenseLabel.trailingAnchor.constraint(equalTo: summaryView.trailingAnchor, constant: -16),
            expenseLabel.centerYAnchor.constraint(equalTo: summaryView.centerYAnchor),
        ])

        // 테이블뷰
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: summaryView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
        ])

        tableView.delegate = self
        tableView.dataSource = self
        searchTextField.delegate = self
    }

    private func makeTypeFilterButton(title: String, tag: Int) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        btn.layer.cornerRadius = 12
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.separator.withAlphaComponent(0.6).cgColor
        btn.tag = tag
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(didTapTypeFilter(_:)), for: .touchUpInside)
        return btn
    }

    private func updateFilterControls() {
        let isAllSelected = currentTypeFilter == nil
        updateTypeButton(allButton, isSelected: isAllSelected)
        updateTypeButton(expenseOnlyButton, isSelected: currentTypeFilter == .expense)
        updateTypeButton(incomeOnlyButton, isSelected: currentTypeFilter == .income)

        let title = currentCategory.map { "\($0.icon)  \($0.rawValue)" } ?? "전체 장부 과목"
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString(
            title,
            attributes: AttributeContainer([
                .font: UIFont.systemFont(ofSize: 15, weight: .bold),
                .foregroundColor: UIColor.label
            ])
        )
        configuration.image = UIImage(systemName: "chevron.down")
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 8
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 12)
        configuration.baseForegroundColor = .label
        categoryButton.configuration = configuration
        categoryButton.showsMenuAsPrimaryAction = true
        categoryButton.menu = makeCategoryMenu()
    }

    private func updateTypeButton(_ button: UIButton, isSelected: Bool) {
        if isSelected {
            let color = typeFilterColor(for: button.tag)
            button.backgroundColor = color.withAlphaComponent(0.14)
            button.setTitleColor(color, for: .normal)
            button.layer.borderColor = color.withAlphaComponent(0.45).cgColor
        } else {
            button.backgroundColor = .secondarySystemGroupedBackground
            button.setTitleColor(.secondaryLabel, for: .normal)
            button.layer.borderColor = UIColor.separator.withAlphaComponent(0.6).cgColor
        }
    }

    private func typeFilterColor(for tag: Int) -> UIColor {
        switch tag {
        case 100:
            return .bbLeaf
        case 101:
            return .systemRed
        default:
            return .label
        }
    }

    private func makeCategoryMenu() -> UIMenu {
        let allAction = UIAction(
            title: "전체 장부 과목",
            state: currentCategory == nil ? .on : .off
        ) { [weak self] _ in
            self?.currentCategory = nil
            self?.updateFilterControls()
            self?.applyFilters()
        }

        let actions = Category.allCases.map { category in
            UIAction(
                title: "\(category.icon)  \(category.rawValue)",
                state: currentCategory == category ? .on : .off
            ) { [weak self] _ in
                self?.currentCategory = category
                self?.updateFilterControls()
                self?.applyFilters()
            }
        }

        return UIMenu(title: "카테고리 선택", children: [allAction] + actions)
    }

    // MARK: - 필터 적용 및 요약 연산
    private func applyFilters() {
        // 1. 월 필터
        let monthKey = String(format: "%04d-%02d", currentYear, currentMonth)
        var result = allTransactions.filter { $0.yearMonthKey == monthKey }

        // 2. 수입/지출 타입 필터
        if let type = currentTypeFilter {
            result = result.filter { $0.type == type }
        }

        // 3. 카테고리 필터
        if let cat = currentCategory {
            result = result.filter { $0.category == cat }
        }

        // 4. 검색어 필터 (메모 + 카테고리명)
        if !currentSearchText.isEmpty {
            result = result.filter {
                $0.memo.localizedCaseInsensitiveContains(currentSearchText) ||
                $0.category.rawValue.localizedCaseInsensitiveContains(currentSearchText)
            }
        }

        // 날짜 내림차순 정렬
        filteredTransactions = result.sorted { $0.date > $1.date }

        updateMonthLabel()
        updateSummary()
        tableView.reloadData()
        emptyLabel.isHidden = !filteredTransactions.isEmpty
    }

    private func updateMonthLabel() {
        monthNavigationView.update(year: currentYear, month: currentMonth)
    }

    private func updateSummary() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let monthKey = String(format: "%04d-%02d", currentYear, currentMonth)
        let monthlyTransactions = allTransactions.filter { $0.yearMonthKey == monthKey }

        let income  = monthlyTransactions.filter { $0.type == .income  }.reduce(0) { $0 + $1.amount }
        let expense = monthlyTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        let balance = income - expense

        let incomeStr  = formatter.string(from: NSNumber(value: income))  ?? "0"
        let expenseStr = formatter.string(from: NSNumber(value: expense)) ?? "0"
        let balanceStr = formatter.string(from: NSNumber(value: abs(balance))) ?? "0"

        incomeLabel.text  = "+ \(incomeStr)"
        expenseLabel.text = "- \(expenseStr)"
        balanceLabel.text = balance >= 0 ? "잔고 \(balanceStr)" : "잔고 -\(balanceStr)"
        balanceLabel.textColor = balance >= 0 ? .label : .systemRed
    }

    // MARK: - Actions
    private func setupActions() {
        searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
    }

    @objc private func didTapPrevMonth() {
        moveMonth(by: -1)
    }

    @objc private func didTapNextMonth() {
        moveMonth(by: 1)
    }

    private func moveMonth(by offset: Int) {
        currentMonth += offset
        if currentMonth == 0 { currentMonth = 12; currentYear -= 1 }
        if currentMonth == 13 { currentMonth = 1; currentYear += 1 }
        applyFilters()
    }

    @objc private func didTapTypeFilter(_ sender: UIButton) {
        switch sender.tag {
        case -1:
            currentTypeFilter = nil
        case 100:
            currentTypeFilter = .income
        case 101:
            currentTypeFilter = .expense
        default:
            break
        }
        updateFilterControls()
        applyFilters()
    }

    @objc private func searchTextChanged() {
        currentSearchText = searchTextField.text ?? ""
        applyFilters()
    }

    @objc private func didTapAdd() {
        let addVC = AddTransactionViewController()
        addVC.delegate = self
        let nav = UINavigationController(rootViewController: addVC)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension LedgerViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredTransactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionCell.reuseID, for: indexPath) as! TransactionCell
        cell.configure(with: filteredTransactions[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 72 }

    // 스와이프 삭제
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, completion in
            guard let self else { return }
            let target = self.filteredTransactions[indexPath.row]
            self.store.deleteTransaction(id: target.id)
            self.applyFilters()
            completion(true)
        }
        delete.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

// MARK: - UITextFieldDelegate
extension LedgerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - AddTransactionDelegate
extension LedgerViewController: AddTransactionDelegate {
    func didAddTransaction(_ transaction: Transaction) {
        store.addTransaction(transaction)
        applyFilters()
    }
}

// MARK: - TransactionCell (인라인 커스텀 셀)
final class TransactionCell: UITableViewCell {

    static let reuseID = "TransactionCell"

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let categoryBadge: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 24)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let amountLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.textAlignment = .right
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11)
        l.textColor = .tertiaryLabel
        l.textAlignment = .right
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupLayout()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupLayout() {
        contentView.addSubview(cardView)
        cardView.addSubview(categoryBadge)
        cardView.addSubview(titleLabel)
        cardView.addSubview(subLabel)
        cardView.addSubview(amountLabel)
        cardView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            categoryBadge.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            categoryBadge.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            categoryBadge.widthAnchor.constraint(equalToConstant: 36),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: categoryBadge.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: amountLabel.leadingAnchor, constant: -8),

            subLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            subLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            amountLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            amountLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            amountLabel.widthAnchor.constraint(equalToConstant: 110),

            dateLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 3),
            dateLabel.trailingAnchor.constraint(equalTo: amountLabel.trailingAnchor),
        ])
    }

    func configure(with t: Transaction) {
        categoryBadge.text = t.category.icon
        titleLabel.text = t.category.rawValue
        subLabel.text = t.memo.isEmpty ? t.paymentMethod.rawValue : "\(t.paymentMethod.rawValue) · \(t.memo)"
        amountLabel.text = t.formattedAmount
        amountLabel.textColor = t.type == .income ? .bbLeaf : .systemRed
        dateLabel.text = t.formattedDate
    }
}
