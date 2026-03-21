//
//  StatsBar.swift
//  SkillsManager
//
//  Molecule: Horizontal stats overview (total, installed, catalogs)
//

import SwiftUI

struct StatsBar: View {
    let totalSkills: Int
    let installedSkills: Int
    let catalogCount: Int

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xxl) {
            statItem(icon: "book.closed", value: totalSkills, label: "Total Skills", color: DesignSystem.Colors.accent)
            statItem(icon: "checkmark", value: installedSkills, label: "Installed", color: DesignSystem.Colors.success)
            statItem(icon: "folder", value: catalogCount, label: "Catalogs", color: .purple)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }

    private func statItem(icon: String, value: Int, label: String, color: Color) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.small))
            VStack(alignment: .leading, spacing: 0) {
                Text("\(value)")
                    .font(DesignSystem.Typography.headline)
                Text(label)
                    .font(DesignSystem.Typography.micro)
                    .foregroundStyle(DesignSystem.Colors.tertiaryText)
            }
        }
    }
}

#Preview {
    StatsBar(totalSkills: 38, installedSkills: 12, catalogCount: 3)
        .frame(width: 500)
}
