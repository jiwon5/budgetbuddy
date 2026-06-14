// Models/Category.swift

import UIKit

enum Category: String, CaseIterable, Codable {
    case food           = "식비"
    case shopping       = "쇼핑/생필품"
    case transport      = "교통/차량"
    case housing        = "주거/통신/공과금"
    case culture        = "문화/여가/유흥"
    case health         = "의료/건강"
    case education      = "교육/학습"
    case salary         = "월급/급여"
    case allowance      = "용돈"
    case finance        = "금융/이자소득"
    case other          = "기타"

    var icon: String {
        switch self {
        case .food:      return "🍽️"
        case .shopping:  return "🛍️"
        case .transport: return "🚗"
        case .housing:   return "🏠"
        case .culture:   return "🎬"
        case .health:    return "🏥"
        case .education: return "🎓"
        case .salary:    return "💼"
        case .allowance: return "🎁"
        case .finance:   return "📈"
        case .other:     return "📦"
        }
    }

    var color: UIColor {
        switch self {
        case .food:      return UIColor(red: 1.00, green: 0.60, blue: 0.40, alpha: 1)
        case .shopping:  return UIColor(red: 0.46, green: 0.43, blue: 0.92, alpha: 1)
        case .transport: return UIColor(red: 0.40, green: 0.70, blue: 1.00, alpha: 1)
        case .housing:   return UIColor(red: 0.60, green: 0.80, blue: 0.50, alpha: 1)
        case .culture:   return UIColor(red: 0.70, green: 0.60, blue: 1.00, alpha: 1)
        case .health:    return UIColor(red: 0.40, green: 0.85, blue: 0.75, alpha: 1)
        case .education: return UIColor(red: 0.30, green: 0.55, blue: 0.95, alpha: 1)
        case .salary:    return UIColor(red: 0.25, green: 0.55, blue: 0.95, alpha: 1)
        case .allowance: return UIColor(red: 1.00, green: 0.45, blue: 0.70, alpha: 1)
        case .finance:   return UIColor(red: 1.00, green: 0.85, blue: 0.35, alpha: 1)
        case .other:     return UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1)
        }
    }

    var transactionType: TransactionType {
        switch self {
        case .salary, .allowance, .finance:
            return .income
        default:
            return .expense
        }
    }
}

extension Category {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        switch rawValue {
        case "교통비":
            self = .transport
        case "주거/통신":
            self = .housing
        case "패션/쇼핑", "뷰티/미용":
            self = .shopping
        case "문화/여가":
            self = .culture
        case "금융":
            self = .finance
        case "기타 지출", "기타 수입":
            self = .other
        default:
            self = Category(rawValue: rawValue) ?? .other
        }
    }
}
