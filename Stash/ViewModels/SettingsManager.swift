//
//  SettingsManager.swift
//  Stash
//

import Foundation

@Observable
final class SettingsManager {
    // MARK: - UserDefaults Keys

    private enum Keys {
        static let dailyBudget = "settings.dailyBudget"
        static let currencyCode = "settings.currencyCode"
        static let hapticsEnabled = "settings.hapticsEnabled"
        static let budgetWarningThreshold = "settings.budgetWarningThreshold"
    }

    // MARK: - Default Values

    private enum Defaults {
        static let dailyBudget: Double = 100.0
        static let currencyCode = "USD"
        static let hapticsEnabled = true
        static let budgetWarningThreshold = 0.25
    }

    // MARK: - Settings Properties

    var dailyBudget: Double {
        didSet {
            let oldValue = UserDefaults.standard.double(forKey: Keys.dailyBudget)
            UserDefaults.standard.set(dailyBudget, forKey: Keys.dailyBudget)
            onBudgetChanged?(oldValue > 0 ? oldValue : Defaults.dailyBudget, dailyBudget)
        }
    }

    var currencyCode: String {
        didSet {
            UserDefaults.standard.set(currencyCode, forKey: Keys.currencyCode)
        }
    }

    var hapticsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(hapticsEnabled, forKey: Keys.hapticsEnabled)
        }
    }

    var budgetWarningThreshold: Double {
        didSet {
            UserDefaults.standard.set(budgetWarningThreshold, forKey: Keys.budgetWarningThreshold)
        }
    }

    // MARK: - Callbacks

    /// Called when dailyBudget changes: (oldValue, newValue)
    var onBudgetChanged: ((Double, Double) -> Void)?

    // MARK: - Computed Properties

    var currency: Currency {
        Currency(rawValue: currencyCode) ?? .usd
    }

    var currencySymbol: String {
        currency.symbol
    }

    var currencyUsesDecimals: Bool {
        currency.usesDecimals
    }

    // MARK: - Initialization

    init() {
        let defaults = UserDefaults.standard

        // Load saved values or use defaults
        let savedBudget = defaults.object(forKey: Keys.dailyBudget) as? Double
        self.dailyBudget = savedBudget ?? Defaults.dailyBudget

        self.currencyCode = defaults.string(forKey: Keys.currencyCode) ?? Defaults.currencyCode

        // Bool needs special handling - check if key exists
        if defaults.object(forKey: Keys.hapticsEnabled) != nil {
            self.hapticsEnabled = defaults.bool(forKey: Keys.hapticsEnabled)
        } else {
            self.hapticsEnabled = Defaults.hapticsEnabled
        }

        let savedThreshold = defaults.object(forKey: Keys.budgetWarningThreshold) as? Double
        self.budgetWarningThreshold = savedThreshold ?? Defaults.budgetWarningThreshold
    }

    // MARK: - Helper Methods

    /// Format amount with current currency symbol
    func formatAmount(_ amount: Double, showDecimals: Bool? = nil) -> String {
        let useDecimals = showDecimals ?? currencyUsesDecimals
        let format = useDecimals ? "%.2f" : "%.0f"
        return currencySymbol + String(format: format, amount)
    }

    /// Format amount for display (handles negative values)
    func formatBudgetAmount(_ amount: Double) -> String {
        if amount < 0 {
            let absAmount = abs(amount)
            let format = currencyUsesDecimals ? "%.2f" : "%.0f"
            return "-" + currencySymbol + String(format: format, absAmount)
        }
        return formatAmount(amount)
    }
}
