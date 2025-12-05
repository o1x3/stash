# Adaptive Budget Dial - Design Specification

## Overview
An innovative unified budget input control that combines preset selection, fine-tuning steppers, direct text entry, and drag-to-adjust gestures. Follows iOS 26 Liquid Glass design patterns.

---

## Visual States

### State 1: Collapsed (Default)
Horizontal scrolling preset carousel with glass pill buttons.

```
[$50]  [$75]  [$100]  [$150]  [$200]  [$250]  [Custom]
                ▲
            selected (tinted)
```

### State 2: Expanded (Fine-Tuning Mode)
Triggered by long press on preset OR tap on selected preset.

```
         [-$10]  ┌──────────────┐  [+$10]
                 │              │
                 │    $100      │
                 │              │
         [-$1]   └──────────────┘   [+$1]
                (tap to type directly)
                (drag horizontally to adjust)

[$50]  [$75]  [$100]  [$150]  [$200]  [$250]  [Custom]
                ▲
```

---

## Interaction Flow

### Quick Path (Most Users)
1. User sees preset carousel
2. Tap any preset → immediate selection with light haptic
3. Done

### Fine-Tune Path
1. Long press preset (0.5s) OR tap already-selected preset
2. Control expands upward with spring animation
3. Stepper buttons appear (morph from central pill using GlassEffectTransition)
4. User taps +$10/-$10 or +$1/-$1 for fine adjustment
5. Tap outside or select new preset to collapse

### Power User Path
1. In expanded state, tap the central amount display
2. Keyboard appears for direct text entry
3. Stepper buttons fade but remain visible
4. Submit or tap outside to confirm

### Delight Gesture (Drag-to-Adjust)
1. In expanded state, drag horizontally on central amount
2. Drag right = increase, drag left = decrease
3. Snaps to nearest $10 increment
4. Soft haptic at each snap point
5. Amount text shifts slightly in drag direction for feedback

---

## Implementation Structure

```swift
struct BudgetInputControl: View {
    @Binding var dailyBudget: Double

    // State
    @State private var isExpanded: Bool = false
    @State private var isEditing: Bool = false
    @State private var dragOffset: CGFloat = 0
    @FocusState private var isTextFieldFocused: Bool

    // Haptics
    private let lightHaptic = UIImpactFeedbackGenerator(style: .light)
    private let mediumHaptic = UIImpactFeedbackGenerator(style: .medium)
    private let selectionHaptic = UISelectionFeedbackGenerator()

    // Presets
    private let presets: [Double] = [50, 75, 100, 150, 200, 250, 300, 500]

    // Namespace for glass morphing
    @Namespace private var budgetNamespace

    var body: some View {
        VStack(spacing: 16) {
            // Expanded fine-tuning area (conditional)
            if isExpanded {
                fineTuningSection
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
            }

            // Preset carousel (always visible)
            presetCarousel
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)
    }
}
```

---

## Sub-Components

### PresetCarousel
```swift
private var presetCarousel: some View {
    ScrollView(.horizontal, showsIndicators: false) {
        GlassEffectContainer(spacing: 12) {
            HStack(spacing: 12) {
                ForEach(presets, id: \.self) { preset in
                    PresetPill(
                        amount: preset,
                        isSelected: dailyBudget == preset,
                        currencySymbol: currencySymbol
                    )
                    .onTapGesture { selectPreset(preset) }
                    .onLongPressGesture(minimumDuration: 0.5) {
                        expandWithPreset(preset)
                    }
                }

                // Custom pill for non-preset amounts
                CustomAmountPill(isSelected: !presets.contains(dailyBudget))
                    .onTapGesture { expandCustom() }
            }
            .padding(.horizontal, 20)
        }
    }
}
```

### FineTuningSection
```swift
private var fineTuningSection: some View {
    GlassEffectContainer(spacing: 20) {
        HStack(spacing: 0) {
            // Left steppers
            VStack(spacing: 8) {
                StepperButton(label: "-10", action: { adjust(by: -10) })
                StepperButton(label: "-1", action: { adjust(by: -1) })
            }

            // Central amount display (tappable, draggable)
            BudgetAmountDisplay(
                amount: $dailyBudget,
                isEditing: $isEditing,
                isFocused: $isTextFieldFocused,
                currencySymbol: currencySymbol
            )
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 20))
            .gesture(dragToAdjustGesture)

            // Right steppers
            VStack(spacing: 8) {
                StepperButton(label: "+10", action: { adjust(by: 10) })
                StepperButton(label: "+1", action: { adjust(by: 1) })
            }
        }
    }
}
```

