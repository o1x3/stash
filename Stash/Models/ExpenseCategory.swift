//
//  ExpenseCategory.swift
//  Stash
//

import Foundation

enum ExpenseCategory: String, CaseIterable, Identifiable {
  case food = "Food"
  case transport = "Transport"
  case shopping = "Shopping"
  case entertainment = "Entertainment"
  case bills = "Bills"

  var id: String { rawValue }
}
