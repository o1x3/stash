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
  private let height: CGFloat = 40
  private let maxDisplayLength = 20

  var body: some View {
    HStack {
      Spacer()

      HStack(spacing: 8) {
        // Tag icon - stable, no animation
        Image(systemName: "tag")
          .font(.subheadline)
          .foregroundStyle(.primary.opacity(0.7))
          .animation(nil, value: isExpanded)

        // Collapsed label - slides left into icon, then shrinks
        Text(truncatedSavedName)
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundStyle(.primary)
          .lineLimit(1)
          .offset(x: isExpanded ? -30 : 0)
          .scaleEffect(isExpanded ? 0.3 : 1, anchor: .leading)
          .opacity(isExpanded ? 0 : 1)
          .frame(width: isExpanded ? 0 : nil, alignment: .leading)
          .animation(.smooth(duration: 0.45), value: isExpanded)

        // TextField - shrinks to 0 when collapsed
        TextField("", text: $tagText)
          .font(.subheadline)
          .textFieldStyle(.plain)
          .focused(isFocused)
          .opacity(isExpanded ? 1 : 0)
          .frame(width: isExpanded ? nil : 0, alignment: .leading)
          .frame(minWidth: isExpanded ? 30 : 0)
          .clipped()
          .allowsHitTesting(isExpanded)
          .onSubmit { confirmTag() }

        // Checkmark button - always present but hidden when collapsed
        Button(action: confirmTag) {
          Image(systemName: "checkmark")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color("AccentPrimary"))
        }
        .buttonStyle(.plain)
        .opacity(isExpanded ? 1 : 0)
        .frame(width: isExpanded ? nil : 0)
        .clipped()
        .allowsHitTesting(isExpanded)
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .frame(height: height)
      .fixedSize(horizontal: !isExpanded, vertical: false)
      .frame(width: isExpanded ? expandedWidth : nil)
      .glassEffect(.regular.interactive(), in: .capsule)
      .contentShape(Capsule())
      .onTapGesture {
        if !isExpanded {
          expandTag()
        }
      }
    }
    .animation(.smooth(duration: 0.35), value: isExpanded)
  }

  // MARK: - Computed Properties

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

    isExpanded = true

    // Focus after animation settles
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      isFocused.wrappedValue = true
    }
  }

  private func confirmTag() {
    // 1. Dismiss keyboard FIRST
    isFocused.wrappedValue = false

    // 2. Determine new tag name
    let trimmed = tagText.trimmingCharacters(in: .whitespacesAndNewlines)
    let newTagName = trimmed.isEmpty ? defaultTag : trimmed

    // 3. Update savedTagName
    savedTagName = newTagName

    // 4. Haptic feedback
    UIImpactFeedbackGenerator(style: .light).impactOccurred()

    // 5. Collapse
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
      isExpanded = false
    }
  }
}

#Preview {
  struct PreviewWrapper: View {
    @State private var isExpanded = false
    @State private var savedTagName = "Tag"
    @FocusState private var isFocused: Bool

    var body: some View {
      ZStack {
        Color("AppBackground").ignoresSafeArea()
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
