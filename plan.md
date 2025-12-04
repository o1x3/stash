# Stash App Redesign - iOS 26 Liquid Glass Implementation

## Overview

Redesign the Stash daily budget tracker iOS app to embrace iOS 26's Liquid Glass design language while matching the visual style of the provided Android reference screenshots. The app targets iOS 26.0+ and uses SwiftUI with the `@Observable` macro.

---

## Reference Screenshots Analysis

**Android Reference (target design - adapting for iOS):**
- Right-aligned amount display with cursor indicator
- Solid colored budget pill (yellow/gold when healthy) - iOS adaptation: Glass overlay with colored fill underneath
- Circular number pad buttons in a 3-column layout - iOS adaptation: Capsule shapes (iOS native)
- Tall confirm button spanning 3 rows on the right side
- Delete button as single circular button (row 1, column 4)
- "Tag" button that expands into a text input field for custom category names
- Clean, minimal UI with peach/cream background

**Current iOS App:**
- Centered amount display
- Glass effect budget bar with progress line
- Grid-based number pad with rounded rectangles
- Category pill selector (to be replaced with Tag input)
- Single-row confirm button

**Design Goal:** Match the Android layout and UX flow while embracing iOS 26 Liquid Glass aesthetic with fluid animations.

---

## Design Changes Required

### 1. Budget Bar (Header) - GLASS WITH ANIMATED FILL

**Keep** the Liquid Glass effect on the budget bar, but implement a **colored fill underneath** that acts as a progress indicator.

```swift
// Structure:
HStack {
    BudgetBarView  // Glass pill with colored fill underneath
    SettingsButton // Glass effect
}
```

**Budget Bar Specifications:**
- Shape: Capsule/pill shape with Liquid Glass
- Background: Colored fill that represents budget percentage, UNDER the glass
- The fill animates smoothly when budget changes (both increase and decrease)

**Implementation Approach - Layered Glass:**
```swift
struct BudgetBarView: View {
    let remainingBudget: Double
    let percentage: Double
    let budgetColor: Color
    let isOverBudget: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Layer 1: Track background (very subtle)
                Capsule()
                    .fill(Color.gray.opacity(0.1))
                
                // Layer 2: Colored progress fill (animates width)
                Capsule()
                    .fill(budgetColor.opacity(0.85))
                    .frame(width: isOverBudget ? geometry.size.width : geometry.size.width * percentage)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: percentage)
                    .animation(.easeInOut(duration: 0.4), value: budgetColor)
                
                // Layer 3: Glass effect overlay (samples the color underneath)
                Capsule()
                    .fill(.clear)
                    .glassEffect(.regular, in: .capsule)
                
                // Layer 4: Text content
                HStack {
                    Text("For today")
                        .foregroundStyle(.primary.opacity(0.7))
                    Spacer()
                    Text(formattedBudget)
                        .fontWeight(.semibold)
                        .foregroundStyle(isOverBudget ? Color(hex: "#F44336") : .primary)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: remainingBudget)
                }
                .font(.subheadline)
                .padding(.horizontal, 20)
            }
        }
        .frame(height: 52)
    }
    
    var formattedBudget: String {
        if isOverBudget {
            return "-\(String(format: "%.2f", abs(remainingBudget)))"
        }
        return String(format: "%.2f", remainingBudget)
    }
}
```

**Alternative Approach - Tinted Glass (simpler):**
```swift
// Use glass tint that changes based on budget status
.glassEffect(.regular.tint(budgetColor).interactive(), in: .capsule)
```
Note: This approach tints the entire glass rather than showing a fill progress. Use the layered approach above for the left-to-right fill effect.

**Budget Color Logic (unchanged):**
| Percentage | Color | Hex |
|------------|-------|-----|
| > 50% | Green | `#4CAF50` |
| 25-50% | Yellow/Gold | `#FFC107` |
| < 25% | Red | `#F44336` |
| < 0% (negative) | Pale Red | `#FFCDD2` |

**Animation Details:**
- Fill width change: `.spring(response: 0.6, dampingFraction: 0.8)` - bouncy, satisfying feel
- Color transition: `.easeInOut(duration: 0.4)` - smooth color morph
- Number change: `.numericText()` content transition - digits roll/slide

**Important:** When over budget (negative), show the amount in red text with "-" prefix and fill the entire bar with pale red.

