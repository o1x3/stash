# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Stash is a minimalist iOS expense tracking app for daily budget management. Users set a daily spending limit ($100 hardcoded) and log expenses using a calculator-style interface. The app resets automatically at midnight.

- **Platform:** iOS 26.0+
- **Framework:** SwiftUI
- **Architecture:** MVVM
- **State Management:** `@Observable` macro (iOS 17+)
- **Persistence:** UserDefaults
- **Bundle ID:** `com.o1x3.Stash`

## Build Commands

```bash
# Build for simulator
xcodebuild build -scheme Stash -destination 'platform=iOS Simulator,name=iPhone 16'

# Build and run on simulator (via MCP)
# Use mcp__XcodeBuildMCP__build_run_sim with scheme: "Stash"

# Clean build
xcodebuild clean -scheme Stash
```

No external dependencies (no CocoaPods, SPM packages, or Carthage).

## Architecture

### File Structure
```
Stash/
├── StashApp.swift          # @main entry point
├── ContentView.swift       # Root view + Color hex extension
├── Models/
│   └── ExpenseCategory.swift   # 5 expense categories enum
├── ViewModels/
│   └── BudgetManager.swift     # @Observable state manager
└── Views/
    ├── NumberPadView.swift     # Calculator keypad
    ├── AmountDisplayView.swift # Amount display
    ├── CategorySelectorView.swift # Category pills
    └── BudgetBarView.swift     # Budget progress bar
```

### State Management

`BudgetManager` is the central state container using `@Observable`:
- `remainingBudget`: Persisted via UserDefaults, resets at midnight
- `currentInput`: String input from number pad
- `selectedCategory`: Current expense category
- Computed: `budgetPercentage`, `budgetColor`, `isOverBudget`

UserDefaults keys: `remainingBudget`, `lastBudgetDate`, `hasSetBudget`

### Budget Color Logic
| Percentage | Color | Hex |
|------------|-------|-----|
| ≤ 0% | Pale Red | #FFCDD2 |
| 0-25% | Red | #F44336 |
| 25-50% | Yellow | #FFC107 |
| 50-100% | Green | #4CAF50 |

## Key Implementation Notes

- **iOS 26 Liquid Glass Effects:** UI uses `.glassEffect()` modifier and `GlassEffectContainer` components
- **Haptic Feedback:** Integrated throughout button interactions
- **Animations:** Spring animations with `.numericText()` content transitions
- **Input Validation:** Max 2 decimal places, leading zero handling

## Specification

See `spec.md` for complete specification including:
- Detailed component API contracts
- Exact color values and spacing measurements
- Animation timing specifications
- Complete data model definitions
