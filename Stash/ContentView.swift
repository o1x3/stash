//
//  ContentView.swift
//  Stash
//
//  Created by Karthik Vinayan on 4/12/25.
//

import SwiftUI

struct ContentView: View {
  // MARK: - Dependencies

  var settings: SettingsManager
  @State private var budgetManager: BudgetManager

  // MARK: - State

  @State private var isTagExpanded = false
  @FocusState private var isTagFieldFocused: Bool

  // Settings transition state
  @State private var showSettings = false
  @Namespace private var settingsNamespace

  // MARK: - Initialization

  init(settings: SettingsManager) {
    self.settings = settings
    self._budgetManager = State(initialValue: BudgetManager(settings: settings))
  }

  // MARK: - Body

  var body: some View {
    ZStack {
      Color("AppBackground")
        .ignoresSafeArea()

      // Main content - hide when settings shown (no opacity animation to avoid flicker)
      if !showSettings {
        mainContent
      }

      // Gear button container (isolated, only contains the gear)
      GlassEffectContainer(spacing: 40) {
        if !showSettings {
          VStack {
            HStack {
              Spacer()
              settingsButton
                .padding(.top, 8)
                .padding(.trailing, 16)
            }
            Spacer()
          }
        }
      }

      // Settings view - OUTSIDE the glass container to prevent internal blending
      if showSettings {
        SettingsView(
          settings: settings,
          budgetManager: budgetManager,
          onDismiss: {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
              showSettings = false
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
          },
          onResetBudget: {
            budgetManager.resetBudget()
          }
        )
        .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .topTrailing)))
      }
    }
    .onReceive(
      NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
    ) { _ in
      budgetManager.checkForMidnightReset()
    }
  }

  // MARK: - Main Content

  private var mainContent: some View {
    VStack(spacing: 0) {
      // Header: Budget Bar + Settings
      headerSection
        .padding(.top, 8)

      Spacer()

      // Amount Display (right-aligned)
      AmountDisplayView(
        amount: budgetManager.currentInput,
        currencySymbol: settings.currencySymbol
      )
      .padding(.bottom, 32)

      Spacer()

      // Tag Button/Input
      TagInputView(
        isExpanded: $isTagExpanded,
        savedTagName: $budgetManager.currentTag,
        isFocused: $isTagFieldFocused
      )
      .padding(.horizontal, 16)
      .padding(.bottom, 16)

      // Number Pad
      NumberPadView(
        onDigit: { digit in
          withAnimation(.spring(response: 0.3)) {
            budgetManager.appendDigit(digit)
          }
        },
        onDelete: {
          withAnimation(.spring(response: 0.3)) {
            budgetManager.deleteLastDigit()
          }
        },
        onClearAll: {
          withAnimation(.spring(response: 0.3)) {
            budgetManager.clearAllDigits()
          }
        },
        onConfirm: {
          withAnimation(.easeInOut(duration: 0.5)) {
            budgetManager.confirmExpense()
          }
        },
        hapticsEnabled: settings.hapticsEnabled
      )
      .padding(.bottom, 24)
    }
  }

  // MARK: - Header Section

  private var headerSection: some View {
    HStack(spacing: 12) {
      BudgetBarView(
        remainingBudget: budgetManager.remainingBudget,
        percentage: budgetManager.budgetPercentage,
        budgetColor: budgetManager.budgetColor,
        isOverBudget: budgetManager.isOverBudget,
        currencySymbol: settings.currencySymbol
      )

      // Placeholder for layout (gear is now positioned absolutely in body)
      Color.clear
        .frame(width: 48, height: 48)
    }
    .padding(.horizontal, 16)
  }

  // MARK: - Settings Button

  private var settingsButton: some View {
    Button(action: {
      withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
        showSettings = true
      }
      UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }) {
      Image(systemName: "gearshape.fill")
        .font(.title2)
        .foregroundStyle(.secondary)
        .frame(width: 48, height: 48)
    }
    .glassEffect(.regular.interactive(), in: .capsule)
  }
}

extension Color {
  init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    let a: UInt64
    let r: UInt64
    let g: UInt64
    let b: UInt64
    switch hex.count {
    case 3:
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6:
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8:
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      (a, r, g, b) = (1, 1, 1, 0)
    }

    self.init(
      .sRGB,
      red: Double(r) / 255,
      green: Double(g) / 255,
      blue: Double(b) / 255,
      opacity: Double(a) / 255
    )
  }
}

#Preview {
  ContentView(settings: SettingsManager())
}
