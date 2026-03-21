//
//  StoragePath.swift
//  SkillsManager
//
//  Atom: Displays a file path with label in a subtle card
//

import SwiftUI

struct StoragePath: View {
    let label: String
    let path: String

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(label)
                .font(DesignSystem.Typography.micro)
                .foregroundStyle(DesignSystem.Colors.tertiaryText)
                .textCase(.uppercase)
            Text(path)
                .font(DesignSystem.Typography.code)
                .foregroundStyle(DesignSystem.Colors.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.badgeBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.small))
    }
}

#Preview {
    StoragePath(label: "Installed at", path: "~/.agent/skills/swift-concurrency/")
        .padding()
        .frame(width: 360)
}
