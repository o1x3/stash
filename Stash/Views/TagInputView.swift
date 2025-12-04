//
//  TagInputView.swift
//  Stash
//

import SwiftUI

struct TagInputView: View {
    @Binding var isExpanded: Bool
    @Binding var savedTagName: String
    var isFocused: FocusState<Bool>.Binding

    // Local state for text editing
    @State private var tagText: String = ""

    // Constants
    private let defaultTag = "Tag"
    private let expandedWidth: CGFloat = 240
    private let collapsedMaxWidth: CGFloat = 150
    private let height: CGFloat = 40
    private let maxDisplayLength = 20

    var body: some View {
        HStack {
            Spacer()

            // SINGLE container structure - NO conditional view swapping
            HStack(spacing: 8) {
                // Tag icon - ALWAYS present
                Image(systemName: "tag")
                    .font(.subheadline)
                    .foregroundStyle(.primary.opacity(0.7))

                // Content area - SLIDE + FADE with 10px offset
                ZStack(alignment: .leading) {
                    // Layer 1: Collapsed label - slides LEFT and fades OUT on expand
                    Text(truncatedSavedName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .opacity(isExpanded ? 0 : 1.0)
                        .offset(x: isExpanded ? -10 : 0)

                    // Layer 2: Hint "Tag" - slides in from RIGHT when expanded + empty
                    Text(defaultTag)
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .foregroundStyle(.primary.opacity(0.4))
                        .opacity(showHint ? 1 : 0)
                        .offset(x: showHint ? 0 : 10)

                    // Layer 3: TextField - slides in from RIGHT on expand
                    TextField("", text: $tagText)
                        .font(.subheadline)
                        .textFieldStyle(.plain)
                        .focused(isFocused)
                        .opacity(isExpanded ? 1 : 0)
                        .offset(x: isExpanded ? 0 : 10)
                        .allowsHitTesting(isExpanded)
                        .onSubmit { confirmTag() }
                }
                .frame(minWidth: 30)
                .clipped()

                // Checkmark - ALWAYS present, visibility via opacity
                Button(action: confirmTag) {
                    Image(systemName: "checkmark")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(hex: "E07A5F"))
                }
                .buttonStyle(.plain)
                .opacity(isExpanded ? 1 : 0)
                .allowsHitTesting(isExpanded)
                .frame(width: isExpanded ? nil : 0)
                .clipped()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(width: isExpanded ? expandedWidth : nil)
            .frame(minWidth: isExpanded ? expandedWidth : nil)
            .frame(maxWidth: isExpanded ? expandedWidth : collapsedMaxWidth)
            .frame(height: height)
            .glassEffect(.regular.interactive(), in: .capsule)
            .contentShape(Capsule())
            .onTapGesture {
                if !isExpanded {
                    expandTag()
                }
            }
        }
        // easeOut for momentum (starts fast, slows down)
        .animation(.easeOut(duration: 0.3), value: isExpanded)
    }

    // MARK: - Computed Properties

    private var showHint: Bool {
        isExpanded && tagText.isEmpty
    }

    private var truncatedSavedName: String {
        if savedTagName.count > maxDisplayLength {
            return String(savedTagName.prefix(maxDisplayLength - 2)) + ".."
        }
        return savedTagName
    }

    // MARK: - Actions

    private func expandTag() {
        // Set text state BEFORE animation
        if savedTagName == defaultTag {
            tagText = ""
        } else {
            tagText = savedTagName
        }

        // Single animation block
        withAnimation(.easeOut(duration: 0.3)) {
            isExpanded = true
        }

        // Focus after animation settles
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isFocused.wrappedValue = true
        }
    }

    private func confirmTag() {
        // 1. Dismiss keyboard FIRST
        isFocused.wrappedValue = false

        // 2. Determine new tag name
        let trimmed = tagText.trimmingCharacters(in: .whitespacesAndNewlines)
        let newTagName = trimmed.isEmpty ? defaultTag : trimmed

        // 3. Update savedTagName (DON'T clear tagText yet - keeps same text visible)
        savedTagName = newTagName

        // 4. Start collapse animation with easeOut
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.easeOut(duration: 0.3)) {
                isExpanded = false
            }
        }

        // 5. Clear tagText AFTER animation completes (0.05 + 0.3 = 0.35s, add buffer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            tagText = ""
        }

        // 6. Haptic feedback
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var isExpanded = false
        @State private var savedTagName = "Tag"
        @FocusState private var isFocused: Bool

        var body: some View {
            ZStack {
                Color(hex: "FFE5D9").ignoresSafeArea()
                VStack(spacing: 40) {
                    TagInputView(
                        isExpanded: $isExpanded,
                        savedTagName: $savedTagName,
                        isFocused: $isFocused
                    )
                    .padding(.horizontal, 16)

                    Text("Saved tag: \(savedTagName)")
                        .font(.caption)
                }
            }
        }
    }

    return PreviewWrapper()
}
