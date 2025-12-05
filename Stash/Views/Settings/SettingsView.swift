//
//  SettingsView.swift
//  Stash
//

import SwiftUI

struct SettingsView: View {
  @Bindable var settings: SettingsManager
  let onDismiss: () -> Void
  let onResetBudget: () -> Void

  @State private var showResetConfirmation = false
  @State private var showCurrencyPicker = false
  @State private var showBudgetPicker = false

  var body: some View {
    ZStack {
      Color("AppBackground")
        .ignoresSafeArea()

      VStack(spacing: 0) {
        // Header with back button
        headerSection
          .padding(.top, 60)
          .padding(.bottom, 32)

        // Settings content
        ScrollView {
          VStack(spacing: 24) {
            // Budget Section
            settingsSection("Budget") {
              VStack(spacing: 12) {
                SettingsRow(
                  icon: "dollarsign.circle.fill",
                  title: "Daily Limit",
                  value: settings.formatAmount(settings.dailyBudget),
                  showChevron: true
                ) {
                  showBudgetPicker = true
                }

                SettingsRow(
                  icon: "globe",
                  title: "Currency",
                  value: "\(settings.currency.flag) \(settings.currency.symbol)",
                  showChevron: true
                ) {
                  showCurrencyPicker = true
                }
              }
            }

            // Preferences Section
            settingsSection("Preferences") {
              SettingsToggleRow(
                icon: "iphone.radiowaves.left.and.right",
                title: "Haptic Feedback",
                isOn: $settings.hapticsEnabled
              )
            }

            // Actions Section
            settingsSection("Actions") {
              Button(action: { showResetConfirmation = true }) {
                HStack {
                  Image(systemName: "arrow.counterclockwise")
                    .font(.body)
                    .foregroundStyle(.red)
                  Text("Reset Today's Budget")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.red)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
              }
              .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
            }

            // Footer
            footerSection
              .padding(.top, 32)
          }
          .padding(.horizontal, 16)
        }
      }
    }
    .sheet(isPresented: $showCurrencyPicker) {
      CurrencyPickerView(selectedCurrency: $settings.currencyCode)
        .presentationDetents([.medium, .large])
    }
    .sheet(isPresented: $showBudgetPicker) {
      BudgetPickerView(dailyBudget: $settings.dailyBudget, currencySymbol: settings.currencySymbol)
        .presentationDetents([.medium])
    }
    .alert("Reset Budget?", isPresented: $showResetConfirmation) {
      Button("Cancel", role: .cancel) { }
      Button("Reset", role: .destructive) {
        onResetBudget()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
      }
    } message: {
      Text("This will reset your remaining budget to \(settings.formatAmount(settings.dailyBudget)) for today.")
    }
  }

  // MARK: - Header

  private var headerSection: some View {
    HStack {
      // Back button
      Button(action: onDismiss) {
        Image(systemName: "chevron.left")
          .font(.title2)
          .fontWeight(.semibold)
          .foregroundStyle(.primary)
          .frame(width: 48, height: 48)
      }
      .glassEffect(.regular.interactive(), in: .capsule)

      Spacer()

      Text("Settings")
        .font(.title2)
        .fontWeight(.bold)

      Spacer()

      // Invisible spacer for balance
      Color.clear
        .frame(width: 48, height: 48)
    }
    .padding(.horizontal, 16)
  }

  // MARK: - Section Builder

  @ViewBuilder
  private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title.uppercased())
        .font(.footnote)
        .fontWeight(.semibold)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 4)

      content()
    }
  }

  // MARK: - Footer

  private var footerSection: some View {
    VStack(spacing: 4) {
      Text("Stash")
        .font(.footnote)
        .fontWeight(.medium)
        .foregroundStyle(.secondary)

      Text("Version 1.0")
        .font(.caption2)
        .foregroundStyle(.tertiary)
    }
  }
}

// MARK: - Settings Row

struct SettingsRow: View {
  let icon: String
  let title: String
  var value: String? = nil
  var showChevron: Bool = false
  var action: (() -> Void)? = nil

  var body: some View {
    Button(action: { action?() }) {
      HStack {
        Image(systemName: icon)
          .font(.body)
          .foregroundStyle(Color("AccentPrimary"))
          .frame(width: 24)

        Text(title)
          .font(.body)
          .foregroundStyle(.primary)

        Spacer()

        if let value = value {
          Text(value)
            .font(.body)
            .foregroundStyle(.secondary)
        }

        if showChevron {
          Image(systemName: "chevron.right")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.tertiary)
        }
      }
      .padding(.horizontal, 16)
      .frame(height: 52)
    }
    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
    .disabled(action == nil)
  }
}

// MARK: - Settings Toggle Row

struct SettingsToggleRow: View {
  let icon: String
  let title: String
  @Binding var isOn: Bool

