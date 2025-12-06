//
//  AnimatedGradient.swift
//  Stash
//
//  Animated shimmer gradient for accent elements
//

import SwiftUI

// MARK: - Shimmer Gradient View

struct ShimmerGradient: View {
    let colors: [Color]
    let cornerRadius: CGFloat

    @State private var phase: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(
        colors: [Color] = [ColorPalette.vibrantOrange, ColorPalette.hotPink],
        cornerRadius: CGFloat = 16
    ) {
        self.colors = colors
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base gradient
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Shimmer overlay
                if !reduceMotion {
                    shimmerOverlay(width: geometry.size.width)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(
                .linear(duration: 2.5)
                    .repeatForever(autoreverses: false)
            ) {
                phase = 1
            }
        }
    }

    private func shimmerOverlay(width: CGFloat) -> some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .white.opacity(0.15), location: 0.3),
                .init(color: .white.opacity(0.25), location: 0.5),
                .init(color: .white.opacity(0.15), location: 0.7),
                .init(color: .clear, location: 1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(width: width * 0.6)
        .offset(x: -width + (width * 2 * phase))
        .mask(
            RoundedRectangle(cornerRadius: cornerRadius)
        )
    }
}

// MARK: - Animated Gradient Button Style

struct AnimatedGradientButtonStyle: ButtonStyle {
    let colors: [Color]
    let cornerRadius: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(
        colors: [Color] = [ColorPalette.vibrantOrange, ColorPalette.hotPink],
        cornerRadius: CGFloat = 16
    ) {
        self.colors = colors
        self.cornerRadius = cornerRadius
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background {
                ShimmerGradient(colors: colors, cornerRadius: cornerRadius)
            }
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Gradient Text Modifier

struct GradientTextModifier: ViewModifier {
    let colors: [Color]

    init(colors: [Color] = [ColorPalette.vibrantOrange, ColorPalette.hotPink]) {
        self.colors = colors
    }

    func body(content: Content) -> some View {
        content
            .foregroundStyle(
                LinearGradient(
                    colors: colors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}

extension View {
    func gradientText(colors: [Color] = [ColorPalette.vibrantOrange, ColorPalette.hotPink]) -> some View {
        modifier(GradientTextModifier(colors: colors))
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.opacity(0.9)
            .ignoresSafeArea()

        VStack(spacing: 24) {
            // Shimmer gradient button
            Button("Confirm Expense") {}
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .buttonStyle(AnimatedGradientButtonStyle())

            // Static gradient
            Text("Stash")
                .font(.largeTitle)
                .fontWeight(.bold)
                .gradientText()

            // Shimmer box
            ShimmerGradient(cornerRadius: 20)
                .frame(height: 100)
        }
        .padding()
    }
}
