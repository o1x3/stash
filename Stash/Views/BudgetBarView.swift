//
//  BudgetBarView.swift
//  Stash
//

import SwiftUI

struct BudgetBarView: View {
  let remainingBudget: Double
  let percentage: Double
  let budgetColor: Color
  let isOverBudget: Bool

  private var formattedBudget: String {
    if isOverBudget {
      return "-" + String(format: "%.2f", abs(remainingBudget))
    }
    return String(format: "%.2f", remainingBudget)
  }

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        // Layer 1: Track background (very subtle)
        Capsule()
          .fill(Color.primary.opacity(0.08))

        // Layer 2: Colored progress fill (animates width)
        Capsule()
          .fill(budgetColor.opacity(0.85))
          .frame(
            width: isOverBudget ? geometry.size.width : geometry.size.width * max(0, percentage)
          )
          .animation(.spring(response: 0.6, dampingFraction: 0.8), value: percentage)
          .animation(.easeInOut(duration: 0.4), value: budgetColor)

        // Layer 3: Glass effect overlay (samples the color underneath)
        Capsule()
          .fill(.clear)
          .glassEffect(.regular, in: .capsule)

        // Layer 4: Text content
        HStack {
          Text("For today")
            .foregroundStyle(.primary.opacity(0.7))
          Spacer()
          Text(formattedBudget)
            .fontWeight(.semibold)
            .foregroundStyle(isOverBudget ? Color("BudgetRed") : .primary)
            .contentTransition(.numericText())
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: remainingBudget)
        }
        .font(.subheadline)
        .padding(.horizontal, 20)
      }
    }
    .frame(height: 52)
  }
}

#Preview {
  ZStack {
    Color("AppBackground").ignoresSafeArea()
    VStack(spacing: 20) {
      BudgetBarView(
        remainingBudget: 75.50,
        percentage: 0.755,
        budgetColor: Color("BudgetGreen"),
        isOverBudget: false
      )
      BudgetBarView(
        remainingBudget: 35.00,
        percentage: 0.35,
        budgetColor: Color("BudgetYellow"),
        isOverBudget: false
      )
      BudgetBarView(
        remainingBudget: 15.00,
        percentage: 0.15,
        budgetColor: Color("BudgetRed"),
        isOverBudget: false
      )
      BudgetBarView(
        remainingBudget: -10.00,
        percentage: 0,
        budgetColor: Color("BudgetOverRed"),
        isOverBudget: true
      )
    }
    .padding()
  }
}
