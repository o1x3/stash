//
//  StashApp.swift
//  Stash
//
//  Created by Karthik Vinayan on 4/12/25.
//

import SwiftUI

@main
struct StashApp: App {
  @State private var settings = SettingsManager()
  @State private var themeManager = ThemeManager()

  var body: some Scene {
    WindowGroup {
      ContentView(settings: settings, themeManager: themeManager)
        .preferredColorScheme(themeManager.effectiveColorScheme)
        .animation(.smooth(duration: 0.35), value: themeManager.appTheme)
        .animation(.smooth(duration: 0.35), value: themeManager.isAMOLEDEnabled)
    }
  }
}
