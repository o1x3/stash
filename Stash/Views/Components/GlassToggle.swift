//
//  GlassToggle.swift
//  Stash
//
//  Beautiful custom glassmorphic toggle with ambient color tint and smooth animations
//

import SwiftUI

// MARK: - Glass Toggle

struct GlassToggle: View {
    @Binding var isOn: Bool
    var activeColor: Color = Color("AccentPrimary")
    var hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light

    private let toggleWidth: CGFloat = 56
    private let toggleHeight: CGFloat = 32
    private let knobSize: CGFloat = 26
    private let knobPadding: CGFloat = 3

    private let hapticGenerator: UIImpactFeedbackGenerator

    init(isOn: Binding<Bool>, activeColor: Color = Color("AccentPrimary"), hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        self._isOn = isOn
        self.activeColor = activeColor
        self.hapticStyle = hapticStyle
        self.hapticGenerator = UIImpactFeedbackGenerator(style: hapticStyle)
    }

    var body: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            // Track
            Capsule()
                .fill(isOn ? activeColor.opacity(0.3) : Color.gray.opacity(0.2))
                .frame(width: toggleWidth, height: toggleHeight)
                .overlay {
                    Capsule()
                        .strokeBorder(
                            isOn ? activeColor.opacity(0.5) : Color.white.opacity(0.1),
                            lineWidth: 0.5
                        )
                }
                .glassEffect(
                    isOn
                        ? .regular.tint(activeColor.opacity(0.2))
                        : .regular,
                    in: .capsule
                )

            // Knob
            Circle()
                .fill(.white)
                .frame(width: knobSize, height: knobSize)
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                .overlay {
                    Circle()
                        .fill(
                            isOn
                                ? activeColor.opacity(0.3)
                                : Color.clear
                        )
                }
                .overlay {
                    Circle()
                        .strokeBorder(
                            isOn
                                ? activeColor.opacity(0.3)
                                : Color.gray.opacity(0.2),
                            lineWidth: 0.5
                        )
                }
                .padding(knobPadding)
        }
        .frame(width: toggleWidth, height: toggleHeight)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                isOn.toggle()
            }
            hapticGenerator.impactOccurred()
            hapticGenerator.prepare()
        }
        .onAppear {
            hapticGenerator.prepare()
        }
    }
}

// MARK: - Glass Toggle Row

struct GlassToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool
    var activeColor: Color = Color("AccentPrimary")

    init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        isOn: Binding<Bool>,
        activeColor: Color = Color("AccentPrimary")
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
        self.activeColor = activeColor
    }

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(activeColor)
                .frame(width: 24, height: 24)

            // Text content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.heavy)
                    .foregroundStyle(.primary)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Toggle
            GlassToggle(isOn: $isOn, activeColor: activeColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Glass Slider

struct GlassSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double = 0.01
    var activeColor: Color = Color("AccentPrimary")
    var label: String? = nil
    var valueFormatter: ((Double) -> String)? = nil

    private let trackHeight: CGFloat = 8
    private let knobSize: CGFloat = 24

    @State private var isDragging = false
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let label = label {
                HStack {
                    Text(label)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(valueFormatter?(value) ?? String(format: "%.0f%%", value * 100))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(activeColor)
                        .contentTransition(.numericText())
                }
            }

            GeometryReader { geometry in
                let width = geometry.size.width
                let fillWidth = width * CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))

                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: trackHeight)
                        .glassEffect(.regular, in: .capsule)

                    // Filled track
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [activeColor.opacity(0.7), activeColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, fillWidth), height: trackHeight)

                    // Knob
                    Circle()
                        .fill(.white)
                        .frame(width: knobSize, height: knobSize)
                        .shadow(color: activeColor.opacity(0.3), radius: isDragging ? 8 : 4, x: 0, y: 2)
                        .overlay {
                            Circle()
                                .fill(activeColor.opacity(isDragging ? 0.4 : 0.2))
                        }
                        .overlay {
                            Circle()
                                .strokeBorder(activeColor.opacity(0.3), lineWidth: 1)
                        }
                        .scaleEffect(isDragging ? 1.15 : 1.0)
                        .offset(x: max(0, min(fillWidth - knobSize / 2, width - knobSize)))
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            if !isDragging {
                                isDragging = true
                                hapticGenerator.impactOccurred()
                            }

                            let newValue = Double(gesture.location.x / width) * (range.upperBound - range.lowerBound) + range.lowerBound
                            let steppedValue = round(newValue / step) * step
                            let clampedValue = min(max(steppedValue, range.lowerBound), range.upperBound)

                            if abs(clampedValue - value) >= step {
                                value = clampedValue
                                UISelectionFeedbackGenerator().selectionChanged()
                            }
                        }
                        .onEnded { _ in
                            isDragging = false
                            hapticGenerator.prepare()
                        }
                )
            }
            .frame(height: knobSize)
        }
        .onAppear {
            hapticGenerator.prepare()
        }
    }
}

// MARK: - Glass Slider Row

struct GlassSliderRow: View {
    let icon: String
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double = 0.01
    var activeColor: Color = Color("AccentPrimary")
    var valueFormatter: ((Double) -> String)? = nil

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(activeColor)
                    .frame(width: 24, height: 24)

                // Title
                Text(title)
                    .font(.body)
                    .fontWeight(.heavy)
                    .foregroundStyle(.primary)

                Spacer()

                // Value display
                Text(valueFormatter?(value) ?? String(format: "%.0f%%", value * 100))
                    .font(.body)
                    .fontWeight(.heavy)
                    .foregroundStyle(activeColor)
                    .contentTransition(.numericText())
            }

            GlassSlider(
                value: $value,
                range: range,
                step: step,
                activeColor: activeColor
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var isOn = false
        @State private var sliderValue = 0.25

        var body: some View {
            ZStack {
                Color("AppBackground").ignoresSafeArea()

                VStack(spacing: 32) {
                    // Standalone toggles
                    HStack(spacing: 20) {
                        GlassToggle(isOn: .constant(false))
                        GlassToggle(isOn: .constant(true))
                        GlassToggle(isOn: $isOn)
                    }

                    // Toggle row in glass card
                    VStack(spacing: 0) {
                        GlassToggleRow(
                            icon: "iphone.radiowaves.left.and.right",
                            title: "Haptic Feedback",
                            subtitle: "Feel taps and interactions",
                            isOn: $isOn
                        )
                    }
                    .glassEffect(.regular, in: .rect(cornerRadius: 16))

                    // Standalone slider
                    GlassSlider(
                        value: $sliderValue,
                        range: 0...1,
                        step: 0.05,
                        label: "Warning Threshold"
                    )
                    .padding(.horizontal)

                    // Slider row in glass card
                    VStack(spacing: 0) {
                        GlassSliderRow(
                            icon: "exclamationmark.triangle",
                            title: "Warning Threshold",
                            value: $sliderValue,
                            range: 0...1,
                            step: 0.05
                        )
                    }
                    .glassEffect(.regular, in: .rect(cornerRadius: 16))
                }
                .padding()
            }
        }
    }

    return PreviewWrapper()
}
