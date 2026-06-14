// Models/SavingsGoal.swift

import Foundation

// MARK: - SavingsGoal: 저축 목표 슬롯 모델
struct SavingsGoal: Codable, Identifiable {

    let id: UUID
    var title: String           // 목표 이름 (예: "맥북 구매")
    var targetAmount: Int       // 목표 금액
    var savedAmount: Int        // 현재 적립 금액
    var emoji: String           // 목표 대표 이모지
    var createdAt: Date

    // MARK: - 이니셜라이저
    init(
        id: UUID = UUID(),
        title: String,
        targetAmount: Int,
        savedAmount: Int = 0,
        emoji: String = AppConfig.Defaults.savingsGoalEmoji,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.targetAmount = targetAmount
        self.savedAmount = savedAmount
        self.emoji = emoji
        self.createdAt = createdAt
    }

    // MARK: - 계산 프로퍼티

    /// 달성률 (0.0 ~ 1.0)
    var progressRate: Double {
        guard targetAmount > 0 else { return 0 }
        return min(Double(savedAmount) / Double(targetAmount), 1.0)
    }

    /// 퍼센트 문자열 (예: "73%")
    var progressPercentText: String {
        return "\(Int(progressRate * 100))%"
    }

    /// 목표 달성 여부
    var isCompleted: Bool {
        return savedAmount >= targetAmount
    }

    /// 잔여 금액
    var remainingAmount: Int {
        return max(targetAmount - savedAmount, 0)
    }

    /// 화면 표시용 잔여 금액 문자열
    var formattedRemainingAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return "\(formatter.string(from: NSNumber(value: remainingAmount)) ?? "\(remainingAmount)")원 남음"
    }

    // MARK: - 간편 충전 금액 옵션
    static let quickAddAmounts = AppConfig.Savings.quickAddAmounts

    // MARK: - 뮤테이팅: 금액 적립
    mutating func deposit(amount: Int) {
        savedAmount = min(savedAmount + amount, targetAmount)
    }
}

// MARK: - [샘플 데이터]
extension SavingsGoal {
    static let sampleData: [SavingsGoal] = [
        SavingsGoal(title: "맥북 프로 구매", targetAmount: 3_000_000, savedAmount: 1_200_000, emoji: "💻"),
        SavingsGoal(title: "제주도 여행",    targetAmount: 500_000,   savedAmount: 320_000,   emoji: "✈️"),
        SavingsGoal(title: "비상금 마련",    targetAmount: 1_000_000, savedAmount: 50_000,    emoji: "🔒"),
    ]
}
