// Config/AppConfig.swift

import Foundation

enum AppConfig {

    enum Defaults {
        static let monthlyBudget = 1_000_000
        static let targetZeroDays = 10
        static let savingsGoalEmoji = "🎯"
    }

    enum StorageKey {
        static let transactions = "budgetbuddy_transactions"
        static let savingsGoals = "budgetbuddy_savings_goals"
        static let monthlyBudget = "budgetbuddy_monthly_budget"
        static let targetZeroDays = "budgetbuddy_target_zero_days"
    }

    enum DateFormat {
        static let displayDate = "yyyy.MM.dd"
        static let yearMonthKey = "yyyy-MM"
    }

    enum Dashboard {
        static let categoryRankLimit = 5
    }

    enum Savings {
        static let quickAddAmounts = [5_000, 10_000, 30_000, 50_000, 100_000]
    }

    enum GoalChallenge {
        static let excellentRate = 0.8
        static let activeRate = 0.5
    }
}
