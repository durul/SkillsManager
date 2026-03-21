//
//  LinkStatusBadge.swift
//  SkillsManager
//
//  Atom: Badge showing link status for a provider
//

import SwiftUI

struct LinkStatusBadge: View {
    let isLinked: Bool

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: isLinked ? "link" : "link.badge.plus")
                .font(.system(size: 9, weight: .semibold))
            Text(isLinked ? "Linked" : "Not linked")
                .font(DesignSystem.Typography.micro)
        }
        .foregroundStyle(isLinked ? DesignSystem.Colors.success : DesignSystem.Colors.tertiaryText)
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, 3)
        .background(
            isLinked ? DesignSystem.Colors.success.opacity(0.12) : DesignSystem.Colors.badgeBackground
        )
        .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 8) {
        LinkStatusBadge(isLinked: true)
        LinkStatusBadge(isLinked: false)
    }
    .padding()
}
