//
//  BudgetManager.swift
//  Stash
//

import Foundation
import SwiftUI

@Observable
final class BudgetManager {
  private let budgetKey = "remainingBudget"
  private let dateKey = "lastBudgetDate"

  // MARK: - Settings Dependency

  private var settings: SettingsManager

  var dailyBudget: Double {
    settings.dailyBudget
  }

  var remainingBudget: Double {
    didSet {
      UserDefaults.standard.set(remainingBudget, forKey: budgetKey)
    }
  }

  var currentInput: String = "0"
  var currentTag: String = "Tag"

  var currentAmount: Double {
    Double(currentInput) ?? 0.0
  }

  var budgetPercentage: Double {
    max(0, remainingBudget / dailyBudget)
  }

  var budgetColor: Color {
    let percentage = remainingBudget / dailyBudget
    if percentage <= 0 {
      return Color("BudgetOverRed")
    } else if percentage <= settings.budgetWarningThreshold {
      return Color("BudgetRed")
    } else if percentage <= 0.5 {
      return Color("BudgetYellow")
    } else {
      return Color("BudgetGreen")
    }
  }

  var isOverBudget: Bool {
    remainingBudget < 0
  }

  var formattedRemainingBudget: String {
    settings.formatBudgetAmount(remainingBudget)
  }

  init(settings: SettingsManager) {
    self.settings = settings

    let savedDate = UserDefaults.standard.string(forKey: dateKey) ?? ""
    let today = Self.todayString()

    if savedDate == today {
      self.remainingBudget = UserDefaults.standard.double(forKey: budgetKey)
      if self.remainingBudget == 0 && !UserDefaults.standard.bool(forKey: "hasSetBudget") {
        self.remainingBudget = settings.dailyBudget
        UserDefaults.standard.set(true, forKey: "hasSetBudget")
      }
    } else {
      self.remainingBudget = settings.dailyBudget
      UserDefaults.standard.set(today, forKey: dateKey)
      UserDefaults.standard.set(true, forKey: "hasSetBudget")
    }

    // Set up proportional budget scaling when settings change
    settings.onBudgetChanged = { [weak self] oldBudget, newBudget in
      self?.adjustBudgetProportionally(from: oldBudget, to: newBudget)
    }
  }

  func appendDigit(_ digit: String) {
    if digit == "." {
      if currentInput.contains(".") { return }
      currentInput += digit
    } else {
      if currentInput == "0" && digit != "." {
        currentInput = digit
      } else {
        let parts = currentInput.split(separator: ".")
        if parts.count == 2 && parts[1].count >= 2 {
          return
        }
        currentInput += digit
      }
    }
  }

  func deleteLastDigit() {
    if currentInput.count > 1 {
      currentInput.removeLast()
    } else {
      currentInput = "0"
    }
  }

  func clearAllDigits() {
    currentInput = "0"
  }

  func confirmExpense() {
    guard currentAmount > 0 else { return }
    remainingBudget -= currentAmount
    currentInput = "0"

    UINotificationFeedbackGenerator().notificationOccurred(.success)
  }

  func updateTag(_ newTag: String) {
    let trimmed = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
    currentTag = trimmed.isEmpty ? "Tag" : trimmed
  }

  func resetBudget() {
    remainingBudget = settings.dailyBudget
    UserDefaults.standard.set(Self.todayString(), forKey: dateKey)
  }

  func checkForMidnightReset() {
    let savedDate = UserDefaults.standard.string(forKey: dateKey) ?? ""
    let today = Self.todayString()

    if savedDate != today {
      resetBudget()
    }
  }

  // MARK: - Proportional Budget Scaling

  /// When daily budget changes mid-day, scale remaining budget proportionally
  /// Example: $100 budget with $40 remaining (40%) -> $150 budget = $60 remaining (still 40%)
  private func adjustBudgetProportionally(from oldBudget: Double, to newBudget: Double) {
    guard oldBudget > 0 else {
      // First time setting budget or invalid old value
      remainingBudget = newBudget
      return
    }

    // Calculate what percentage of budget remains
    let percentageRemaining = remainingBudget / oldBudget

    // Apply same percentage to new budget
    remainingBudget = newBudget * percentageRemaining
  }

  private static func todayString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: Date())
  }
}
