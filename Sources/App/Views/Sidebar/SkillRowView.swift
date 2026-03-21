import SwiftUI
import Domain

/// Organism: A skill card in the grid view
/// Matches prototype .skill-card from skill-card.css
struct SkillCardView: View {
    let skill: Skill
    let isSelected: Bool
    let onSelect: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 0) {
                // Header: name + installed dot
                HStack(alignment: .top) {
                    HStack(spacing: 8) {
                        if skill.isInstalled {
                            Circle()
                                .fill(DS.Colors.green)
                                .frame(width: 6, height: 6)
                        }

                        Text(skill.displayName)
                            .font(DS.Typography.cardName)
                            .foregroundStyle(DS.Colors.textPrimary)
                            .lineLimit(1)
                    }

                    Spacer()
                }
                .padding(.bottom, 10)

                // Description
                Text(skill.description)
                    .font(DS.Typography.description)
                    .foregroundStyle(DS.Colors.textSecondary)
                    .lineSpacing(4)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 14)

                // Meta: version + tags + providers
                FlowLayout(spacing: 6) {
                    TagChip.version(skill.version)

                    ForEach(skill.tags, id: \.self) { tag in
                        TagChip.category(tag)
                    }

                    ForEach(Array(skill.installedProviders).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { provider in
                        TagChip.provider(provider)
                    }

                    if skill.hasReferences {
                        TagChip(text: "\(skill.referenceCount) refs", style: .refs)
                    }

                    if skill.hasScripts {
                        TagChip(text: "\(skill.scriptCount) scripts", style: .scripts)
                    }
                }
            }
            .padding(18)
            .cardStyle(isSelected: isSelected, isHovering: isHovering)
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
    }
}

/// Organism: A skill row in list view
/// Matches prototype .skill-list-item from skill-card.css
struct SkillRowView: View {
    let skill: Skill
    let isSelected: Bool
    let onSelect: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 0) {
                // Name + dot
                HStack(spacing: 8) {
                    if skill.isInstalled {
                        Circle()
                            .fill(DS.Colors.green)
                            .frame(width: 6, height: 6)
                    }

                    Text(skill.displayName)
                        .font(DS.Typography.body)
                        .fontWeight(.medium)
                        .foregroundStyle(DS.Colors.textPrimary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Providers
                HStack(spacing: 4) {
                    ForEach(Array(skill.installedProviders).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { provider in
                        TagChip.provider(provider)
                    }
                }
                .frame(width: 180, alignment: .leading)

                // Version
                Text("v\(skill.version)")
                    .font(DS.Typography.mono)
                    .foregroundStyle(DS.Colors.textMuted)
                    .frame(width: 120, alignment: .leading)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, isHovering ? 12 : 0)
            .background(isHovering || isSelected ? DS.Colors.bgCardHover : .clear)
            .clipShape(RoundedRectangle(cornerRadius: isHovering ? DS.Radius.sm : 0))
            .overlay(alignment: .bottom) {
                if !isHovering {
                    Divider().overlay(DS.Colors.border)
                }
            }
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
    }
}
