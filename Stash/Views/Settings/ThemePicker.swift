//
//  ThemePicker.swift
//  Stash
//
//  Theme selection component with glass effect styling
//

import SwiftUI

struct ThemePicker: View {
    @Binding var selection: AppTheme
    let hapticsEnabled: Bool

    private let haptic = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTheme.allCases) { theme in
                themeButton(theme)
            }
        }
        .padding(4)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
        .onAppear {
            haptic.prepare()
        }
    }

    private func themeButton(_ theme: AppTheme) -> some View {
        Button {
            if hapticsEnabled {
                haptic.impactOccurred()
            }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selection = theme
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: theme.icon)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(theme.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(selection == theme ? .white : .primary)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background {
                if selection == theme {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    ColorPalette.vibrantOrange,
                                    ColorPalette.hotPink
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: ColorPalette.vibrantOrange.opacity(0.3), radius: 8, y: 4)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - AMOLED Toggle Row

struct AMOLEDToggleRow: View {
    @Binding var isEnabled: Bool
    let hapticsEnabled: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "moon.stars.fill")
                .font(.body)
                .foregroundStyle(
                    LinearGradient(
                        colors: [ColorPalette.electricPurple, ColorPalette.cyberBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text("AMOLED Black")
                    .font(.body)
                    .fontWeight(.heavy)
                    .foregroundStyle(.primary)

                Text("Pure black background for OLED screens")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .tint(ColorPalette.electricPurple)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.1)
            .ignoresSafeArea()

        VStack(spacing: 20) {
            ThemePicker(selection: .constant(.system), hapticsEnabled: true)
            ThemePicker(selection: .constant(.dark), hapticsEnabled: true)
            AMOLEDToggleRow(isEnabled: .constant(false), hapticsEnabled: true)
        }
        .padding()
    }
}
