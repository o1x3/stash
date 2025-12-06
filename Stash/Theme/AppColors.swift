//
//  AppColors.swift
//  Stash
//
//  Theme-aware color resolution for the app
//

import SwiftUI

struct AppColors {
    let themeManager: ThemeManager
    let colorScheme: ColorScheme

    // MARK: - Initialization

    init(themeManager: ThemeManager, colorScheme: ColorScheme) {
        self.themeManager = themeManager
        self.colorScheme = colorScheme
    }

    // MARK: - Effective Color Scheme

    /// Resolves the actual color scheme considering theme settings
    private var effectiveColorScheme: ColorScheme {
        if let forced = themeManager.effectiveColorScheme {
            return forced
        }
        return colorScheme
    }

    private var isDark: Bool {
        effectiveColorScheme == .dark
    }

    private var isAMOLED: Bool {
        themeManager.isAMOLEDActive
    }

    // MARK: - Primary Accent Colors

    var accentPrimary: Color {
        isDark ? ColorPalette.vibrantOrangeLight : ColorPalette.vibrantOrange
    }

    var accentSecondary: Color {
        isDark ? ColorPalette.hotPinkLight : ColorPalette.hotPink
    }

    var accentTertiary: Color {
        isDark ? ColorPalette.electricPurpleLight : ColorPalette.electricPurple
    }

    // MARK: - Background Colors

    var appBackground: Color {
        if isAMOLED {
            return ColorPalette.amoledBackground
        }
        return isDark ? ColorPalette.darkBackground : ColorPalette.lightBackground
    }

    var cardBackground: Color {
        if isAMOLED {
            return ColorPalette.amoledCardBackground
        }
        return isDark ? ColorPalette.darkCardBackground : ColorPalette.lightCardBackground
    }

    // MARK: - Budget Status Colors

    var budgetGreen: Color {
        isDark ? ColorPalette.limeGreenLight : ColorPalette.limeGreen
    }

    var budgetYellow: Color {
        isDark ? ColorPalette.budgetOrangeLight : ColorPalette.budgetOrange
    }

    var budgetRed: Color {
        isDark ? ColorPalette.budgetPinkLight : ColorPalette.budgetPink
    }

    var budgetOverRed: Color {
        isDark ? ColorPalette.budgetRedLight : ColorPalette.budgetRed
    }

    // MARK: - Gradients

    /// Orange to Pink gradient for headers and accent elements
    var headerGradient: LinearGradient {
        LinearGradient(
            colors: [accentPrimary, accentSecondary],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    /// Orange to Pink gradient (same as header, for accent elements)
    var accentGradient: LinearGradient {
        LinearGradient(
            colors: [accentPrimary, accentSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Purple to Blue gradient for interactive elements
    var interactiveGradient: LinearGradient {
        LinearGradient(
            colors: [
                isDark ? ColorPalette.electricPurpleLight : ColorPalette.electricPurple,
                isDark ? ColorPalette.cyberBlueLight : ColorPalette.cyberBlue,
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Glass Effect Tint

    var glassTint: Color {
        accentPrimary.opacity(0.15)
    }

    // MARK: - AMOLED Adjustments

    /// Border opacity for glass cards (higher in AMOLED mode for visibility)
    var cardBorderOpacity: Double {
        isAMOLED ? 0.15 : 0.1
    }
}

// MARK: - Environment Key

private struct AppColorsKey: EnvironmentKey {
    static let defaultValue: AppColors? = nil
}

extension EnvironmentValues {
    var appColors: AppColors? {
        get { self[AppColorsKey.self] }
        set { self[AppColorsKey.self] = newValue }
    }
}

// MARK: - View Extension

extension View {
    func appColors(_ colors: AppColors) -> some View {
        environment(\.appColors, colors)
    }
}
