//
//  ColorPalette.swift
//  Stash
//
//  Raw color definitions for the vibrant color system
//

import SwiftUI

enum ColorPalette {
    // MARK: - Primary Accent (Vibrant Orange)

    static let vibrantOrange = Color(hex: "F97316")
    static let vibrantOrangeLight = Color(hex: "FB923C")

    // MARK: - Secondary Accents

    static let electricPurple = Color(hex: "8B5CF6")
    static let electricPurpleLight = Color(hex: "A855F7")

    static let hotPink = Color(hex: "EC4899")
    static let hotPinkLight = Color(hex: "F472B6")

    static let cyberBlue = Color(hex: "3B82F6")
    static let cyberBlueLight = Color(hex: "60A5FA")

    // MARK: - Budget Status Colors (Vibrant)

    static let limeGreen = Color(hex: "84CC16")
    static let limeGreenLight = Color(hex: "A3E635")

    static let budgetOrange = Color(hex: "F97316")
    static let budgetOrangeLight = Color(hex: "FB923C")

    static let budgetPink = Color(hex: "EC4899")
    static let budgetPinkLight = Color(hex: "F472B6")

    static let budgetRed = Color(hex: "EF4444")
    static let budgetRedLight = Color(hex: "F87171")

    // MARK: - Background Colors

    static let lightBackground = Color(hex: "FAFAFA")
    static let darkBackground = Color(hex: "121212")
    static let amoledBackground = Color(hex: "000000")

    // MARK: - Card Backgrounds

    static let lightCardBackground = Color.white.opacity(0.8)
    static let darkCardBackground = Color(hex: "1E1E1E").opacity(0.8)
    static let amoledCardBackground = Color(hex: "0A0A0A").opacity(0.9)
}
