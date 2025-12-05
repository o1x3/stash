//
//  SettingsView.swift
//  Stash
//
//  Redesigned with Liquid Glass aesthetics and premium micro-interactions
//

import SwiftUI

// MARK: - Animation Constants

private enum SettingsAnimation {
    static let spring = Animation.spring(response: 0.45, dampingFraction: 0.75)
    static let quickSpring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let smooth = Animation.smooth(duration: 0.35)
}

// MARK: - Settings View

struct SettingsView: View {
    @Bindable var settings: SettingsManager
    let budgetManager: BudgetManager?
    let onDismiss: () -> Void
    let onResetBudget: () -> Void

    @State private var showResetConfirmation = false
    @State private var showCurrencyPicker = false
    @State private var showBudgetPicker = false
    @State private var scrollOffset: CGFloat = 0
    @State private var budgetPulseScale: CGFloat = 1.0

    // Haptic generators
    private let lightHaptic = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        ZStack {
            // Background with subtle gradient
            backgroundView

            VStack(spacing: 0) {
                // Header
                headerSection
                    .padding(.top, 8)
                    .padding(.bottom, 24)

                // Scrollable content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Hero Budget Card
                        heroBudgetCard
                            .padding(.bottom, 4)

                        // Currency Card
                        currencyCard

                        // Preferences Section
                        preferencesSection

                        // Reset Button
                        resetBudgetButton

                        // Footer
                        footerSection
                            .padding(.top, 24)
                            .padding(.bottom, 40)
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
        .confirmationSheet(
            isPresented: $showResetConfirmation,
            title: "Reset Budget?",
            message: "This will reset your remaining budget to \(settings.formatAmount(settings.dailyBudget)) for today. This action cannot be undone.",
            confirmTitle: "Reset Budget",
            style: .destructive
        ) {
            onResetBudget()
        }
        .onAppear {
            lightHaptic.prepare()
        }
    }

    // MARK: - Background

    private var backgroundView: some View {
        ZStack {
            Color("AppBackground")
                .ignoresSafeArea()

            // Subtle ambient gradient
            RadialGradient(
                colors: [
                    Color("AccentPrimary").opacity(0.05),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 100,
                endRadius: 400
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            // Back button with glass effect
            Button(action: {
                lightHaptic.impactOccurred()
                onDismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .frame(width: 44, height: 44)
            }
            .glassEffect(.regular.interactive(), in: .circle)

            Spacer()

            Text("Settings")
                .font(.title2)
                .fontWeight(.bold)

            Spacer()

            // Invisible spacer for balance
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Hero Budget Card

    private var heroBudgetCard: some View {
        Button(action: {
            lightHaptic.impactOccurred()
            withAnimation(SettingsAnimation.quickSpring) {
                budgetPulseScale = 1.05
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(SettingsAnimation.spring) {
                    budgetPulseScale = 1.0
                }
            }
            showBudgetPicker = true
        }) {
            VStack(spacing: 16) {
                // Section label
                Text("DAILY BUDGET")
                    .font(.caption)
                    .fontWeight(.heavy)
                    .foregroundStyle(.secondary)
                    .tracking(1.2)

                // Budget amount with progress ring
                ZStack {
                    // Progress ring
                    budgetProgressRing
                        .frame(width: 140, height: 140)

                    // Amount display
                    VStack(spacing: 4) {
                        Text(settings.formatAmount(settings.dailyBudget, showDecimals: false))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .contentTransition(.numericText())

                        Text("per day")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .scaleEffect(budgetPulseScale)

                // Budget status
                if let manager = budgetManager {
                    budgetStatusView(manager: manager)
                }

                // Tap hint
                HStack(spacing: 4) {
                    Image(systemName: "hand.tap")
                        .font(.caption2)
                    Text("Tap to edit")
                        .font(.caption2)
                }
                .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 28)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(HeroBudgetButtonStyle())
    }

    @ViewBuilder
    private func budgetStatusView(manager: BudgetManager) -> some View {
        let percentage = manager.budgetPercentage
        let color = manager.budgetColor

        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(budgetStatusText(percentage: percentage, remaining: manager.remainingBudget))
                .font(.subheadline)
                .fontWeight(.heavy)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background {
            Capsule()
                .fill(color.opacity(0.15))
        }
    }

    private func budgetStatusText(percentage: Double, remaining: Double) -> String {
        if remaining <= 0 {
            return "Over budget"
        }
        let percentText = String(format: "%.0f%%", percentage * 100)
        return "\(percentText) remaining today"
    }

    private var budgetProgressRing: some View {
        let percentage = budgetManager?.budgetPercentage ?? 1.0
        let color = budgetManager?.budgetColor ?? Color("BudgetGreen")

        return ZStack {
            // Background ring
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 8)

            // Progress arc
            Circle()
                .trim(from: 0, to: min(percentage, 1.0))
                .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(SettingsAnimation.smooth, value: percentage)

            // Glow effect
            Circle()
                .trim(from: 0, to: min(percentage, 1.0))
                .stroke(color.opacity(0.3), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .blur(radius: 4)
        }
    }

    // MARK: - Currency Card

    private var currencyCard: some View {
        Button(action: {
            lightHaptic.impactOccurred()
            showCurrencyPicker = true
        }) {
            HStack(spacing: 16) {
                // Large flag
                Text(settings.currency.flag)
                    .font(.system(size: 44))
                    .frame(width: 60, height: 60)
                    .background {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                    }

                // Currency info
                VStack(alignment: .leading, spacing: 4) {
                    Text(settings.currency.name)
                        .font(.body)
                        .fontWeight(.heavy)
                        .foregroundStyle(.primary)

                    Text("\(settings.currency.symbol) \(settings.currency.rawValue)")
                        .font(.subheadline)
                        .fontWeight(.heavy)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(GlassCardButtonStyle())
    }

    // MARK: - Preferences Section

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            Text("PREFERENCES")
                .font(.caption)
                .fontWeight(.heavy)
                .foregroundStyle(.secondary)
                .tracking(1.2)
                .padding(.horizontal, 4)

            // Haptic Feedback Toggle - separate card with native Toggle
            HStack(spacing: 12) {
                Image(systemName: "iphone.radiowaves.left.and.right")
                    .font(.body)
                    .foregroundStyle(Color("AccentPrimary"))
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Haptic Feedback")
                        .font(.body)
                        .fontWeight(.heavy)
                        .foregroundStyle(.primary)

                    Text("Feel taps and interactions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Toggle("", isOn: $settings.hapticsEnabled)
                    .labelsHidden()
                    .tint(Color("AccentPrimary"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .glassEffect(.regular, in: .rect(cornerRadius: 20))

            // Warning Threshold Slider - separate card
            GlassSliderRow(
                icon: "exclamationmark.triangle",
                title: "Low Budget Warning",
                value: $settings.budgetWarningThreshold,
                range: 0.1...0.5,
                step: 0.05,
                valueFormatter: { value in
                    "at \(Int(value * 100))%"
                }
            )
            .glassEffect(.regular, in: .rect(cornerRadius: 20))
        }
    }

    // MARK: - Reset Budget Button

    private var resetBudgetButton: some View {
        DestructiveGlassCard(action: {
            showResetConfirmation = true
        }) {
            HStack(spacing: 10) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.body)
                    .fontWeight(.heavy)

                Text("Reset Today's Budget")
                    .font(.body)
                    .fontWeight(.heavy)
            }
            .foregroundStyle(.red)
            .frame(height: 56)
        }
    }

    // MARK: - Footer

    private var footerSection: some View {
        VStack(spacing: 8) {
            // App name with subtle styling
            HStack(spacing: 4) {
                Text("Stash")
                    .font(.footnote)
                    .fontWeight(.semibold)
                Text("v1.0")
                    .font(.footnote)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.secondary)

            // Made with love
            HStack(spacing: 4) {
                Text("Made with")
                    .font(.caption2)
                Image(systemName: "heart.fill")
                    .font(.caption2)
                    .foregroundStyle(Color("AccentPrimary"))
            }
            .foregroundStyle(.tertiary)
        }
    }
}

// MARK: - Hero Budget Button Style

private struct HeroBudgetButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background {
                // Subtle gradient background
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color("AccentPrimary").opacity(0.08),
                                Color("AccentPrimary").opacity(0.03)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color("AccentPrimary").opacity(0.35),
                                Color("AccentPrimary").opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .glassEffect(
                .regular.tint(Color("AccentPrimary").opacity(0.08)).interactive(),
                in: .rect(cornerRadius: 24)
            )
            .shadow(color: Color("AccentPrimary").opacity(0.08), radius: 20, x: 0, y: 10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Glass Card Button Style

private struct GlassCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
            }
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 20))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Currency Picker View

struct CurrencyPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCurrency: String

    @State private var searchText = ""

    private var filteredCurrencies: [Currency] {
        if searchText.isEmpty {
            return Currency.allCases
        }
        return Currency.allCases.filter { currency in
            currency.name.localizedCaseInsensitiveContains(searchText) ||
            currency.rawValue.localizedCaseInsensitiveContains(searchText) ||
            currency.symbol.contains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground")
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(filteredCurrencies) { currency in
                            CurrencyRow(
                                currency: currency,
                                isSelected: currency.rawValue == selectedCurrency,
                                onSelect: {
                                    selectedCurrency = currency.rawValue
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    dismiss()
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Currency")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search currencies")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Currency Row

private struct CurrencyRow: View {
    let currency: Currency
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Large flag
                Text(currency.flag)
                    .font(.system(size: 36))
                    .frame(width: 50, height: 50)
                    .background {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                    }
                    .scaleEffect(isSelected ? 1.1 : 1.0)

                // Currency details
                VStack(alignment: .leading, spacing: 2) {
                    Text(currency.name)
                        .font(.body)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundStyle(.primary)

                    Text(currency.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Symbol
                Text(currency.symbol)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color("AccentPrimary"))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .glassEffect(
            isSelected
                ? .regular.tint(Color("AccentPrimary").opacity(0.2)).interactive()
                : .regular.interactive(),
            in: .rect(cornerRadius: 16)
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Budget Picker View

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

                VStack(spacing: 32) {
                    // Current value display
                    budgetInputSection
                        .padding(.top, 24)

                    // Preset amounts
                    presetSection

                    Spacer()
                }
            }
            .navigationTitle("Set Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveBudget()
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
                if let value = Double(newValue), value > 0 {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        dailyBudget = value
                    }
                }
            }
        }
    }

    private var budgetInputSection: some View {
        VStack(spacing: 12) {
            Text("Daily Budget")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                Text(currencySymbol)
                    .font(.system(size: 36, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)

                TextField("0", text: $inputText)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .focused($isTextFieldFocused)
                    .frame(minWidth: 100)
                    .fixedSize()
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 32)
            .glassEffect(.regular, in: .rect(cornerRadius: 24))
        }
    }

    private var presetSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("QUICK SELECT")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .tracking(1.2)
                .padding(.horizontal, 20)

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 12
            ) {
                ForEach(presets, id: \.self) { preset in
                    PresetButton(
                        amount: preset,
                        symbol: currencySymbol,
                        isSelected: dailyBudget == preset,
                        action: {
                            inputText = String(format: "%.0f", preset)
                            dailyBudget = preset
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func saveBudget() {
        if let value = Double(inputText), value > 0 {
            dailyBudget = value
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }
}

// MARK: - Preset Button

private struct PresetButton: View {
    let amount: Double
    let symbol: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(symbol)\(Int(amount))")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
        }
        .background {
            Capsule()
                .fill(isSelected ? Color("AccentPrimary") : Color.clear)
        }
        .glassEffect(
            isSelected
                ? .regular.tint(Color("AccentPrimary")).interactive()
                : .regular.interactive(),
            in: .capsule
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Preview

#Preview {
    SettingsView(
        settings: SettingsManager(),
        budgetManager: nil,
        onDismiss: {},
        onResetBudget: {}
    )
}
