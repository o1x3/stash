//
//  BudgetManager.swift
//  Stash
//

import Foundation
import SwiftUI

@Observable
final class BudgetManager {
  private let dailyBudget: Double = 100.0
  private let budgetKey = "remainingBudget"
  private let dateKey = "lastBudgetDate"

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
      return Color(hex: "FFCDD2")
    } else if percentage <= 0.25 {
      return Color(hex: "F44336")
    } else if percentage <= 0.5 {
      return Color(hex: "FFC107")
    } else {
      return Color(hex: "4CAF50")
    }
  }

  var isOverBudget: Bool {
    remainingBudget < 0
  }

  var formattedRemainingBudget: String {
    if isOverBudget {
      return "-" + String(format: "%.2f", abs(remainingBudget))
    }
    return String(format: "%.2f", remainingBudget)
  }

  init() {
    let savedDate = UserDefaults.standard.string(forKey: dateKey) ?? ""
    let today = Self.todayString()

    if savedDate == today {
      self.remainingBudget = UserDefaults.standard.double(forKey: budgetKey)
      if self.remainingBudget == 0 && !UserDefaults.standard.bool(forKey: "hasSetBudget") {
        self.remainingBudget = dailyBudget
        UserDefaults.standard.set(true, forKey: "hasSetBudget")
      }
    } else {
      self.remainingBudget = dailyBudget
      UserDefaults.standard.set(today, forKey: dateKey)
      UserDefaults.standard.set(true, forKey: "hasSetBudget")
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
    remainingBudget = dailyBudget
    UserDefaults.standard.set(Self.todayString(), forKey: dateKey)
  }

  func checkForMidnightReset() {
    let savedDate = UserDefaults.standard.string(forKey: dateKey) ?? ""
    let today = Self.todayString()

    if savedDate != today {
      resetBudget()
    }
  }

  private static func todayString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: Date())
  }
}