**Remove dollar sign** from the budget display - just show the number (e.g., "17.86" not "$17.86").

---

### 2. Amount Display - RIGHT ALIGNED WITH ANIMATIONS

**Move** the amount display from center to **right-aligned** with a cursor indicator and smooth digit animations.

```swift
struct AmountDisplayView: View {
    let amount: String
    @State private var cursorOpacity: Double = 1.0
    
    var body: some View {
        HStack {
            Spacer()
            HStack(spacing: 0) {
                // Animated amount text
                Text(formattedAmount)
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .contentTransition(.numericText(countsDown: false))
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: amount)
                    .transaction { transaction in
                        transaction.animation = .spring(response: 0.35, dampingFraction: 0.7)
                    }
                
                // Animated cursor line (blinking)
                Rectangle()
                    .fill(Color(hex: "#E07A5F"))
                    .frame(width: 3, height: 56)
                    .opacity(cursorOpacity)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: cursorOpacity)
                    .onAppear {
                        cursorOpacity = 0.3
                    }
            }
            .padding(.trailing, 24)
        }
    }
    
    var formattedAmount: String {
        // Format logic without $ symbol
        if amount == "0" {
            return "0"
        }
        return amount
    }
}
```

**Animation Details for Digit Entry:**

1. **Adding a digit:**
   - New digit slides in from right/bottom with scale animation
   - `.contentTransition(.numericText())` handles individual digit animations
   - Spring animation gives bouncy, satisfying feedback
   - Existing digits shift smoothly to accommodate

2. **Removing a digit (backspace):**
   - Digit shrinks and fades out
   - Remaining digits slide back into position
   - Use `.numericText(countsDown: true)` when deleting for appropriate direction

3. **Cursor animation:**
   - Gentle pulse/blink between full opacity and 30%
   - Continuous loop with `repeatForever(autoreverses: true)`

**Enhanced Animation Approach (per-character):**
```swift
// For more control over individual digit animations
struct AnimatedDigit: View {
    let digit: Character
    let index: Int
    
    var body: some View {
        Text(String(digit))
            .font(.system(size: 72, weight: .bold, design: .rounded))
            .transition(
                .asymmetric(
                    insertion: .scale(scale: 0.5).combined(with: .opacity).combined(with: .offset(y: 20)),
                    removal: .scale(scale: 0.8).combined(with: .opacity)
                )
            )
            .id("\(digit)-\(index)")
    }
}

// Usage in AmountDisplayView
HStack(spacing: 0) {
    ForEach(Array(amount.enumerated()), id: \.offset) { index, digit in
        AnimatedDigit(digit: digit, index: index)
    }
}
.animation(.spring(response: 0.3, dampingFraction: 0.7), value: amount)
```

**Remove dollar sign** - just show the number (e.g., "8" not "$8").

---

### 3. Tag Input (Replaces Category Selector) - ANIMATED EXPAND/COLLAPSE

**Remove** the horizontal scrolling category pills. Replace with a **Tag button** that expands into a text input field with smooth morphing animations.

**Key Behavior:**
- Collapsed: Shows "Tag" or the previously entered tag name
- Tapping expands into full text input field
- After entering text and pressing checkmark/return, collapses back and displays the entered tag name
- All transitions are smooth glass morphing animations

**State Management:**
```swift
@State private var isTagExpanded = false
@State private var tagText = ""
@State private var savedTag = "Tag" // Displays saved tag or default "Tag"
@FocusState private var isTagFieldFocused: Bool
@Namespace private var tagAnimation
```

**Collapsed State (default):**
```swift
struct TagButtonCollapsed: View {
    let savedTag: String
    let namespace: Namespace.ID
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: "tag")
                    .matchedGeometryEffect(id: "tagIcon", in: namespace)
                Text(savedTag)
                    .matchedGeometryEffect(id: "tagText", in: namespace)
                    .lineLimit(1)
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .glassEffect(.regular.interactive(), in: .capsule)
        .glassEffectID("tagContainer", in: namespace)
    }
}
```

