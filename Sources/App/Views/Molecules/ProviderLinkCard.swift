//
//  ProviderLinkCard.swift
//  SkillsManager
//
//  Molecule: Provider card showing link status with symlink path
//

import SwiftUI
import Domain

struct ProviderLinkCard: View {
    let provider: Provider
    let isLinked: Bool
    var path: String? = nil

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            providerIcon
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(provider.displayName)
                    .font(DesignSystem.Typography.caption)
                    .fontWeight(.semibold)
                if let path {
                    Text(path + (isLinked ? " ← symlink" : ""))
                        .font(DesignSystem.Typography.code)
                        .foregroundStyle(DesignSystem.Colors.tertiaryText)
                }
            }
            Spacer()
            LinkStatusBadge(isLinked: isLinked)
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            isLinked ? DesignSystem.Colors.success.opacity(0.05) : DesignSystem.Colors.badgeBackground
        )
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.small))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.small)
                .stroke(
                    isLinked ? DesignSystem.Colors.success.opacity(0.3) : DesignSystem.Colors.subtleBorder,
                    lineWidth: 1
                )
        )
    }

    private var providerIcon: some View {
        Text(provider == .claude ? "C" : "X")
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundStyle(provider == .claude ? DesignSystem.Colors.claudeBlue : DesignSystem.Colors.codexGreen)
            .frame(width: 32, height: 32)
            .background(
                (provider == .claude ? DesignSystem.Colors.claudeBlue : DesignSystem.Colors.codexGreen).opacity(0.12)
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.small))
    }
}

#Preview {
    VStack(spacing: 8) {
        ProviderLinkCard(provider: .claude, isLinked: true, path: "~/.claude/skills/")
        ProviderLinkCard(provider: .codex, isLinked: false, path: "~/.codex/skills/")
    }
    .padding()
    .frame(width: 360)
}
