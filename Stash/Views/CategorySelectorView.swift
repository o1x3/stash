//
//  CategorySelectorView.swift
//  Stash
//

import SwiftUI

struct CategorySelectorView: View {
  @Binding var selectedCategory: ExpenseCategory
  let onSelect: () -> Void

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      GlassEffectContainer(spacing: 8) {
        HStack(spacing: 12) {
          ForEach(ExpenseCategory.allCases) { category in
            CategoryPill(
              title: category.rawValue,
              isSelected: selectedCategory == category
            )
            .onTapGesture {
              UIImpactFeedbackGenerator(style: .light).impactOccurred()
              withAnimation(.easeInOut(duration: 0.2)) {
                selectedCategory = category
              }
              onSelect()
            }
          }
        }
        .padding(.horizontal, 20)
      }
    }
  }
}

struct CategoryPill: View {
  let title: String
  let isSelected: Bool

  var body: some View {
    Text(title)
      .font(.subheadline)
      .fontWeight(isSelected ? .semibold : .medium)
      .foregroundStyle(isSelected ? .white : .primary)
      .padding(.horizontal, 20)
      .padding(.vertical, 12)
      .glassEffect(
        isSelected
          ? .regular.tint(Color("AccentPrimary")).interactive()
          : .regular.interactive(),
        in: .capsule
      )
  }
}

#Preview {
  ZStack {
    Color("AppBackground").ignoresSafeArea()
    CategorySelectorView(selectedCategory: .constant(.food), onSelect: {})
  }
}