**Expanded State (when tapped):**
```swift
struct TagInputExpanded: View {
    @Binding var tagText: String
    let namespace: Namespace.ID
    let isFocused: FocusState<Bool>.Binding
    let onConfirm: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "tag")
                .foregroundStyle(.secondary)
                .matchedGeometryEffect(id: "tagIcon", in: namespace)
            
            TextField("Enter tag...", text: $tagText)
                .textFieldStyle(.plain)
                .font(.subheadline)
                .focused(isFocused)
                .matchedGeometryEffect(id: "tagText", in: namespace)
                .onSubmit {
                    onConfirm()
                }
            
            Button(action: onConfirm) {
                Image(systemName: "checkmark")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "#E07A5F"))
            }
            .buttonStyle(.glass)
            .transition(.scale.combined(with: .opacity))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassEffect(.regular.interactive(), in: .capsule)
        .glassEffectID("tagContainer", in: namespace)
    }
}
```

**Combined TagInputView with Animations:**
```swift
struct TagInputView: View {
    @Binding var isExpanded: Bool
    @Binding var tagText: String
    @Binding var savedTag: String
    var isFocused: FocusState<Bool>.Binding
    @Namespace private var tagNamespace
    
    var body: some View {
        HStack {
            Spacer()
            
            GlassEffectContainer {
                if isExpanded {
                    TagInputExpanded(
                        tagText: $tagText,
                        namespace: tagNamespace,
                        isFocused: isFocused,
                        onConfirm: confirmTag
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9, anchor: .trailing).combined(with: .opacity),
                        removal: .scale(scale: 0.95, anchor: .trailing).combined(with: .opacity)
                    ))
                } else {
                    TagButtonCollapsed(
                        savedTag: savedTag,
                        namespace: tagNamespace,
                        onTap: expandTag
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9, anchor: .trailing).combined(with: .opacity),
                        removal: .scale(scale: 0.95, anchor: .trailing).combined(with: .opacity)
                    ))
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
    }
    
    private func expandTag() {
        tagText = savedTag == "Tag" ? "" : savedTag // Pre-fill with existing tag
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isExpanded = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isFocused.wrappedValue = true
        }
    }
    
    private func confirmTag() {
        let newTag = tagText.trimmingCharacters(in: .whitespacesAndNewlines)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            savedTag = newTag.isEmpty ? "Tag" : newTag
            isExpanded = false
            isFocused.wrappedValue = false
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
```

**Animation Details:**

1. **Expand animation (tap Tag button):**
   - Glass pill morphs/stretches from small button to full-width input
   - Use `glassEffectID` for smooth glass morphing between states
   - Icon slides to left edge
   - Text field fades in and receives focus
   - Checkmark button scales in from right
   - Duration: `.spring(response: 0.4, dampingFraction: 0.8)`

2. **Collapse animation (confirm):**
   - Glass pill shrinks back to button size
   - Text field content becomes the new button label
   - Checkmark scales out
   - Keyboard dismisses
   - Haptic feedback on confirm

3. **Text replacement animation:**
   - When collapsed, the tag label uses `.contentTransition(.interpolate)` for smooth text morphing
   - Previous tag text morphs into new tag text

4. **Keyboard coordination:**
   - Use `@FocusState` to automatically show/hide keyboard
   - Pressing return/enter on keyboard also confirms (via `.onSubmit`)

**Position:** Bottom-right of the content area, aligned trailing, above the number pad.

---

### 4. Number Pad - NEW LAYOUT

**Completely redesign** the number pad layout to match Android reference:

```
┌─────────────────────────────────────────────────┐
│  [7]    [8]    [9]    [⌫]                       │  Row 1
│                                                 │
│  [4]    [5]    [6]    ┌──────┐                  │  Row 2
│                       │      │                  │
│  [1]    [2]    [3]    │  ✓   │                  │  Row 3
│                       │      │                  │
│  [0]         [.]      └──────┘                  │  Row 4
└─────────────────────────────────────────────────┘
```

**Grid Structure:**
- 4 columns, 4 rows
- Columns 1-3: Number buttons (0-9 and decimal)
- Column 4: Delete button (row 1 only) + Confirm button (spans rows 2-4)
- Row 4: "0" spans columns 1-2, "." is column 3

**Button Shapes (iOS Native - Capsules):**
- Number buttons: Capsule shape with Liquid Glass
- Delete button: Capsule shape with Liquid Glass (slightly tinted)
- Confirm button: Tall capsule/rounded rectangle with Liquid Glass + coral tint

**Implementation using custom layout:**

