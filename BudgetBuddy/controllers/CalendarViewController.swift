// Controllers/CalendarViewController.swift

import UIKit

class CalendarViewController: UIViewController {

    // MARK: - Data
    private let store = LedgerStore.shared
    private var transactions: [Transaction] { store.transactions }
    private var savingsGoals: [SavingsGoal] { store.savingsGoals }
    private var currentYear:  Int = Calendar.current.component(.year,  from: Date())
    private var currentMonth: Int = Calendar.current.component(.month, from: Date())
    private var targetZeroDays: Int {
        get { store.targetZeroDays }
        set { store.targetZeroDays = newValue }
    }
    private let monthNavigationView = MonthNavigationView()

    // 당월 일수 계산
    private var daysInMonth: Int {
        var components = DateComponents()
        components.year  = currentYear
        components.month = currentMonth
        let date = Calendar.current.date(from: components)!
        return Calendar.current.range(of: .day, in: .month, for: date)!.count
    }

    // 당월 1일의 요일 (0=일, 1=월 ... 6=토)
    private var firstWeekdayOfMonth: Int {
        var components = DateComponents()
        components.year  = currentYear
        components.month = currentMonth
        components.day   = 1
        let date = Calendar.current.date(from: components)!
        return Calendar.current.component(.weekday, from: date) - 1
    }

    // 날짜별 지출 합산 딕셔너리
    private var dailyExpenseMap: [Int: Int] = [:]

    // MARK: - UI

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentStack: UIStackView = {
        let sv = UIStackView()
        sv.axis    = .vertical
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // 달성 현황 카드
    private let statsCard: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let statsTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "이번 달 목표"
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let zeroDayValueLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 30, weight: .heavy)
        l.textColor = .label
        l.adjustsFontSizeToFitWidth = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let targetButton: UIButton = {
        let btn = UIButton(type: .system)
        var configuration = UIButton.Configuration.filled()
        configuration.title = "목표 수정"
        configuration.image = UIImage(systemName: "slider.horizontal.3")
        configuration.imagePadding = 5
        configuration.baseBackgroundColor = UIColor.bbLeafTint(0.12)
        configuration.baseForegroundColor = .bbLeaf
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 11, bottom: 6, trailing: 11)
        btn.configuration = configuration
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let progressRingView = ZeroDayProgressRingView()

    private let remainingValueLabel = CalendarViewController.makeMetricValueLabel()
    private let spendingDaysValueLabel = CalendarViewController.makeMetricValueLabel()

    // 요일 헤더
    private let weekdayHeader: UIStackView = {
        let sv = UIStackView()
        sv.axis         = .horizontal
        sv.distribution = .fillEqually
        sv.translatesAutoresizingMaskIntoConstraints = false
        ["일","월","화","수","목","금","토"].forEach { day in
            let l = UILabel()
            l.text      = day
            l.font      = .systemFont(ofSize: 12, weight: .medium)
            l.textColor = day == "일" ? .systemRed : (day == "토" ? .systemBlue : .secondaryLabel)
            l.textAlignment = .center
            sv.addArrangedSubview(l)
        }
        return sv
    }()

    // 캘린더 컬렉션뷰
    private lazy var calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing      = 4
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor    = .clear
        cv.isScrollEnabled    = false
        cv.register(CalendarDayCell.self, forCellWithReuseIdentifier: CalendarDayCell.reuseID)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    private var collectionHeightConstraint: NSLayoutConstraint!

    // MARK: - UI: 저축 목표 카드
    private let savingsCard: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let savingsTableView: UITableView = {
        let tv = UITableView()
        tv.isScrollEnabled = false
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.register(SavingsSlotCell.self, forCellReuseIdentifier: SavingsSlotCell.reuseID)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private var savingsTableHeightConstraint: NSLayoutConstraint!

    private static func makeMetricValueLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bbAppBackground
        setupNavigationBar()
        setupScrollView()
        setupStatsCard()
        setupCalendarSection()
        setupSavingsCard()
        buildDailyMap()
        updateAll()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buildDailyMap()
        updateAll()
    }