  var body: some View {
    HStack {
      Image(systemName: icon)
        .font(.body)
        .foregroundStyle(Color("AccentPrimary"))
        .frame(width: 24)

      Text(title)
        .font(.body)
        .foregroundStyle(.primary)

      Spacer()

      Toggle("", isOn: $isOn)
        .labelsHidden()
        .tint(Color("AccentPrimary"))
    }
    .padding(.horizontal, 16)
    .frame(height: 52)
    .glassEffect(.regular, in: .rect(cornerRadius: 16))
  }
}

// MARK: - Currency Picker

struct CurrencyPickerView: View {
  @Environment(\.dismiss) private var dismiss
  @Binding var selectedCurrency: String

  var body: some View {
    NavigationStack {
      ZStack {
        Color("AppBackground")
          .ignoresSafeArea()

        ScrollView {
          LazyVStack(spacing: 8) {
            ForEach(Currency.allCases) { currency in
              Button(action: {
                selectedCurrency = currency.rawValue
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                dismiss()
              }) {
                HStack {
                  Text(currency.flag)
                    .font(.title2)

                  VStack(alignment: .leading, spacing: 2) {
                    Text(currency.name)
                      .font(.body)
                      .foregroundStyle(.primary)
                    Text(currency.rawValue)
                      .font(.caption)
                      .foregroundStyle(.secondary)
                  }

                  Spacer()

                  Text(currency.symbol)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                  if currency.rawValue == selectedCurrency {
                    Image(systemName: "checkmark.circle.fill")
                      .font(.title3)
                      .foregroundStyle(Color("AccentPrimary"))
                  }
                }
                .padding(.horizontal, 16)
                .frame(height: 60)
              }
              .glassEffect(
                currency.rawValue == selectedCurrency
                  ? .regular.tint(Color("AccentPrimary").opacity(0.3)).interactive()
                  : .regular.interactive(),
                in: .rect(cornerRadius: 16)
              )
            }
          }
          .padding(.horizontal, 16)
          .padding(.top, 16)
        }
      }
      .navigationTitle("Currency")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done") { dismiss() }
            .fontWeight(.semibold)
        }
      }
    }
  }
}

// MARK: - Budget Picker

struct BudgetPickerView: View {
  @Environment(\.dismiss) private var dismiss
  @Binding var dailyBudget: Double
  let currencySymbol: String

  @State private var inputText: String = ""
  @FocusState private var isTextFieldFocused: Bool

  private let presets: [Double] = [50, 75, 100, 150, 200, 250, 300, 500]

  var body: some View {
    NavigationStack {
      ZStack {
        Color("AppBackground")
          .ignoresSafeArea()

        VStack(spacing: 24) {
          // Current value display
          VStack(spacing: 8) {
            Text("Daily Budget")
              .font(.subheadline)
              .foregroundStyle(.secondary)

            HStack(spacing: 4) {
              Text(currencySymbol)
                .font(.system(size: 36, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)

              TextField("0", text: $inputText)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .focused($isTextFieldFocused)
                .frame(width: 150)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .glassEffect(.regular, in: .rect(cornerRadius: 20))
          }
          .padding(.top, 24)

          // Preset amounts
          VStack(alignment: .leading, spacing: 12) {
            Text("Quick Select")
              .font(.footnote)
              .fontWeight(.semibold)
              .foregroundStyle(.secondary)
              .padding(.horizontal, 4)

            LazyVGrid(columns: [
              GridItem(.flexible()),
              GridItem(.flexible()),
              GridItem(.flexible()),
              GridItem(.flexible())
            ], spacing: 12) {
              ForEach(presets, id: \.self) { preset in
                Button(action: {
                  inputText = String(format: "%.0f", preset)
                  dailyBudget = preset
                  UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }) {
                  Text("\(currencySymbol)\(Int(preset))")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(dailyBudget == preset ? .white : .primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                }
                .glassEffect(
                  dailyBudget == preset
                    ? .regular.tint(Color("AccentPrimary")).interactive()
                    : .regular.interactive(),
                  in: .capsule
                )
              }
            }
          }
          .padding(.horizontal, 16)

          Spacer()
        }
      }
      .navigationTitle("Set Budget")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button("Save") {
            if let value = Double(inputText), value > 0 {
              dailyBudget = value
            }
            dismiss()
          }
          .fontWeight(.semibold)
          .disabled(Double(inputText) == nil || Double(inputText)! <= 0)
        }
      }
      .onAppear {
        inputText = String(format: "%.0f", dailyBudget)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          isTextFieldFocused = true
        }
      }
      .onChange(of: inputText) { _, newValue in
        // Validate and update
        if let value = Double(newValue), value > 0 {
          dailyBudget = value
        }
      }
    }
  }
}

#Preview {
  SettingsView(
    settings: SettingsManager(),
    onDismiss: {},
    onResetBudget: {}
  )
}