```swift
struct NumberPadView: View {
    let onDigit: (String) -> Void
    let onDelete: () -> Void
    let onConfirm: () -> Void
    
    var body: some View {
        GlassEffectContainer(spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                // Left side: 3x4 grid of number buttons
                VStack(spacing: 12) {
                    // Row 1: 7, 8, 9
                    HStack(spacing: 12) {
                        NumberButton(label: "7") { onDigit("7") }
                        NumberButton(label: "8") { onDigit("8") }
                        NumberButton(label: "9") { onDigit("9") }
                    }
                    // Row 2: 4, 5, 6
                    HStack(spacing: 12) {
                        NumberButton(label: "4") { onDigit("4") }
                        NumberButton(label: "5") { onDigit("5") }
                        NumberButton(label: "6") { onDigit("6") }
                    }
                    // Row 3: 1, 2, 3
                    HStack(spacing: 12) {
                        NumberButton(label: "1") { onDigit("1") }
                        NumberButton(label: "2") { onDigit("2") }
                        NumberButton(label: "3") { onDigit("3") }
                    }
                    // Row 4: 0 (wide), .
                    HStack(spacing: 12) {
                        NumberButton(label: "0", isWide: true) { onDigit("0") }
                        NumberButton(label: ".") { onDigit(".") }
                    }
                }
                
                // Right side: Delete + Confirm stack
                VStack(spacing: 12) {
                    // Delete button (single row height)
                    DeleteButton { onDelete() }
                    
                    // Confirm button (spans remaining 3 rows)
                    ConfirmButton { onConfirm() }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}
```

**NumberButton Styling:**
```swift
struct NumberButton: View {
    let label: String
    var isWide: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            Text(label)
                .font(.title)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 56)
        .frame(maxWidth: isWide ? .infinity : nil)
        .buttonStyle(.glass)
        // Capsule shape is default for glass buttons
    }
}
```

**DeleteButton Styling:**
```swift
struct DeleteButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            Image(systemName: "delete.left")
                .font(.title2)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 56)
        .buttonStyle(.glass)
        .tint(Color(hex: "#E07A5F").opacity(0.3)) // Subtle coral tint
    }
}
```

**ConfirmButton Styling:**
```swift
struct ConfirmButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        }) {
            Image(systemName: "checkmark")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxHeight: .infinity) // Takes remaining vertical space
        .buttonStyle(.glassProminent)
        .tint(Color(hex: "#E07A5F"))
    }
}
```

**Button Dimensions:**
- Number buttons: Equal width, 56pt height
- "0" button: Double width (spans 2 columns)
- Delete button: Same width as number buttons, 56pt height
- Confirm button: Same width as delete, height spans 3 button heights + 2 spacing gaps

---

### 5. Settings Button - KEEP GLASS

```swift
Button {
    // Settings action
} label: {
    Image(systemName: "gearshape.fill")
        .font(.title2)
        .frame(width: 48, height: 48)
}
.buttonStyle(.glass)
```

---

### 6. Overall Layout Structure

```swift
struct ContentView: View {
    @State private var budgetManager = BudgetManager()
    @State private var isTagExpanded = false
    @State private var tagText = ""
    @FocusState private var isTagFieldFocused: Bool
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#FFE5D9")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header: Budget Bar + Settings
                HStack(spacing: 12) {
                    BudgetBarView(
                        remainingBudget: budgetManager.remainingBudget,
                        percentage: budgetManager.budgetPercentage,
                        budgetColor: budgetManager.budgetColor,
                        isOverBudget: budgetManager.isOverBudget
                    )
                    
                    Button { /* settings */ } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .frame(width: 48, height: 48)
                    }
                    .buttonStyle(.glass)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                Spacer()
                
                // Amount Display (right-aligned)
                AmountDisplayView(amount: budgetManager.currentInput)
                
                Spacer()
                
                // Tag Button/Input
                TagInputView(
                    isExpanded: $isTagExpanded,
                    tagText: $tagText,
                    isFocused: $isTagFieldFocused
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                
                // Number Pad
                NumberPadView(
                    onDigit: { budgetManager.appendDigit($0) },
                    onDelete: { budgetManager.deleteLastDigit() },
                    onConfirm: { budgetManager.confirmExpense() }
                )
                .padding(.bottom, 24)
            }
        }
    }
}
```

---

### 7. BudgetManager Updates

Add these properties and update methods in BudgetManager:

