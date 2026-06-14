// Controllers/DashboardViewController.swift

import UIKit

class DashboardViewController: UIViewController {

    // MARK: - Data
    private let store = LedgerStore.shared
    private var transactions: [Transaction] { store.transactions }
    private var monthlyBudget: Int {
        get { store.monthlyBudget }
        set { store.monthlyBudget = newValue }
    }

    private var currentYear:  Int = Calendar.current.component(.year,  from: Date())
    private var currentMonth: Int = Calendar.current.component(.month, from: Date())
    private let monthNavigationView = MonthNavigationView()

    // MARK: - UI: 스크롤 컨테이너
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // MARK: - UI: 잔고 요약 카드
    private let summaryCard: UIView = makeCard()

    private let totalIncomeLabel  = DashboardViewController.makeSummaryValueLabel(color: .bbLeaf)
    private let totalExpenseLabel = DashboardViewController.makeSummaryValueLabel(color: .systemRed)
    private let totalBalanceLabel = DashboardViewController.makeSummaryValueLabel(color: .label)

    // MARK: - UI: 예산 게이지 카드
    private let budgetCard: UIView = makeCard()
    private let budgetProgressView = BudgetProgressView()
    private let budgetEditButton: UIButton = {
        let btn = UIButton(type: .system)
        var configuration = UIButton.Configuration.filled()
        configuration.title = "수정"
        configuration.image = UIImage(systemName: "pencil")
        configuration.imagePadding = 4
        configuration.baseBackgroundColor = UIColor.bbLeafTint(0.12)
        configuration.baseForegroundColor = .bbLeaf
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
        btn.configuration = configuration
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - UI: 카테고리 소비 카드
    private let categoryCard: UIView = makeCard()
    private let categoryStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 14
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // MARK: - 카드 팩토리
    private static func makeCard() -> UIView {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 16
        v.layer.shadowColor   = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.05
        v.layer.shadowOffset  = CGSize(width: 0, height: 2)
        v.layer.shadowRadius  = 8
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }

    private static func makeSummaryValueLabel(color: UIColor) -> UILabel {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.textColor = color
        l.textAlignment = .center
        l.adjustsFontSizeToFitWidth = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private func makeSectionTitle(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupNavigationBar()
        setupScrollView()
        setupSummaryCard()
        setupBudgetCard()
        setupCategoryCard()
        updateAll()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAll()
    }

    // MARK: - ScrollView 기반 레이아웃
    private func setupScrollView() {
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
    }

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

    // MARK: - 잔고 요약 카드
    private func setupSummaryCard() {
        let title = makeSectionTitle("이번 달 현황")

        let incomeTitle  = makeSmallLabel("수입", color: .bbLeaf)
        let expenseTitle = makeSmallLabel("지출", color: .systemRed)
        let balanceTitle = makeSmallLabel("잔고", color: .secondaryLabel)

        totalBalanceLabel.font = .systemFont(ofSize: 26, weight: .heavy)
        totalBalanceLabel.textAlignment = .left
        totalIncomeLabel.font = .systemFont(ofSize: 16, weight: .bold)
        totalIncomeLabel.textAlignment = .right
        totalExpenseLabel.font = .systemFont(ofSize: 16, weight: .bold)
        totalExpenseLabel.textAlignment = .right

        let balanceStack = UIStackView(arrangedSubviews: [balanceTitle, totalBalanceLabel])
        balanceStack.axis = .vertical
        balanceStack.alignment = .leading
        balanceStack.spacing = 6
        balanceStack.translatesAutoresizingMaskIntoConstraints = false

        let incomeRow = makeSummaryRow(title: incomeTitle, value: totalIncomeLabel)
        let expenseRow = makeSummaryRow(title: expenseTitle, value: totalExpenseLabel)
        let rightStack = UIStackView(arrangedSubviews: [incomeRow, expenseRow])
        rightStack.axis = .vertical
        rightStack.spacing = 10
        rightStack.translatesAutoresizingMaskIntoConstraints = false

        let divider = makeDividerV()

        let hStack = UIStackView(arrangedSubviews: [balanceStack, divider, rightStack])
        hStack.axis = .horizontal
        hStack.distribution = .fill
        hStack.alignment = .center
        hStack.spacing = 14
        hStack.translatesAutoresizingMaskIntoConstraints = false

        summaryCard.addSubview(title)
        summaryCard.addSubview(hStack)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: summaryCard.topAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 16),

            hStack.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 12),
            hStack.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 8),
            hStack.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -8),
            hStack.bottomAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: -16),

            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.heightAnchor.constraint(equalToConstant: 52),

            balanceStack.widthAnchor.constraint(equalTo: hStack.widthAnchor, multiplier: 0.48),
        ])
        contentStack.addArrangedSubview(summaryCard)
    }

    // MARK: - 예산 게이지 카드
    private func setupBudgetCard() {
        let title = makeSectionTitle("목표 지출액")
        budgetProgressView.translatesAutoresizingMaskIntoConstraints = false

        budgetCard.addSubview(title)
        budgetCard.addSubview(budgetProgressView)
        budgetCard.addSubview(budgetEditButton)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: budgetCard.topAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: budgetCard.leadingAnchor, constant: 16),

            budgetEditButton.centerYAnchor.constraint(equalTo: title.centerYAnchor),
            budgetEditButton.trailingAnchor.constraint(equalTo: budgetCard.trailingAnchor, constant: -16),
            budgetEditButton.heightAnchor.constraint(equalToConstant: 30),

            budgetProgressView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 28),
            budgetProgressView.leadingAnchor.constraint(equalTo: budgetCard.leadingAnchor, constant: 16),
            budgetProgressView.trailingAnchor.constraint(equalTo: budgetCard.trailingAnchor, constant: -16),
            budgetProgressView.heightAnchor.constraint(equalToConstant: 20),
            budgetProgressView.bottomAnchor.constraint(equalTo: budgetCard.bottomAnchor, constant: -24),
        ])
        budgetEditButton.addTarget(self, action: #selector(didTapEditBudget), for: .touchUpInside)
        contentStack.addArrangedSubview(budgetCard)
    }

    // MARK: - 카테고리별 소비 카드
    private func setupCategoryCard() {
        let title = makeSectionTitle("카테고리별 지출")
        categoryCard.addSubview(title)
        categoryCard.addSubview(categoryStack)
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: categoryCard.topAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: categoryCard.leadingAnchor, constant: 16),

            categoryStack.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 12),
            categoryStack.leadingAnchor.constraint(equalTo: categoryCard.leadingAnchor, constant: 16),
            categoryStack.trailingAnchor.constraint(equalTo: categoryCard.trailingAnchor, constant: -16),
            categoryStack.bottomAnchor.constraint(equalTo: categoryCard.bottomAnchor, constant: -16),
        ])
        contentStack.addArrangedSubview(categoryCard)
    }

    // MARK: - 전체 데이터 갱신
    private func updateAll() {
        let monthKey = String(format: "%04d-%02d", currentYear, currentMonth)
        let monthly  = transactions.filter { $0.yearMonthKey == monthKey }

        let income  = monthly.filter { $0.type == .income  }.reduce(0) { $0 + $1.amount }
        let expense = monthly.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        let balance = income - expense

        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        func f(_ v: Int) -> String { (fmt.string(from: NSNumber(value: v)) ?? "0") + "원" }

        monthNavigationView.update(year: currentYear, month: currentMonth)
        totalIncomeLabel.text  = f(income)
        totalExpenseLabel.text = f(expense)
        totalBalanceLabel.text = f(balance)
        totalBalanceLabel.textColor = balance >= 0 ? .label : .systemRed

        budgetProgressView.update(spent: expense, budget: monthlyBudget)
        updateCategoryRows(monthly: monthly)

    }

    private func updateCategoryRows(monthly: [Transaction]) {
        categoryStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let expenses = monthly.filter { $0.type == .expense }
        let total    = expenses.reduce(0) { $0 + $1.amount }
        guard total > 0 else {
            let empty = makeSmallLabel("이번 달 지출 내역이 없습니다.", color: .tertiaryLabel)
            categoryStack.addArrangedSubview(empty)
            return
        }

        // 카테고리별 합산
        var catTotals: [(Category, Int)] = []
        for cat in Category.allCases {
            let sum = expenses.filter { $0.category == cat }.reduce(0) { $0 + $1.amount }
            if sum > 0 { catTotals.append((cat, sum)) }
        }
        catTotals.sort { $0.1 > $1.1 }

        let donut = CategoryDonutView()
        donut.translatesAutoresizingMaskIntoConstraints = false
        donut.configure(
            slices: catTotals.map { (category: $0.0, amount: $0.1) },
            total: total
        )
        categoryStack.addArrangedSubview(donut)
        donut.heightAnchor.constraint(equalToConstant: 150).isActive = true

        let listStack = UIStackView()
        listStack.axis = .vertical
        listStack.spacing = 10
        listStack.translatesAutoresizingMaskIntoConstraints = false
        categoryStack.addArrangedSubview(listStack)

        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal

        for (index, item) in catTotals.prefix(AppConfig.Dashboard.categoryRankLimit).enumerated() {
            let pct = Double(item.1) / Double(total)
            let row = makeCategoryRow(
                rank: index + 1,
                cat: item.0,
                amount: item.1,
                pct: pct,
                formatter: fmt
            )
            listStack.addArrangedSubview(row)
        }
    }

    private func makeCategoryRow(rank: Int, cat: Category, amount: Int, pct: Double, formatter: NumberFormatter) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.isUserInteractionEnabled = true
        container.accessibilityLabel = "\(cat.rawValue) 세부 내역 보기"

        let rankLabel = UILabel()
        rankLabel.text = "\(rank)"
        rankLabel.font = .systemFont(ofSize: 11, weight: .bold)
        rankLabel.textColor = .secondaryLabel
        rankLabel.textAlignment = .center
        rankLabel.backgroundColor = .secondarySystemBackground
        rankLabel.layer.cornerRadius = 10
        rankLabel.clipsToBounds = true
        rankLabel.translatesAutoresizingMaskIntoConstraints = false

        let colorDot = UIView()
        colorDot.backgroundColor = cat.color
        colorDot.layer.cornerRadius = 5
        colorDot.translatesAutoresizingMaskIntoConstraints = false

        let iconLabel = UILabel()
        iconLabel.text = cat.icon
        iconLabel.font = .systemFont(ofSize: 17)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false

        let nameLabel = UILabel()
        nameLabel.text = cat.rawValue
        nameLabel.font = .systemFont(ofSize: 13, weight: .medium)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        let amtLabel = UILabel()
        amtLabel.text = "\(formatter.string(from: NSNumber(value: amount)) ?? "0")원"
        amtLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        amtLabel.textAlignment = .right
        amtLabel.translatesAutoresizingMaskIntoConstraints = false

        let pctLabel = UILabel()
        pctLabel.text = "\(Int(pct * 100))%"
        pctLabel.font = .systemFont(ofSize: 12, weight: .bold)
        pctLabel.textColor = .secondaryLabel
        pctLabel.textAlignment = .right
        pctLabel.translatesAutoresizingMaskIntoConstraints = false

        let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronView.tintColor = .tertiaryLabel
        chevronView.contentMode = .scaleAspectFit
        chevronView.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(rankLabel)
        container.addSubview(colorDot)
        container.addSubview(iconLabel)
        container.addSubview(nameLabel)
        container.addSubview(amtLabel)
        container.addSubview(pctLabel)
        container.addSubview(chevronView)

        let tapGesture = CategoryTapGestureRecognizer(target: self, action: #selector(didTapCategorySummary(_:)))
        tapGesture.category = cat
        container.addGestureRecognizer(tapGesture)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 32),

            rankLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            rankLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 20),
            rankLabel.heightAnchor.constraint(equalToConstant: 20),

            colorDot.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 10),
            colorDot.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            colorDot.widthAnchor.constraint(equalToConstant: 10),
            colorDot.heightAnchor.constraint(equalToConstant: 10),

            iconLabel.leadingAnchor.constraint(equalTo: colorDot.trailingAnchor, constant: 8),
            iconLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 24),

            nameLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 6),
            nameLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: amtLabel.leadingAnchor, constant: -8),

            chevronView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            chevronView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: 12),
            chevronView.heightAnchor.constraint(equalToConstant: 12),

            amtLabel.trailingAnchor.constraint(equalTo: chevronView.leadingAnchor, constant: -8),
            amtLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            amtLabel.widthAnchor.constraint(equalToConstant: 90),

            pctLabel.trailingAnchor.constraint(equalTo: amtLabel.leadingAnchor, constant: -8),
            pctLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            pctLabel.widthAnchor.constraint(equalToConstant: 44),
        ])
        return container
    }

    // MARK: - Actions
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
        updateAll()
    }

    @objc private func didTapEditBudget() {
        let alert = UIAlertController(title: "목표 지출액 설정", message: "이번 달 목표 지출액을 입력하세요", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.keyboardType = .numberPad
            tf.placeholder  = "예: 1500000"
            tf.text = "\(self.monthlyBudget)"
        }
        alert.addAction(UIAlertAction(title: "저장", style: .default) { [weak self] _ in
            if let text = alert.textFields?.first?.text,
               let value = Int(text), value > 0 {
                self?.monthlyBudget = value
                self?.updateAll()
            }
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func didTapAdd() {
        let addVC = AddTransactionViewController()
        addVC.delegate = self
        let nav = UINavigationController(rootViewController: addVC)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    @objc private func didTapCategorySummary(_ recognizer: CategoryTapGestureRecognizer) {
        guard let category = recognizer.category else { return }
        let monthKey = String(format: "%04d-%02d", currentYear, currentMonth)
        let details = transactions
            .filter { $0.yearMonthKey == monthKey && $0.type == .expense && $0.category == category }
            .sorted { $0.date > $1.date }

        let detailVC = CategoryExpenseDetailViewController(
            category: category,
            monthTitle: "\(currentYear)년 \(currentMonth)월",
            transactions: details
        )
        let nav = UINavigationController(rootViewController: detailVC)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    // MARK: - 헬퍼 뷰 팩토리
    private func makeSmallLabel(_ text: String, color: UIColor) -> UILabel {
        let l = UILabel()
        l.text      = text
        l.font      = .systemFont(ofSize: 12)
        l.textColor = color
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    private func makeSummaryRow(title: UILabel, value: UILabel) -> UIStackView {
        let row = UIStackView(arrangedSubviews: [title, value])
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .fill
        row.spacing = 8
        row.translatesAutoresizingMaskIntoConstraints = false

        title.setContentHuggingPriority(.required, for: .horizontal)
        value.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return row
    }

    private func makeVStack(top: UILabel, bottom: UILabel) -> UIStackView {
        let sv = UIStackView(arrangedSubviews: [top, bottom])
        sv.axis      = .vertical
        sv.alignment = .center
        sv.spacing   = 4
        return sv
    }

    private func makeDividerV() -> UIView {
        let v = UIView()
        v.backgroundColor = .systemGray5
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }
}

// MARK: - AddTransactionDelegate
extension DashboardViewController: AddTransactionDelegate {
    func didAddTransaction(_ transaction: Transaction) {
        store.addTransaction(transaction)
        updateAll()
    }
}

private final class CategoryTapGestureRecognizer: UITapGestureRecognizer {
    var category: Category?
}

private final class CategoryExpenseDetailViewController: UIViewController {

    private let category: Category
    private let monthTitle: String
    private let transactions: [Transaction]

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.reuseID)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(category: Category, monthTitle: String, transactions: [Transaction]) {
        self.category = category
        self.monthTitle = monthTitle
        self.transactions = transactions
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "\(category.icon) \(category.rawValue)"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )

        setupLayout()
        updateSummary()
    }

    private func setupLayout() {
        view.addSubview(summaryLabel)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            summaryLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            summaryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            summaryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        tableView.dataSource = self
        tableView.delegate = self
    }

    private func updateSummary() {
        let total = transactions.reduce(0) { $0 + $1.amount }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let totalText = formatter.string(from: NSNumber(value: total)) ?? "0"
        summaryLabel.text = "\(monthTitle) · \(transactions.count)건 · \(totalText)원"
    }

    @objc private func didTapClose() {
        dismiss(animated: true)
    }
}

extension CategoryExpenseDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionCell.reuseID, for: indexPath) as! TransactionCell
        cell.configure(with: transactions[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        72
    }
}

// MARK: - CategoryDonutView
final class CategoryDonutView: UIView {

    private struct Slice {
        let category: Category
        let amount: Int
    }

    private var slices: [Slice] = []
    private var total: Int = 0

    private let centerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "총 지출"
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let centerAmountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(centerTitleLabel)
        addSubview(centerAmountLabel)

        NSLayoutConstraint.activate([
            centerTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -12),
            centerTitleLabel.widthAnchor.constraint(equalToConstant: 96),

            centerAmountLabel.topAnchor.constraint(equalTo: centerTitleLabel.bottomAnchor, constant: 2),
            centerAmountLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerAmountLabel.widthAnchor.constraint(equalToConstant: 110),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(slices: [(category: Category, amount: Int)], total: Int) {
        self.slices = slices.map { Slice(category: $0.category, amount: $0.amount) }
        self.total = total

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let totalText = formatter.string(from: NSNumber(value: total)) ?? "0"
        centerAmountLabel.text = "\(totalText)원"

        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard total > 0, !slices.isEmpty, let context = UIGraphicsGetCurrentContext() else { return }

        let side = min(rect.width, rect.height) - 10
        let radius = side / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let lineWidth: CGFloat = 22
        var startAngle = -CGFloat.pi / 2

        context.setLineWidth(lineWidth)
        context.setLineCap(.round)

        UIColor.systemGray6.setStroke()
        let fullPath = UIBezierPath(
            arcCenter: center,
            radius: radius - lineWidth / 2,
            startAngle: 0,
            endAngle: CGFloat.pi * 2,
            clockwise: true
        )
        fullPath.lineWidth = lineWidth
        fullPath.stroke()

        for slice in slices {
            let ratio = CGFloat(slice.amount) / CGFloat(total)
            let endAngle = startAngle + ratio * CGFloat.pi * 2
            let path = UIBezierPath(
                arcCenter: center,
                radius: radius - lineWidth / 2,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: true
            )
            slice.category.color.setStroke()
            path.lineWidth = lineWidth
            path.lineCapStyle = .round
            path.stroke()
            startAngle = endAngle
        }
    }
}
