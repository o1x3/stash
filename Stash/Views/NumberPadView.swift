//
//  NumberPadView.swift
//  Stash
//

import SwiftUI

struct NumberPadView: View {
  let onDigit: (String) -> Void
  let onDelete: () -> Void
  let onConfirm: () -> Void

  private let buttonSpacing: CGFloat = 12
  private let buttonHeight: CGFloat = 56

  var body: some View {
    GlassEffectContainer(spacing: 8) {
      HStack(alignment: .top, spacing: buttonSpacing) {
        // Left side: 3-column number grid
        VStack(spacing: buttonSpacing) {
          // Row 1: 7, 8, 9
          HStack(spacing: buttonSpacing) {
            NumberButton(label: "7") { onDigit("7") }
            NumberButton(label: "8") { onDigit("8") }
            NumberButton(label: "9") { onDigit("9") }
          }
          // Row 2: 4, 5, 6
          HStack(spacing: buttonSpacing) {
            NumberButton(label: "4") { onDigit("4") }
            NumberButton(label: "5") { onDigit("5") }
            NumberButton(label: "6") { onDigit("6") }
          }
          // Row 3: 1, 2, 3
          HStack(spacing: buttonSpacing) {
            NumberButton(label: "1") { onDigit("1") }
            NumberButton(label: "2") { onDigit("2") }
            NumberButton(label: "3") { onDigit("3") }
          }
          // Row 4: 0 (wide), .
          HStack(spacing: buttonSpacing) {
            NumberButton(label: "0", isWide: true) { onDigit("0") }
            NumberButton(label: ".") { onDigit(".") }
          }
        }

        // Right side: Delete + Confirm stack
        VStack(spacing: buttonSpacing) {
          // Delete button (single row height)
          DeleteButton { onDelete() }

          // Confirm button (spans remaining 3 rows)
          ConfirmButton { onConfirm() }
            .frame(height: buttonHeight * 3 + buttonSpacing * 2)
        }
        .frame(width: 72)
      }
      .padding(.horizontal, 20)
    }
  }
}

struct NumberButton: View {
  let label: String
  var isWide: Bool = false
  let action: () -> Void

  var body: some View {
    Button(action: {
      UIImpactFeedbackGenerator(style: .light).impactOccurred()
      action()
    }) {
      Text(label)
        .font(.title)
        .fontWeight(.medium)
        .foregroundStyle(.primary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .frame(height: 56)
    .frame(maxWidth: isWide ? .infinity : nil)
    .buttonStyle(NumberPadButtonStyle())
  }
}

struct DeleteButton: View {
  let action: () -> Void

  var body: some View {
    Button(action: {
      UIImpactFeedbackGenerator(style: .light).impactOccurred()
      action()
    }) {
      Image(systemName: "delete.left")
        .font(.title2)
        .fontWeight(.medium)
        .foregroundStyle(.primary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .frame(height: 56)
    .buttonStyle(NumberPadButtonStyle(tintColor: Color(hex: "E07A5F").opacity(0.3)))
  }
}

struct ConfirmButton: View {
  let action: () -> Void

  var body: some View {
    Button(action: {
      UIImpactFeedbackGenerator(style: .medium).impactOccurred()
      action()
    }) {
      Image(systemName: "checkmark")
        .font(.title)
        .fontWeight(.bold)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .buttonStyle(ConfirmButtonStyle())
  }
}

struct NumberPadButtonStyle: ButtonStyle {
  var tintColor: Color? = nil

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .background {
        Capsule()
          .fill(tintColor ?? Color.clear)
      }
      .glassEffect(.regular.interactive(), in: .capsule)
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
      .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
  }
}

struct ConfirmButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .background {
        Capsule()
          .fill(Color(hex: "E07A5F"))
      }
      .glassEffect(.regular.tint(Color(hex: "E07A5F")).interactive(), in: .capsule)
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
      .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
  }
}

#Preview {
  ZStack {
    Color(hex: "FFE5D9").ignoresSafeArea()
    NumberPadView(
      onDigit: { _ in },
      onDelete: {},
      onConfirm: {}
    )
  }
}