```swift
@Observable
class BudgetManager {
    // Existing properties...
    
    // NEW: Tag support
    var currentTag: String = "Tag" // Default label, updates when user enters custom tag
    
    // UPDATED: Format without dollar sign
    var formattedRemainingBudget: String {
        if isOverBudget {
            return "-" + String(format: "%.2f", abs(remainingBudget))
        }
        return String(format: "%.2f", remainingBudget)
    }
    
    // UPDATED: confirmExpense with animation support
    // Note: Animations are applied in the View layer, but the state changes here trigger them
    func confirmExpense() {
        guard currentAmount > 0 else { return }
        
        // These changes will be animated by the View's animation modifiers
        remainingBudget -= currentAmount
        currentInput = "0"
        
        // Haptic feedback
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    // NEW: Update tag
    func updateTag(_ newTag: String) {
        let trimmed = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        currentTag = trimmed.isEmpty ? "Tag" : trimmed
    }
}
```

**State that triggers animations:**
- `currentInput` changes → Amount display animates
- `remainingBudget` changes → Budget bar fill + color animates
- `currentTag` changes → Tag label text morphs

---

### 8. Color Palette

| Element | Color | Hex | Usage |
|---------|-------|-----|-------|
| Background | Warm Peach | `#FFE5D9` | Main app background |
| Accent | Coral | `#E07A5F` | Confirm button tint, cursor |
| Budget Green | Green | `#4CAF50` | Healthy budget (>50%) |
| Budget Yellow | Gold | `#FFC107` | Warning budget (25-50%) |
| Budget Red | Red | `#F44336` | Critical budget (<25%) |
| Budget Pale Red | Pale Red | `#FFCDD2` | Overspent budget |

---

### 9. Liquid Glass Usage Summary

| Component | Glass Effect | Notes |
|-----------|--------------|-------|
| Budget Bar | ✅ YES | Layered: colored fill underneath + `.glassEffect(.regular)` on top |
| Settings Button | ✅ YES | `.buttonStyle(.glass)` |
| Tag Button (collapsed) | ✅ YES | `.glassEffect(.regular.interactive(), in: .capsule)` + `glassEffectID` |
| Tag Input (expanded) | ✅ YES | `.glassEffect(.regular.interactive(), in: .capsule)` + `glassEffectID` |
| Number Buttons | ✅ YES | `.buttonStyle(.glass)` - capsule shape default |
| Delete Button | ✅ YES | `.buttonStyle(.glass)` with subtle coral tint |
| Confirm Button | ✅ YES | `.buttonStyle(.glassProminent)` with coral tint |

**Glass Morphing:** Use `GlassEffectContainer` and `glassEffectID` for the Tag button to enable smooth morphing animation between collapsed and expanded states.

---

### 10. Animation Specifications - COMPREHENSIVE

All interactions should feel fluid, responsive, and delightful. Use spring animations for user-initiated actions and easeInOut for automatic/system changes.

**Amount Display Animations:**
| Trigger | Animation | Details |
|---------|-----------|---------|
| Digit added | `.spring(response: 0.35, dampingFraction: 0.7)` | New digit scales up from 0.5, slides in from bottom-right |
| Digit removed | `.spring(response: 0.3, dampingFraction: 0.8)` | Digit scales down to 0.8, fades out, remaining digits shift |
| Numeric transition | `.contentTransition(.numericText())` | Built-in digit rolling effect |
| Cursor blink | `.easeInOut(duration: 0.6).repeatForever(autoreverses: true)` | Opacity pulses 1.0 → 0.3 |

**Budget Bar Animations:**
| Trigger | Animation | Details |
|---------|-----------|---------|
| Fill width change | `.spring(response: 0.6, dampingFraction: 0.8)` | Bouncy, satisfying fill expansion/contraction |
| Color transition | `.easeInOut(duration: 0.4)` | Smooth color morph (green → yellow → red) |
| Amount text change | `.spring(response: 0.4, dampingFraction: 0.8)` + `.numericText()` | Numbers roll/slide to new value |
| Over budget transition | `.easeInOut(duration: 0.5)` | Fill expands to 100%, color changes to pale red |

