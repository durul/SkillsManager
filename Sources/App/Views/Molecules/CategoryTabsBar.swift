//
//  CategoryTabsBar.swift
//  SkillsManager
//
//  Molecule: Horizontal scrolling tabs for filtering skills by tag
//

import SwiftUI

struct CategoryTabsBar: View {
    let tags: [String]
    let skillCounts: [String: Int]
    @Binding var selectedTag: String?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                // "All" tab
                tabButton(label: "All", count: totalCount, isSelected: selectedTag == nil) {
                    selectedTag = nil
                }

                // Tag tabs
                ForEach(tags, id: \.self) { tag in
                    tabButton(label: tag, count: skillCounts[tag] ?? 0, isSelected: selectedTag == tag) {
                        selectedTag = tag
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
    }

    private var totalCount: Int {
        skillCounts.values.reduce(0) { max($0, $1) }
    }

    private func tabButton(label: String, count: Int, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Text(label)
                    .font(DesignSystem.Typography.caption)
                Text("\(count)")
                    .font(DesignSystem.Typography.micro)
                    .foregroundStyle(DesignSystem.Colors.tertiaryText)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(isSelected ? DesignSystem.Colors.accent.opacity(0.12) : Color.clear)
            .foregroundStyle(isSelected ? DesignSystem.Colors.accent : DesignSystem.Colors.secondaryText)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CategoryTabsBar(
        tags: ["development", "design", "testing", "ai", "devops"],
        skillCounts: ["development": 5, "design": 2, "testing": 2, "ai": 2, "devops": 1],
        selectedTag: .constant(nil)
    )
    .frame(width: 600)
}
