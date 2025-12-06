//
//  AppTheme.swift
//  Stash
//
//  Theme enumeration for app appearance modes
//

import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var icon: String {
        switch self {
        case .system: return "sparkles"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    /// Returns the ColorScheme to apply, or nil for system default
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