    // MARK: - Layout

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

    private func setupStatsCard() {
        let headingStack = UIStackView(arrangedSubviews: [statsTitleLabel, zeroDayValueLabel, targetButton])
        headingStack.axis = .vertical
        headingStack.spacing = 6
        headingStack.alignment = .leading
        headingStack.translatesAutoresizingMaskIntoConstraints = false

        let metricStack = UIStackView(arrangedSubviews: [
            makeMetricBlock(title: "남은 목표", valueLabel: remainingValueLabel),
            makeMetricBlock(title: "지출 기록일", valueLabel: spendingDaysValueLabel)
        ])
        metricStack.axis = .horizontal
        metricStack.spacing = 10
        metricStack.distribution = .fillEqually
        metricStack.translatesAutoresizingMaskIntoConstraints = false

        progressRingView.translatesAutoresizingMaskIntoConstraints = false

        statsCard.addSubview(headingStack)
        statsCard.addSubview(progressRingView)
        statsCard.addSubview(metricStack)

        NSLayoutConstraint.activate([
            headingStack.topAnchor.constraint(equalTo: statsCard.topAnchor, constant: 18),
            headingStack.leadingAnchor.constraint(equalTo: statsCard.leadingAnchor, constant: 18),
            headingStack.trailingAnchor.constraint(lessThanOrEqualTo: progressRingView.leadingAnchor, constant: -14),

            targetButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 118),
            targetButton.heightAnchor.constraint(equalToConstant: 30),

            progressRingView.topAnchor.constraint(equalTo: statsCard.topAnchor, constant: 18),
            progressRingView.trailingAnchor.constraint(equalTo: statsCard.trailingAnchor, constant: -18),
            progressRingView.widthAnchor.constraint(equalToConstant: 86),
            progressRingView.heightAnchor.constraint(equalToConstant: 86),

            metricStack.topAnchor.constraint(equalTo: progressRingView.bottomAnchor, constant: 16),
            metricStack.leadingAnchor.constraint(equalTo: statsCard.leadingAnchor, constant: 18),
            metricStack.trailingAnchor.constraint(equalTo: statsCard.trailingAnchor, constant: -18),
            metricStack.bottomAnchor.constraint(equalTo: statsCard.bottomAnchor, constant: -18),
            metricStack.heightAnchor.constraint(equalToConstant: 58),
        ])
        targetButton.addTarget(self, action: #selector(didTapSetTarget), for: .touchUpInside)
        contentStack.addArrangedSubview(statsCard)
    }