### BudgetAmountDisplay
```swift
struct BudgetAmountDisplay: View {
    @Binding var amount: Double
    @Binding var isEditing: Bool
    var isFocused: FocusState<Bool>.Binding
    let currencySymbol: String

    @State private var textValue: String = ""

    var body: some View {
        ZStack {
            if isEditing {
                TextField("", text: $textValue)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .keyboardType(.decimalPad)
                    .focused(isFocused)
                    .onSubmit { commitEdit() }
            } else {
                HStack(spacing: 4) {
                    Text(currencySymbol)
                        .font(.system(size: 36, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.0f", amount))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())
                }
            }
        }
        .frame(width: 160, height: 100)
        .onTapGesture { beginEditing() }
    }
}
```

### StepperButton
```swift
struct StepperButton: View {
    let label: String
    let action: () -> Void

    private let haptic = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        Button(action: {
            haptic.impactOccurred()
            action()
        }) {
            Text(label)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .frame(width: 56, height: 40)
        }
        .glassEffect(.regular.interactive(), in: .capsule)
    }
}
```

---

## Drag-to-Adjust Gesture

```swift
private var dragToAdjustGesture: some Gesture {
    DragGesture()
        .onChanged { value in
            let translation = value.translation.width

            // Calculate adjustment (10 per 50pt of drag)
            let rawAdjustment = translation / 50 * 10
            let snappedAdjustment = round(rawAdjustment / 10) * 10

            // Apply with haptic at snap points
            let newValue = baseValue + snappedAdjustment
            if newValue != dailyBudget && newValue > 0 {
                dailyBudget = newValue
                selectionHaptic.selectionChanged()
            }
        }
        .onEnded { _ in
            baseValue = dailyBudget
        }
}
```

---

## Animation Specifications

| Animation Context | Parameters |
|-------------------|------------|
| Preset selection | `.spring(response: 0.3, dampingFraction: 0.7)` |
| Expansion/collapse | `.spring(response: 0.4, dampingFraction: 0.8)` |
| Stepper morphing | `.glassEffectTransition(.materialize)` |
| Amount text changes | `.contentTransition(.numericText())` |
| Drag feedback | `.spring(response: 0.2, dampingFraction: 0.6)` |

---

## Haptic Feedback Map

| Action | Haptic Type |
|--------|-------------|
| Tap preset | Light impact |
| Select preset | Light impact |
| Long press to expand | Medium impact |
| Stepper tap (+/-) | Light impact |
| Drag snap to $10 | Selection changed |
| Confirm text entry | Notification success |
| Invalid input | Notification error |

---

## Glass Effect Configuration

```swift
// Preset pills (unselected)
.glassEffect(.regular.interactive(), in: .capsule)

// Preset pills (selected)
.glassEffect(.regular.tint(Color("AccentPrimary")).interactive(), in: .capsule)

// Central amount display
.glassEffect(.regular.interactive(), in: .rect(cornerRadius: 20))

// Stepper buttons
.glassEffect(.regular.interactive(), in: .capsule)

// Container for morphing
GlassEffectContainer(spacing: 20) { ... }
```

---

## Input Validation

- Minimum budget: $1
- Maximum budget: $9999
- Max 4 digits before decimal
- Max 2 digits after decimal (currency dependent)
- Currencies like JPY/KRW: no decimals allowed

---

## Accessibility

- All presets are buttons with proper labels
- Stepper buttons announce their action ("Decrease by 10", "Increase by 1")
- Amount display announces current value
- Drag gesture has VoiceOver alternative (stepper buttons)
- Focus management for keyboard users

---

## File Location
When implemented, save as:
`/Stash/Views/Settings/BudgetInputControl.swift`

Replace the current `BudgetPickerView` in `SettingsView.swift` with this control.
