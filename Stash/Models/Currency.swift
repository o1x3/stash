//
//  Currency.swift
//  Stash
//

import Foundation

enum Currency: String, CaseIterable, Identifiable {
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case jpy = "JPY"
    case cny = "CNY"
    case inr = "INR"
    case krw = "KRW"
    case cad = "CAD"
    case aud = "AUD"
    case chf = "CHF"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .jpy: return "¥"
        case .cny: return "¥"
        case .inr: return "₹"
        case .krw: return "₩"
        case .cad: return "C$"
        case .aud: return "A$"
        case .chf: return "CHF "
        }
    }

    var name: String {
        switch self {
        case .usd: return "US Dollar"
        case .eur: return "Euro"
        case .gbp: return "British Pound"
        case .jpy: return "Japanese Yen"
        case .cny: return "Chinese Yuan"
        case .inr: return "Indian Rupee"
        case .krw: return "Korean Won"
        case .cad: return "Canadian Dollar"
        case .aud: return "Australian Dollar"
        case .chf: return "Swiss Franc"
        }
    }

    /// Some currencies don't use decimal places (e.g., JPY, KRW)
    var usesDecimals: Bool {
        switch self {
        case .jpy, .krw:
            return false
        default:
            return true
        }
    }

    /// Flag emoji for visual representation
    var flag: String {
        switch self {
        case .usd: return "🇺🇸"
        case .eur: return "🇪🇺"
        case .gbp: return "🇬🇧"
        case .jpy: return "🇯🇵"
        case .cny: return "🇨🇳"
        case .inr: return "🇮🇳"
        case .krw: return "🇰🇷"
        case .cad: return "🇨🇦"
        case .aud: return "🇦🇺"
        case .chf: return "🇨🇭"
        }
    }
}
