// Models/PaymentMethod.swift

import Foundation

enum PaymentMethod: String, CaseIterable, Codable {
    case creditCard   = "신용카드"
    case debitCard    = "체크카드"
    case bankTransfer = "계좌이체"
    case kakaoPay     = "카카오페이"
    case naverPay     = "네이버페이"
    case tossPay      = "토스페이"
    case cash         = "현금"

    var icon: String {
        switch self {
        case .creditCard:   return "💳"
        case .debitCard:    return "💳"
        case .bankTransfer: return "🏦"
        case .kakaoPay:     return "💛"
        case .naverPay:     return "💚"
        case .tossPay:      return "💙"
        case .cash:         return "💵"
        }
    }
}
