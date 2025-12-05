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

  var body: some Scene {
    WindowGroup {
      ContentView(settings: settings)
    }
  }
}