    private func makeMetricBlock(title: String, valueLabel: UILabel) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(titleLabel)
        container.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        ])

        return container
    }

    private func setupCalendarSection() {
        // 캘린더 카드
        let calCard = UIView()
        calCard.backgroundColor  = .systemBackground
        calCard.layer.cornerRadius = 16
        calCard.translatesAutoresizingMaskIntoConstraints = false

        calCard.addSubview(weekdayHeader)
        calCard.addSubview(calendarCollectionView)

        let rows = (firstWeekdayOfMonth + daysInMonth + 6) / 7
        collectionHeightConstraint = calendarCollectionView.heightAnchor.constraint(equalToConstant: CGFloat(rows * 68))

        NSLayoutConstraint.activate([
            weekdayHeader.topAnchor.constraint(equalTo: calCard.topAnchor, constant: 14),
            weekdayHeader.leadingAnchor.constraint(equalTo: calCard.leadingAnchor, constant: 8),
            weekdayHeader.trailingAnchor.constraint(equalTo: calCard.trailingAnchor, constant: -8),
            weekdayHeader.heightAnchor.constraint(equalToConstant: 20),

            calendarCollectionView.topAnchor.constraint(equalTo: weekdayHeader.bottomAnchor, constant: 8),
            calendarCollectionView.leadingAnchor.constraint(equalTo: calCard.leadingAnchor, constant: 8),
            calendarCollectionView.trailingAnchor.constraint(equalTo: calCard.trailingAnchor, constant: -8),
            calendarCollectionView.bottomAnchor.constraint(equalTo: calCard.bottomAnchor, constant: -14),
            collectionHeightConstraint,
        ])

        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate   = self
        contentStack.addArrangedSubview(calCard)
        contentStack.addArrangedSubview(makeSectionDivider())
    }

    private func setupSavingsCard() {
        let title = makeSectionTitle("저축 목표")
        let addGoalButton = UIButton(type: .system)
        addGoalButton.setTitle("+ 목표 추가", for: .normal)
        addGoalButton.titleLabel?.font = .systemFont(ofSize: 13)
        addGoalButton.translatesAutoresizingMaskIntoConstraints = false
        addGoalButton.addTarget(self, action: #selector(didTapAddGoal), for: .touchUpInside)

        savingsCard.addSubview(title)
        savingsCard.addSubview(addGoalButton)
        savingsCard.addSubview(savingsTableView)

        savingsTableHeightConstraint = savingsTableView.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: savingsCard.topAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: savingsCard.leadingAnchor, constant: 16),

            addGoalButton.centerYAnchor.constraint(equalTo: title.centerYAnchor),
            addGoalButton.trailingAnchor.constraint(equalTo: savingsCard.trailingAnchor, constant: -16),

            savingsTableView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            savingsTableView.leadingAnchor.constraint(equalTo: savingsCard.leadingAnchor),
            savingsTableView.trailingAnchor.constraint(equalTo: savingsCard.trailingAnchor),
            savingsTableView.bottomAnchor.constraint(equalTo: savingsCard.bottomAnchor),
            savingsTableHeightConstraint,
        ])

        savingsTableView.dataSource = self
        savingsTableView.delegate = self
        contentStack.addArrangedSubview(savingsCard)
    }

    private func makeSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func makeSectionDivider() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let line = UIView()
        line.backgroundColor = .separator
        line.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(line)
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 18),
            line.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            line.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            line.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            line.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),
        ])

        return container
    }

    // MARK: - 데이터 연산

    private func buildDailyMap() {
        dailyExpenseMap = [:]
        let monthKey = String(format: "%04d-%02d", currentYear, currentMonth)
        let monthly  = transactions.filter { $0.yearMonthKey == monthKey && $0.type == .expense }
        for t in monthly {
            let day = t.dayOfMonth
            dailyExpenseMap[day, default: 0] += t.amount
        }
    }

    private func updateAll() {
        monthNavigationView.update(year: currentYear, month: currentMonth)

        // 무지출 일수 (지출 0원인 날 — 이미 지난 날짜만 카운트)
        let today     = Date()
        var zeroDays  = 0
        var pastDays  = 0

        for day in 1...daysInMonth {
            var comps = DateComponents()
            comps.year = currentYear; comps.month = currentMonth; comps.day = day
            guard let date = Calendar.current.date(from: comps), date <= today else { break }
            pastDays += 1
            if (dailyExpenseMap[day] ?? 0) == 0 { zeroDays += 1 }
        }

        let achieveRate = targetZeroDays > 0 ? Double(zeroDays) / Double(targetZeroDays) : 0
        let (_, _, color) = gradeInfo(zeroDays: zeroDays, target: targetZeroDays)
        let remainingTargetDays = max(targetZeroDays - zeroDays, 0)
        let spendingDays = max(pastDays - zeroDays, 0)

        zeroDayValueLabel.text = "\(zeroDays)일 / \(targetZeroDays)일"
        remainingValueLabel.text = "\(remainingTargetDays)일"
        spendingDaysValueLabel.text = "\(spendingDays)일"
        progressRingView.update(progress: achieveRate, color: color)
        updateTargetButtonTitle()

        // 컬렉션뷰 높이 재계산
        let rows = (firstWeekdayOfMonth + daysInMonth + 6) / 7
        collectionHeightConstraint.constant = CGFloat(rows * 68)
        calendarCollectionView.reloadData()

        savingsTableView.reloadData()
        savingsTableView.layoutIfNeeded()
        savingsTableHeightConstraint.constant = CGFloat(savingsGoals.count * 120)
    }

    private func updateTargetButtonTitle() {
        var configuration = targetButton.configuration
        configuration?.title = "목표 \(targetZeroDays)일 수정"
        targetButton.configuration = configuration
    }

    // MARK: - 등급 로직
    private func gradeInfo(zeroDays: Int, target: Int) -> (String, String, UIColor) {
        guard target > 0 else { return ("🐣", "목표를 설정해주세요", .secondaryLabel) }
        let rate = Double(zeroDays) / Double(target)
        switch rate {
        case 1.0...:  return ("🌿", "완료", .bbLeafDark)
        case AppConfig.GoalChallenge.excellentRate...:  return ("🌿", "거의 완료", .bbLeaf)
        case AppConfig.GoalChallenge.activeRate...:     return ("🌿", "진행 중", .bbMintDark)
        default:      return ("🌱", "시작", .bbMint)
        }
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
        buildDailyMap()
        updateAll()
    }

    @objc private func didTapSetTarget() {
        let alert = UIAlertController(title: "목표 무지출 일수", message: "이번 달 목표 일수를 입력하세요", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.keyboardType = .numberPad
            tf.text = "\(self.targetZeroDays)"
        }
        alert.addAction(UIAlertAction(title: "저장", style: .default) { [weak self] _ in
            if let text = alert.textFields?.first?.text,
                let value = Int(text), value > 0 {
                self?.targetZeroDays = value
                self?.buildDailyMap()
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

    @objc private func didTapAddGoal() {
        let alert = UIAlertController(title: "저축 목표 추가", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "목표 이름 (예: 맥북 구매)" }
        alert.addTextField { textField in
            textField.placeholder = "목표 금액"
            textField.keyboardType = .numberPad
        }
        alert.addTextField { $0.placeholder = "이모지 (예: 💻)" }
        alert.addAction(UIAlertAction(title: "추가", style: .default) { [weak self] _ in
            guard let self,
                  let name = alert.textFields?[0].text, !name.isEmpty,
                  let amountText = alert.textFields?[1].text,
                  let amount = Int(amountText), amount > 0 else { return }
            let emoji = alert.textFields?[2].text?.isEmpty == false
                ? alert.textFields![2].text! : AppConfig.Defaults.savingsGoalEmoji
            self.store.addSavingsGoal(SavingsGoal(title: name, targetAmount: amount, emoji: emoji))
            self.updateAll()
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // 총 셀 수 = 앞 빈칸 + 실제 날짜
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return firstWeekdayOfMonth + daysInMonth
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDayCell.reuseID, for: indexPath) as! CalendarDayCell

        let index = indexPath.item
        if index < firstWeekdayOfMonth {
            // 빈 셀 (1일 이전 공백)
            cell.configure(day: nil, expense: nil, isToday: false, isFuture: false)
        } else {
            let day     = index - firstWeekdayOfMonth + 1
            let expense = dailyExpenseMap[day]

            // 오늘 여부 확인
            let todayComps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            let isToday = todayComps.year == currentYear &&
                          todayComps.month == currentMonth &&
                          todayComps.day == day
            var cellComponents = DateComponents()
            cellComponents.year = currentYear
            cellComponents.month = currentMonth
            cellComponents.day = day
            let cellDate = Calendar.current.date(from: cellComponents)
            let isFuture = cellDate.map { Calendar.current.startOfDay(for: $0) > Calendar.current.startOfDay(for: Date()) } ?? false

            cell.configure(day: day, expense: expense, isToday: isToday, isFuture: isFuture)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width) / 7
        return CGSize(width: width, height: 64)
    }
}

// MARK: - AddTransactionDelegate
extension CalendarViewController: AddTransactionDelegate {
    func didAddTransaction(_ transaction: Transaction) {
        store.addTransaction(transaction)
        buildDailyMap()
        updateAll()
    }
}

// MARK: - UITableViewDataSource & Delegate
extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        savingsGoals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SavingsSlotCell.reuseID, for: indexPath) as! SavingsSlotCell
        cell.configure(with: savingsGoals[indexPath.row])
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }
}

// MARK: - SavingsSlotCellDelegate
extension CalendarViewController: SavingsSlotCellDelegate {
    func didTapQuickAdd(goalID: UUID, amount: Int) {
        store.deposit(to: goalID, amount: amount)
        updateAll()
    }
}

// MARK: - ZeroDayProgressRingView
final class ZeroDayProgressRingView: UIView {

    private var progress: Double = 0
    private var progressColor: UIColor = .bbLeaf

    private let percentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .heavy)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(percentLabel)

        NSLayoutConstraint.activate([
            percentLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            percentLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            percentLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func update(progress: Double, color: UIColor) {
        self.progress = min(max(progress, 0), 1)
        progressColor = color
        percentLabel.text = "\(Int(self.progress * 100))%"
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        let lineWidth: CGFloat = 8
        let radius = min(rect.width, rect.height) / 2 - lineWidth / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)

        let trackPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: 0,
            endAngle: CGFloat.pi * 2,
            clockwise: true
        )
        UIColor.secondarySystemGroupedBackground.setStroke()
        trackPath.lineWidth = lineWidth
        trackPath.stroke()

        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + CGFloat(progress) * CGFloat.pi * 2
        let progressPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        progressColor.setStroke()
        progressPath.lineWidth = lineWidth
        progressPath.lineCapStyle = .round
        progressPath.stroke()
    }
}