**Tag Input Animations:**
| Trigger | Animation | Details |
|---------|-----------|---------|
| Expand (tap) | `.spring(response: 0.4, dampingFraction: 0.8)` | Glass morphs from pill to input field |
| Collapse (confirm) | `.spring(response: 0.4, dampingFraction: 0.8)` | Glass shrinks back, text updates |
| Checkmark appear | `.scale.combined(with: .opacity)` | Scales in from 0.5 with fade |
| Text field focus | Automatic | Keyboard slides up |
| Label text change | `.contentTransition(.interpolate)` | Old text morphs into new text |
| Icon position | `matchedGeometryEffect` | Smooth position transition |

**Number Pad Button Animations:**
| Trigger | Animation | Details |
|---------|-----------|---------|
| Button press | Handled by `.buttonStyle(.glass)` | Scale to 0.95, bounce back, shimmer effect |
| Button release | Built-in spring | Returns to 1.0 scale with slight overshoot |
| Haptic feedback | `UIImpactFeedbackGenerator` | `.light` for digits, `.medium` for confirm |

**Confirm Expense Animation (when checkmark tapped with valid amount):**
```swift
func confirmExpense() {
    guard currentAmount > 0 else { return }
    
    // Animate the amount display reset
    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
        // Amount will animate back to "0"
        currentInput = "0"
    }
    
    // Animate the budget bar fill decrease
    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
        remainingBudget -= currentAmount
    }
    
    // Haptic feedback
    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    
    // Optional: Success haptic
    UINotificationFeedbackGenerator().notificationOccurred(.success)
}
```

**Global Animation Principles:**

1. **User-initiated actions** (taps, swipes): Use spring animations for responsiveness
   - `response: 0.3-0.4` for quick actions
   - `dampingFraction: 0.7-0.8` for slight bounce without being too springy

2. **System/automatic changes** (budget updates, color changes): Use easeInOut
   - `duration: 0.4-0.6` for smooth, noticeable transitions

3. **Content transitions**: Use built-in SwiftUI transitions
   - `.numericText()` for numbers
   - `.interpolate` for text
   - `.symbolEffect(.replace)` for SF Symbols

4. **Glass morphing**: Use `glassEffectID` within `GlassEffectContainer`
   - Enables smooth shape morphing between states
   - Maintains glass sampling consistency

5. **Stagger animations** for multiple elements:
   ```swift
   ForEach(Array(items.enumerated()), id: \.offset) { index, item in
       ItemView(item: item)
           .animation(.spring().delay(Double(index) * 0.05), value: trigger)
   }
   ```

**Animation Timing Quick Reference:**
| Feel | Response | Damping | Use For |
|------|----------|---------|---------|
| Snappy | 0.25-0.35 | 0.8-0.9 | Button presses, quick feedback |
| Bouncy | 0.35-0.45 | 0.6-0.75 | Expanding elements, celebrations |
| Smooth | 0.4-0.6 | 0.8-1.0 | Transitions, morphing |
| Gentle | 0.5-0.7 | 0.85-1.0 | Background changes, subtle updates |

---

### 11. File Changes Required

**Files to modify:**
1. `ContentView.swift` - Update layout structure, remove category selector, add tag state
2. `BudgetBarView.swift` - Implement layered glass with animated colored fill underneath
3. `AmountDisplayView.swift` - Right-align, add animated cursor, remove $ symbol, add digit animations
4. `NumberPadView.swift` - Complete rewrite with new layout (3 columns + action column)
5. `BudgetManager.swift` - Add currentTag property, update formatting, add animation-friendly methods

**Files to add:**
1. `TagInputView.swift` - New animated tag button/input component with glass morphing

**Files to remove/deprecate:**
1. `CategorySelectorView.swift` - No longer needed

---

### 12. Important Implementation Notes

1. **GlassEffectContainer**: Wrap related glass elements (like the number pad buttons) in a `GlassEffectContainer` for proper glass sampling and morphing. Also required for Tag button expand/collapse morphing.

2. **Button Border Shape**: iOS 26 glass buttons default to capsule. Don't fight this - embrace it for touch-friendly layouts.

3. **Tint Usage**: Only use `.tint()` for semantic meaning (primary action = confirm button). Don't tint decoratively.

4. **Interactive Glass**: Use `.interactive()` modifier on glass effects for custom views that should respond to touch with scale/bounce/shimmer.

5. **Content Shape**: For custom glass buttons, remember to set `.contentShape(Capsule())` to ensure the entire glass area is tappable, not just the label.

