// Models/Transaction.swift

import Foundation

// MARK: - TransactionType: 수입 / 지출 구분
enum TransactionType: String, Codable {
    case income  = "수입"
    case expense = "지출"
}

// MARK: - Transaction: 핵심 가계부 데이터 모델
struct Transaction: Codable, Identifiable {

    let id: UUID                        // 고유 식별자
    var type: TransactionType           // 수입 / 지출
    var amount: Int                     // 금액 (원 단위 정수)
    var date: Date                      // 발생 일자
    var category: Category              // 카테고리
    var paymentMethod: PaymentMethod    // 결제 수단
    var memo: String                    // 메모 (선택)

    // MARK: - 이니셜라이저
    init(
        id: UUID = UUID(),
        type: TransactionType,
        amount: Int,
        date: Date = Date(),
        category: Category,
        paymentMethod: PaymentMethod,
        memo: String = ""
    ) {
        self.id = id
        self.type = type
        self.amount = amount
        self.date = date
        self.category = category
        self.paymentMethod = paymentMethod
        self.memo = memo
    }

    // MARK: - 편의 계산 프로퍼티

    /// 화면 표시용 부호 포함 금액 문자열 (예: "+50,000원" / "-12,000원")
    var formattedAmount: String {
        let sign = (type == .income) ? "+" : "-"
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "\(sign)\(formatted)원"
    }

    /// 화면 표시용 날짜 문자열 (예: "2025.06.04")
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = AppConfig.DateFormat.displayDate
        return formatter.string(from: date)
    }

    /// 해당 날짜의 "년-월" 키 (월별 필터링에 활용)
    var yearMonthKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = AppConfig.DateFormat.yearMonthKey
        return formatter.string(from: date)
    }

    /// 해당 날짜의 "일(day)" 정수값 (캘린더 뷰에 활용)
    var dayOfMonth: Int {
        Calendar.current.component(.day, from: date)
    }
}

// MARK: - [샘플 데이터] 개발/테스트용 더미 트랜잭션
extension Transaction {
    static let sampleData: [Transaction] = [
        Transaction(type: .expense, amount: 8_500,     date: .daysAgo(0), category: .food,      paymentMethod: .debitCard,    memo: "한성 후문 점심"),
        Transaction(type: .expense, amount: 55_000,    date: .daysAgo(1), category: .transport, paymentMethod: .creditCard,   memo: "쏘카 대여"),
        Transaction(type: .income,  amount: 3_500_000, date: .daysAgo(2), category: .salary,    paymentMethod: .bankTransfer, memo: "실무 급여"),
        Transaction(type: .expense, amount: 82_100,    date: .daysAgo(3), category: .housing,   paymentMethod: .bankTransfer, memo: "통신비 정기 납부"),
        Transaction(type: .expense, amount: 32_000,    date: .daysAgo(4), category: .shopping,  paymentMethod: .naverPay,     memo: "생활용품"),
        Transaction(type: .expense, amount: 12_000,    date: .daysAgo(5), category: .culture,   paymentMethod: .kakaoPay,     memo: "OTT 구독"),
        Transaction(type: .income,  amount: 100_000,   date: .daysAgo(6), category: .allowance, paymentMethod: .bankTransfer, memo: "용돈"),
        Transaction(type: .expense, amount: 55_000,    date: .daysAgo(7), category: .health,    paymentMethod: .creditCard,   memo: "약국"),
    ]
}

// MARK: - Date 생성 헬퍼 (샘플 데이터 전용)
private extension Date {
    static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }
}