// MARK: - CalendarDayCell
final class CalendarDayCell: UICollectionViewCell {

    static let reuseID = "CalendarDayCell"

    private let dayLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .medium)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let contentLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 10)
        l.textAlignment = .center
        l.adjustsFontSizeToFitWidth = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let todayDot: UIView = {
        let v = UIView()
        v.backgroundColor = .bbLeaf
        v.layer.cornerRadius = 3
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 10
        contentView.addSubview(dayLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(todayDot)

        NSLayoutConstraint.activate([
            todayDot.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            todayDot.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            todayDot.widthAnchor.constraint(equalToConstant: 6),
            todayDot.heightAnchor.constraint(equalToConstant: 6),

            dayLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            dayLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),

            contentLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 4),
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            contentLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -4),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(day: Int?, expense: Int?, isToday: Bool, isFuture: Bool) {
        guard let day = day else {
            dayLabel.text    = ""
            contentLabel.text = ""
            contentView.backgroundColor = .clear
            todayDot.isHidden = true
            return
        }

        dayLabel.text = "\(day)"
        todayDot.isHidden = !isToday

        if isFuture {
            contentLabel.text = ""
            contentView.backgroundColor = .clear
            dayLabel.textColor = .tertiaryLabel
            contentView.layer.borderWidth = 0
            return
        }

        if let expense = expense, expense > 0 {
            // 지출 있는 날 — 금액 표시
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let str = formatter.string(from: NSNumber(value: expense)) ?? "\(expense)"
            contentLabel.text      = "-\(str)"
            contentLabel.textColor = .systemRed
            contentView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.06)
            dayLabel.textColor = .label
        } else {
            // 무지출 성공 🌿
            contentLabel.text      = "🌿"
            contentLabel.textColor = .bbLeaf
            contentView.backgroundColor = UIColor.bbLeafTint(0.08)
            dayLabel.textColor = .label
        }

        if isToday {
            contentView.layer.borderWidth = 1.5
            contentView.layer.borderColor = UIColor.bbLeaf.cgColor
        } else {
            contentView.layer.borderWidth = 0
        }
    }
}