6. **Glass on Glass**: Avoid layering glass directly on glass - glass cannot sample other glass. Use `GlassEffectContainer` when multiple glass elements are nearby.

7. **Animation on State Change**: Apply `.animation()` modifiers to views, and let state changes (`@State`, `@Observable`) trigger the animations. Don't wrap every state change in `withAnimation` unless you need different animations for different properties.

8. **Numeric Text Transitions**: For any numeric display that changes, use `.contentTransition(.numericText())` for the built-in digit rolling effect. Combine with `.animation()` for timing control.

9. **Glass Effect ID for Morphing**: When you want two different views to morph between each other (like Tag collapsed → expanded), give them the same `glassEffectID` and wrap in `GlassEffectContainer`.

10. **Matched Geometry Effect**: For non-glass elements that should animate position/size between states (like the tag icon), use `matchedGeometryEffect(id:in:)` with a `@Namespace`.

11. **Avoid Animation Conflicts**: Don't apply multiple `.animation()` modifiers that might conflict. Use `.transaction` or `withAnimation` with specific properties when needed.

12. **Performance**: Spring animations are more expensive than linear/easeInOut. For lists or many simultaneous animations, consider simpler curves or reduced spring complexity.

---

## Summary of Changes

1. ✅ Budget bar: Glass pill with animated colored fill underneath (progress from left to right)
2. ✅ Amount display: Right-aligned with blinking cursor, animated digit entry/removal
3. ✅ Remove $ symbol from budget and amount displays
4. ✅ Replace category pills with animated Tag button/input with glass morphing
5. ✅ Tag shows entered text after confirmation (replaces "Tag" label)
6. ✅ Redesign number pad with new layout (3 columns + action column)
7. ✅ Confirm button spans 3 rows vertically
8. ✅ Delete button is single row
9. ✅ Use iOS native capsule shapes for buttons
10. ✅ Apply Liquid Glass to ALL interactive elements (including budget bar)
11. ✅ Comprehensive spring animations for all interactions
12. ✅ Numeric text transitions for all number changes
13. ✅ Glass morphing animations using `glassEffectID`

---

## Animation Philosophy

**Every interaction should feel alive and responsive:**

1. **Immediate feedback**: Button presses respond instantly with scale + haptic
2. **Satisfying completion**: Actions complete with spring bounce and success haptics  
3. **Smooth transitions**: State changes morph fluidly, never jump
4. **Consistent timing**: Similar actions have similar animation durations
5. **Layered motion**: Multiple elements can animate together but with slight staggers
6. **Physics-based**: Springs feel natural; avoid linear/robotic movement

**The app should feel like touching liquid glass** - responsive, fluid, with a subtle weight and momentum to every movement.

---

## Testing Checklist

### Functionality
- [ ] Budget bar fills correctly from left to right
- [ ] Budget bar color changes at correct thresholds (50%, 25%, 0%)
- [ ] Amount display updates with input
- [ ] Cursor is visible and blinking next to amount
- [ ] Tag button expands to input field on tap
- [ ] Tag input accepts text and collapses on confirm
- [ ] Tag label updates to show entered text after confirm
- [ ] All number pad buttons are tappable
- [ ] Haptic feedback works on all buttons
- [ ] Confirm button spans full height correctly
- [ ] "0" button spans two columns
- [ ] Glass effects render correctly on peach background
- [ ] Pressing return on keyboard confirms tag input

### Animations
- [ ] Digits animate in smoothly when added (scale + slide)
- [ ] Digits animate out smoothly when deleted (scale + fade)
- [ ] Budget fill animates with spring when expense confirmed
- [ ] Budget color transitions smoothly between states
- [ ] Budget amount number rolls/slides to new value
- [ ] Tag button morphs smoothly into input field
- [ ] Tag input morphs smoothly back to button
- [ ] Tag label text morphs when updated
- [ ] Cursor blinks continuously
- [ ] Number pad buttons scale on press
- [ ] Confirm button has satisfying press animation
- [ ] No animation jank or stuttering
- [ ] Animations complete without being cut off

### Glass Effects
- [ ] All glass elements sample background correctly
- [ ] Glass morphing works for tag expand/collapse
- [ ] Glass tints display correctly (confirm button coral)
- [ ] Interactive glass responds to touch (shimmer/bounce)
- [ ] GlassEffectContainer groups elements properly
