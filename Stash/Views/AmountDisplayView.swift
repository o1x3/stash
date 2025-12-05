//
//  AmountDisplayView.swift
//  Stash
//

import SwiftUI

struct AmountDisplayView: View {
  let amount: String
  var currencySymbol: String = "$"
  @State private var cursorOpacity: Double = 1.0

  private var formattedAmount: String {
    if amount == "0" {
      return "0"
    }
    if amount.contains(".") {
      let parts = amount.split(separator: ".", omittingEmptySubsequences: false)
      if parts.count == 1 || (parts.count == 2 && parts[1].isEmpty) {
        return amount
      } else if parts.count == 2 && parts[1].count == 1 {
        return amount
      } else {
        let value = Double(amount) ?? 0
        return String(format: "%.2f", value)
      }
    }
    return amount
  }

  var body: some View {
    HStack {
      Spacer()
      HStack(spacing: 4) {
        // Currency symbol
        Text(currencySymbol)
          .font(.system(size: 48, weight: .medium, design: .monospaced))
          .foregroundStyle(.secondary)

        HStack(spacing: 0) {
          // Animated amount text
          Text(formattedAmount)
            .font(.system(size: 72, weight: .bold, design: .monospaced))
            .foregroundStyle(.primary)
            .contentTransition(.numericText(countsDown: false))
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: amount)

          // Animated cursor line (blinking)
          Rectangle()
            .fill(Color("AccentPrimary"))
            .frame(width: 3, height: 56)
            .opacity(cursorOpacity)
            .animation(
              .easeInOut(duration: 0.6)
                .repeatForever(autoreverses: true),
              value: cursorOpacity
            )
            .onAppear {
              cursorOpacity = 0.3
            }
        }
      }
      .padding(.trailing, 24)
    }
  }
}

#Preview {
  ZStack {
    Color("AppBackground").ignoresSafeArea()
    VStack(spacing: 20) {
      AmountDisplayView(amount: "0")
      AmountDisplayView(amount: "4.20")
      AmountDisplayView(amount: "123.45")
    }
  }
}
