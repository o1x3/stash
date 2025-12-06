//
//  ThemeManager.swift
//  Stash
//
//  Manages theme state and persistence using @Observable pattern
//

import SwiftUI

@Observable
final class ThemeManager {
    // MARK: - UserDefaults Keys

    private enum Keys {
        static let appTheme = "settings.appTheme"
        static let amoledEnabled = "settings.amoledEnabled"
    }

    // MARK: - Default Values

    private enum Defaults {
        static let appTheme: AppTheme = .system
        static let amoledEnabled = false
    }

    // MARK: - Theme Properties

    var appTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(appTheme.rawValue, forKey: Keys.appTheme)
        }
    }

    var isAMOLEDEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isAMOLEDEnabled, forKey: Keys.amoledEnabled)
        }
    }

    // MARK: - Computed Properties

    /// Returns the effective ColorScheme to apply to the app
    /// Returns nil for system default (follows iOS appearance)
    var effectiveColorScheme: ColorScheme? {
        appTheme.colorScheme
    }

    /// Returns true if AMOLED mode is active (dark theme + AMOLED enabled)
    var isAMOLEDActive: Bool {
        appTheme == .dark && isAMOLEDEnabled
    }

    /// Returns true if the app is currently in dark mode
    /// Note: For system theme, this needs to be checked against the environment
    var isDarkTheme: Bool {
        appTheme == .dark
    }

    // MARK: - Initialization

    init() {
        let defaults = UserDefaults.standard

        // Load theme
        if let savedTheme = defaults.string(forKey: Keys.appTheme),
           let theme = AppTheme(rawValue: savedTheme)
        {
            self.appTheme = theme
        } else {
            self.appTheme = Defaults.appTheme
        }

        // Load AMOLED setting
        if defaults.object(forKey: Keys.amoledEnabled) != nil {
            self.isAMOLEDEnabled = defaults.bool(forKey: Keys.amoledEnabled)
        } else {
            self.isAMOLEDEnabled = Defaults.amoledEnabled
        }
    }
}
