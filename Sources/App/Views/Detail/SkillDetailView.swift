import SwiftUI
import Domain

/// Organism: Right detail panel showing selected skill info
/// Matches prototype detail-panel.css + pages 03-browse, 04-install, 05-uninstall
struct SkillDetailView: View {
    let skill: Skill
    @Bindable var library: SkillLibrary
    let onClose: () -> Void
    let onInstall: () -> Void
    let onUninstall: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
            body_
            footer
        }
        .frame(width: DS.Layout.detailWidth)
        .background(DS.Colors.bgSecondary)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(skill.displayName)
                    .font(DS.Typography.detailName)
                    .foregroundStyle(DS.Colors.textPrimary)

                HStack(spacing: 4) {
                    Image(systemName: skill.source.isLocal ? "folder" : "link")
                        .font(.system(size: 10))
                    Text(skill.source.displayName)
                }
                .font(DS.Typography.description)
                .foregroundStyle(DS.Colors.textMuted)
            }

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 11))
                    .foregroundStyle(DS.Colors.textMuted)
                    .frame(width: 28, height: 28)
                    .background(DS.Colors.bgSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .overlay(alignment: .bottom) {
            Divider().overlay(DS.Colors.border)
        }
    }

    // MARK: - Body

    private var body_: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                descriptionSection
                tagsSection
                metadataSection

                if skill.isInstalled {
                    storageSection
                }

                providersSection
                contentPreviewSection
            }
            .padding(20)
        }
    }

    // MARK: - Sections

    private var descriptionSection: some View {
        detailSection("Description") {
            Text(skill.description)
                .font(DS.Typography.body)
                .foregroundStyle(DS.Colors.textSecondary)
                .lineSpacing(5)
        }
    }

    private var tagsSection: some View {
        detailSection("Tags") {
            EditableTagsView(tags: library.skillTags(for: skill))
        }
    }

    private var metadataSection: some View {
        detailSection("Metadata") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                metaItem(label: "Version", value: skill.version)
                metaItem(label: "References", value: skill.hasReferences ? "\(skill.referenceCount) files" : "None")
                metaItem(label: "Scripts", value: skill.hasScripts ? "\(skill.scriptCount) files" : "None")
                metaItem(label: "Source", value: skill.source.isLocal ? "Local" : "GitHub")
            }
        }
    }

    private var storageSection: some View {
        detailSection("Storage") {
            StoragePath(label: "Installed at", path: "~/.agent/skills/\(skill.id)/")
        }
    }

    private var providersSection: some View {
        detailSection(skill.isInstalled ? "Linked Providers" : "Providers") {
            VStack(spacing: 8) {
                ForEach(Provider.allCases) { provider in
                    ProviderLinkCard(
                        provider: provider,
                        isInstalled: skill.isInstalledFor(provider)
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var contentPreviewSection: some View {
        if !skill.content.isEmpty {
            detailSection("Content Preview") {
                ScrollView {
                    MarkdownView(content: strippedContent)
                        .textSelection(.enabled)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 300)
                .background(DS.Colors.bgInput)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.sm)
                        .stroke(DS.Colors.border, lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 0) {
            Divider().overlay(DS.Colors.border)

            HStack(spacing: 8) {
                if skill.isInstalled {
                    Button(action: onUninstall) {
                        HStack(spacing: 6) {
                            Image(systemName: "trash")
                                .font(.system(size: 11))
                            Text("Uninstall")
                        }
                        .font(DS.Typography.body)
                        .fontWeight(.medium)
                        .foregroundStyle(DS.Colors.red)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.clear)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                        .overlay(
                            RoundedRectangle(cornerRadius: DS.Radius.sm)
                                .stroke(DS.Colors.border, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)

                    if skill.isEditable {
                        Button {
                            library.startEditing()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 11))
                                Text("Edit")
                            }
                            .font(DS.Typography.body)
                            .fontWeight(.medium)
                            .foregroundStyle(DS.Colors.textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .overlay(
                                RoundedRectangle(cornerRadius: DS.Radius.sm)
                                    .stroke(DS.Colors.border, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer()

                    if skill.isFullyInstalled {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11))
                            Text("All Linked")
                        }
                        .font(DS.Typography.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(DS.Colors.accent.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                    } else {
                        Button(action: onInstall) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.down")
                                    .font(.system(size: 11))
                                Text("Link to \(skill.availableProviders.first?.displayName ?? "")")
                            }
                            .font(DS.Typography.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(DS.Colors.accent)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    Spacer()

                    Button(action: onInstall) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.down")
                                .font(.system(size: 11))
                            Text("Install & Link")
                        }
                        .font(DS.Typography.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(DS.Colors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }

    // MARK: - Helpers

    private func detailSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(DS.Typography.sectionTitle)
                .tracking(0.5)
                .foregroundStyle(DS.Colors.textMuted)

            content()
        }
    }

    private func metaItem(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(DS.Typography.micro)
                .foregroundStyle(DS.Colors.textMuted)
                .tracking(0.3)

            Text(value)
                .font(DS.Typography.body)
                .fontWeight(.medium)
                .foregroundStyle(DS.Colors.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DS.Colors.bgInput)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
    }

    /// Skill content with YAML frontmatter stripped
    private var strippedContent: String {
        var content = skill.content
        if content.hasPrefix("---") {
            if let endRange = content.range(of: "---", range: content.index(content.startIndex, offsetBy: 3)..<content.endIndex) {
                content = String(content[endRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return content
    }
}
