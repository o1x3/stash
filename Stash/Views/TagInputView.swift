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

  // Namespace for glass effect morphing
  @Namespace private var glassNamespace

  // Constants
  private let defaultTag = "Tag"
  private let expandedWidth: CGFloat = 240
  private let collapsedMaxWidth: CGFloat = 150
  private let height: CGFloat = 40
  private let maxDisplayLength = 20

  var body: some View {
    HStack {
      Spacer()

      GlassEffectContainer(spacing: 20) {
        if isExpanded {
          expandedPillContent
            .glassEffect(.regular.interactive(), in: .capsule)
            .glassEffectID("tagPill", in: glassNamespace)
        } else {
          collapsedPillContent
            .glassEffect(.regular.interactive(), in: .capsule)
            .glassEffectID("tagPill", in: glassNamespace)
        }
      }
    }
    .animation(.easeOut(duration: 0.3), value: isExpanded)
  }

  // MARK: - Pill Contents

  /// Expanded state: tag icon + text field + checkmark
  private var expandedPillContent: some View {
    HStack(spacing: 8) {
      // Tag icon
      Image(systemName: "tag")
        .font(.subheadline)
        .foregroundStyle(.primary.opacity(0.7))

      // TextField with placeholder
      TextField("Tag", text: $tagText)
        .font(.subheadline)
        .textFieldStyle(.plain)
        .focused(isFocused)
        .onSubmit { confirmTag() }
        .transition(.opacity.combined(with: .move(edge: .trailing)))

      // Checkmark button
      Button(action: confirmTag) {
        Image(systemName: "checkmark")
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(Color(hex: "E07A5F"))
      }
      .buttonStyle(.plain)
      .transition(.opacity)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .frame(width: expandedWidth)
    .frame(height: height)
    .contentShape(Capsule())
  }

  /// Collapsed state: tag icon + saved name
  private var collapsedPillContent: some View {
    HStack(spacing: 8) {
      // Tag icon
      Image(systemName: "tag")
        .font(.subheadline)
        .foregroundStyle(.primary.opacity(0.7))

      // Saved tag name
      Text(truncatedSavedName)
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundStyle(.primary)
        .lineLimit(1)
        .transition(.opacity.combined(with: .move(edge: .leading)))
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .frame(height: height)
    .contentShape(Capsule())
    .onTapGesture {
      expandTag()
    }
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

    // Trigger expansion
    withAnimation(.easeOut(duration: 0.3)) {
      isExpanded = true
    }

    // Focus after animation begins
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
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

    // 4. Haptic feedback (immediate)
    UIImpactFeedbackGenerator(style: .light).impactOccurred()

    // 5. Start collapse animation after brief delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
      withAnimation(.easeOut(duration: 0.3)) {
        isExpanded = false
      }
    }

    // NOTE: tagText is NOT cleared here - it will be reset in expandTag()
    // This prevents the flickering issue caused by mid-animation state changes
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
