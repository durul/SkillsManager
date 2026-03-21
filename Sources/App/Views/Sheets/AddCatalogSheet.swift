import SwiftUI

/// Sheet: Add a skill catalog from GitHub or local directory
/// Matches prototype app-shell.js renderAddCatalogModal() + modal.css
struct AddCatalogSheet: View {
    @Bindable var library: SkillLibrary
    @Environment(\.dismiss) private var dismiss

    @State private var sourceType: SourceType = .github
    @State private var urlText = ""

    enum SourceType {
        case github
        case localDirectory
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Add Skill Catalog")
                    .font(DS.Typography.topbarTitle)
                    .foregroundStyle(DS.Colors.textPrimary)

                Text("Import skills from a GitHub repository or local directory")
                    .font(DS.Typography.description)
                    .foregroundStyle(DS.Colors.textMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 16)
            .overlay(alignment: .bottom) {
                Divider().overlay(DS.Colors.border)
            }

            // Body
            VStack(spacing: 12) {
                // GitHub option
                sourceOption(
                    icon: "link",
                    iconBg: Color(hex: 0xA855F7).opacity(0.12),
                    iconFg: DS.Colors.purple,
                    title: "GitHub Repository",
                    description: "Clone a GitHub repository containing skills. The repo will be cached locally for offline access.",
                    isSelected: sourceType == .github,
                    placeholder: "https://github.com/org/skills-repo"
                ) {
                    sourceType = .github
                }

                // Local directory option
                sourceOption(
                    icon: "folder",
                    iconBg: Color(hex: 0xF59E0B).opacity(0.12),
                    iconFg: DS.Colors.orange,
                    title: "Local Directory",
                    description: "Add skills from a local folder. Each subfolder with a SKILL.md file will be recognized as a skill.",
                    isSelected: sourceType == .localDirectory,
                    placeholder: "~/projects/my-skills"
                ) {
                    sourceType = .localDirectory
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)

            // Footer
            HStack {
                Spacer()

                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
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

                Button {
                    addCatalog()
                } label: {
                    Text("Add Catalog")
                        .font(DS.Typography.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(DS.Colors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                }
                .buttonStyle(.plain)
                .disabled(urlText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .overlay(alignment: .top) {
                Divider().overlay(DS.Colors.border)
            }
        }
        .frame(width: 460)
        .background(DS.Colors.bgSecondary)
        .preferredColorScheme(.dark)
    }

    // MARK: - Source Option

    private func sourceOption(
        icon: String,
        iconBg: Color,
        iconFg: Color,
        title: String,
        description: String,
        isSelected: Bool,
        placeholder: String,
        onSelect: @escaping () -> Void
    ) -> some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .frame(width: 40, height: 40)
                        .background(iconBg)
                        .foregroundStyle(iconFg)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    Text(title)
                        .font(DS.Typography.cardName)
                        .foregroundStyle(DS.Colors.textPrimary)
                }

                Text(description)
                    .font(DS.Typography.description)
                    .foregroundStyle(DS.Colors.textMuted)
                    .lineSpacing(4)

                if isSelected {
                    HStack(spacing: 8) {
                        TextField(placeholder, text: $urlText)
                            .font(DS.Typography.mono)
                            .textFieldStyle(.plain)
                            .foregroundStyle(DS.Colors.textPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(DS.Colors.bgPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                            .overlay(
                                RoundedRectangle(cornerRadius: DS.Radius.sm)
                                    .stroke(DS.Colors.border, lineWidth: 1)
                            )

                        if sourceType == .localDirectory {
                            Button("Browse") {
                                browseFolder()
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
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color(hex: 0x3B82F6).opacity(0.12) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .stroke(isSelected ? DS.Colors.accent : DS.Colors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func addCatalog() {
        let url = urlText.trimmingCharacters(in: .whitespaces)
        guard !url.isEmpty else { return }

        let catalogUrl: String
        if sourceType == .localDirectory {
            // Convert to file:// URL if needed
            if url.hasPrefix("file://") {
                catalogUrl = url
            } else {
                let expanded = (url as NSString).expandingTildeInPath
                catalogUrl = "file://\(expanded)"
            }
        } else {
            catalogUrl = url
        }

        library.addCatalog(url: catalogUrl)
        dismiss()
    }

    private func browseFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.message = "Select a folder containing skills"

        if panel.runModal() == .OK, let url = panel.url {
            urlText = url.path
        }
    }
}
