// Models/LedgerStore.swift

import Foundation

final class LedgerStore {

    static let shared = LedgerStore()

    private let userDefaults: UserDefaults

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var transactions: [Transaction] {
        get { load([Transaction].self, forKey: AppConfig.StorageKey.transactions) ?? Transaction.sampleData }
        set { save(newValue, forKey: AppConfig.StorageKey.transactions) }
    }

    var savingsGoals: [SavingsGoal] {
        get { load([SavingsGoal].self, forKey: AppConfig.StorageKey.savingsGoals) ?? SavingsGoal.sampleData }
        set { save(newValue, forKey: AppConfig.StorageKey.savingsGoals) }
    }

    var monthlyBudget: Int {
        get {
            let value = userDefaults.integer(forKey: AppConfig.StorageKey.monthlyBudget)
            return value == 0 ? AppConfig.Defaults.monthlyBudget : value
        }
        set {
            userDefaults.set(newValue, forKey: AppConfig.StorageKey.monthlyBudget)
        }
    }

    var targetZeroDays: Int {
        get {
            let value = userDefaults.integer(forKey: AppConfig.StorageKey.targetZeroDays)
            return value == 0 ? AppConfig.Defaults.targetZeroDays : value
        }
        set {
            userDefaults.set(newValue, forKey: AppConfig.StorageKey.targetZeroDays)
        }
    }

    func addTransaction(_ transaction: Transaction) {
        var current = transactions
        current.append(transaction)
        transactions = current
    }

    func deleteTransaction(id: UUID) {
        var current = transactions
        current.removeAll { $0.id == id }
        transactions = current
    }

    func addSavingsGoal(_ goal: SavingsGoal) {
        var current = savingsGoals
        current.append(goal)
        savingsGoals = current
    }

    func deposit(to goalID: UUID, amount: Int) {
        var current = savingsGoals
        guard let index = current.firstIndex(where: { $0.id == goalID }) else { return }
        current[index].deposit(amount: amount)
        savingsGoals = current
    }

    private func save<T: Encodable>(_ value: T, forKey key: String) {
        guard let encoded = try? JSONEncoder().encode(value) else { return }
        userDefaults.set(encoded, forKey: key)
    }

    private func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
