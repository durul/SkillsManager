//
//  TagChip.swift
//  SkillsManager
//
//  Atom: Pill-shaped tag label with style variants
//

import SwiftUI

struct TagChip: View {
    let text: String
    var style: Style = .auto

    enum Style {
        /// Auto-detected from SKILL.md frontmatter
        case auto
        /// User-added custom tag
        case custom

        var backgroundColor: Color {
            switch self {
            case .auto: return Color.purple.opacity(0.12)
            case .custom: return Color.cyan.opacity(0.12)
            }
        }

        var foregroundColor: Color {
            switch self {
            case .auto: return .purple
            case .custom: return .cyan
            }
        }
    }

    var body: some View {
        Text(text)
            .font(DesignSystem.Typography.micro)
            .foregroundStyle(style.foregroundColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(style.backgroundColor)
            .clipShape(Capsule())
    }
}

#Preview("TagChip variants") {
    HStack(spacing: DesignSystem.Spacing.xs) {
        TagChip(text: "development")
        TagChip(text: "swift")
        TagChip(text: "favorites", style: .custom)
        TagChip(text: "my-team", style: .custom)
    }
    .padding()
}
