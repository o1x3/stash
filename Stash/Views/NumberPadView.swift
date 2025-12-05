//
//  NumberPadView.swift
//  Stash
//

import SwiftUI

struct NumberPadView: View {
  let onDigit: (String) -> Void
  let onDelete: () -> Void
  let onClearAll: () -> Void
  let onConfirm: () -> Void

  // Reusable haptic generators - created once, reused for all taps
  // This prevents latency from Taptic Engine wake-up on rapid taps
  private let lightHaptic = UIImpactFeedbackGenerator(style: .light)
  private let mediumHaptic = UIImpactFeedbackGenerator(style: .medium)

  private let buttonSpacing: CGFloat = 12
  private let buttonHeight: CGFloat = 56

  var body: some View {
    GlassEffectContainer(spacing: 8) {
      HStack(alignment: .top, spacing: buttonSpacing) {
        // Left side: 3-column number grid
        VStack(spacing: buttonSpacing) {
          // Row 1: 7, 8, 9
          HStack(spacing: buttonSpacing) {
            NumberButton(label: "7", haptic: lightHaptic) { onDigit("7") }
            NumberButton(label: "8", haptic: lightHaptic) { onDigit("8") }
            NumberButton(label: "9", haptic: lightHaptic) { onDigit("9") }
          }
          // Row 2: 4, 5, 6
          HStack(spacing: buttonSpacing) {
            NumberButton(label: "4", haptic: lightHaptic) { onDigit("4") }
            NumberButton(label: "5", haptic: lightHaptic) { onDigit("5") }
            NumberButton(label: "6", haptic: lightHaptic) { onDigit("6") }
          }
          // Row 3: 1, 2, 3
          HStack(spacing: buttonSpacing) {
            NumberButton(label: "1", haptic: lightHaptic) { onDigit("1") }
            NumberButton(label: "2", haptic: lightHaptic) { onDigit("2") }
            NumberButton(label: "3", haptic: lightHaptic) { onDigit("3") }
          }
          // Row 4: 0 (wide), .
          HStack(spacing: buttonSpacing) {
            NumberButton(label: "0", isWide: true, haptic: lightHaptic) { onDigit("0") }
            NumberButton(label: ".", haptic: lightHaptic) { onDigit(".") }
          }
        }

        // Right side: Delete + Confirm stack
        VStack(spacing: buttonSpacing) {
          // Delete button (single row height)
          // Tap to delete one digit, long press to clear all
          DeleteButton(haptic: lightHaptic, onDelete: onDelete, onClearAll: onClearAll)

          // Confirm button (spans remaining 3 rows)
          ConfirmButton(haptic: mediumHaptic) { onConfirm() }
            .frame(height: buttonHeight * 3 + buttonSpacing * 2)
        }
        .frame(width: 72)
      }
      .padding(.horizontal, 20)
    }
    .onAppear {
      // Pre-warm the Taptic Engine for lowest latency on first tap
      lightHaptic.prepare()
      mediumHaptic.prepare()
    }
  }
}

struct NumberButton: View {
  let label: String
  var isWide: Bool = false
  let haptic: UIImpactFeedbackGenerator
  let action: () -> Void

  var body: some View {
    Button(action: {
      haptic.impactOccurred()
      haptic.prepare()  // Re-prepare for next rapid tap
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
  let haptic: UIImpactFeedbackGenerator
  let onDelete: () -> Void
  let onClearAll: () -> Void

  private let heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)

  var body: some View {
    Image(systemName: "delete.left")
      .font(.title2)
      .fontWeight(.medium)
      .foregroundStyle(.primary)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .frame(height: 56)
      .background {
        Capsule()
          .fill(Color("AccentPrimary").opacity(0.5))
      }
      .glassEffect(.regular.interactive(), in: .capsule)
      .onTapGesture {
        haptic.impactOccurred()
        haptic.prepare()
        onDelete()
      }
      .onLongPressGesture(minimumDuration: 0.5) {
        heavyHaptic.impactOccurred()
        heavyHaptic.prepare()
        onClearAll()
      }
      .onAppear {
        heavyHaptic.prepare()
      }
  }
}

struct ConfirmButton: View {
  let haptic: UIImpactFeedbackGenerator
  let action: () -> Void

  var body: some View {
    Button(action: {
      haptic.impactOccurred()
      haptic.prepare()  // Re-prepare for next rapid tap
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
          .fill(Color("AccentPrimary"))
      }
      .glassEffect(.regular.tint(Color("AccentPrimary")).interactive(), in: .capsule)
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
      .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
  }
}

#Preview {
  ZStack {
    Color("AppBackground").ignoresSafeArea()
    NumberPadView(
      onDigit: { _ in },
      onDelete: {},
      onClearAll: {},
      onConfirm: {}
    )
  }
}
