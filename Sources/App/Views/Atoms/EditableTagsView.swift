import SwiftUI
import Domain

/// Editable tags view showing SKILL.md tags (purple) + user tags (cyan)
/// Matches prototype page 07-manage-tags.html
struct EditableTagsView: View {
    let skill: Skill
    @Bindable var library: SkillLibrary

    @State private var isAddingTag = false
    @State private var newTagText = ""

    private var userTags: Set<String> {
        library.userTags(for: skill.uniqueKey)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FlowLayout(spacing: 6) {
                // Purple: SKILL.md tags (read-only)
                ForEach(skill.tags, id: \.self) { tag in
                    autoTagChip(tag)
                }

                // Cyan: user-added tags (removable)
                ForEach(Array(userTags).sorted(), id: \.self) { tag in
                    userTagChip(tag)
                }

                // Add button or input
                if isAddingTag {
                    tagInput
                } else {
                    addButton
                }
            }

            tagLegend
            tagAnnotation
        }
    }

    // MARK: - Auto Tag (purple)

    private func autoTagChip(_ tag: String) -> some View {
        Text(tag)
            .font(DS.Typography.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(hex: 0xA855F7).opacity(0.12))
            .foregroundStyle(DS.Colors.purple)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    // MARK: - User Tag (cyan, removable)

    private func userTagChip(_ tag: String) -> some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(DS.Typography.caption)
                .fontWeight(.medium)

            Button {
                library.removeUserTag(tag, from: skill.uniqueKey)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 7, weight: .bold))
                    .frame(width: 14, height: 14)
                    .background(.white.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(hex: 0x06B6D4).opacity(0.12))
        .foregroundStyle(DS.Colors.cyan)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    // MARK: - Add Button

    private var addButton: some View {
        Button {
            isAddingTag = true
        } label: {
            HStack(spacing: 3) {
                Image(systemName: "plus")
                    .font(.system(size: 8))
                Text("add")
                    .font(DS.Typography.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(DS.Colors.textMuted)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [3]))
                    .foregroundStyle(DS.Colors.border)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tag Input

    private var tagInput: some View {
        TextField("tag name", text: $newTagText)
            .font(DS.Typography.caption)
            .textFieldStyle(.plain)
            .foregroundStyle(DS.Colors.textPrimary)
            .frame(width: 80)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(DS.Colors.bgInput)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(DS.Colors.accent, lineWidth: 1)
            )
            .onSubmit { commitTag() }
            .onExitCommand { cancelTag() }
    }

    // MARK: - Legend

    private var tagLegend: some View {
        HStack(spacing: 16) {
            legendItem(color: DS.Colors.purple, bgColor: Color(hex: 0xA855F7).opacity(0.12), label: "From SKILL.md")
            legendItem(color: DS.Colors.cyan, bgColor: Color(hex: 0x06B6D4).opacity(0.12), label: "Custom (you)")
        }
        .padding(.top, 4)
    }

    private func legendItem(color: Color, bgColor: Color, label: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(bgColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(color, lineWidth: 1)
                )
                .frame(width: 8, height: 8)

            Text(label)
                .font(DS.Typography.micro)
                .foregroundStyle(DS.Colors.textMuted)
        }
    }

    // MARK: - Annotation

    private var tagAnnotation: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle")
                .font(.system(size: 11))
                .foregroundStyle(DS.Colors.accent)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 2) {
                (Text("Purple tags").foregroundColor(DS.Colors.purple).bold()
                 + Text(" are auto-detected from the ").foregroundColor(DS.Colors.textSecondary)
                 + Text("tags").font(DS.Typography.monoSmall).foregroundColor(DS.Colors.accent)
                 + Text(" field in SKILL.md frontmatter.").foregroundColor(DS.Colors.textSecondary))

                (Text("Cyan tags").foregroundColor(DS.Colors.cyan).bold()
                 + Text(" are custom tags you added. Stored locally, won't modify the skill file.").foregroundColor(DS.Colors.textSecondary))

                Text("Both types appear as filter tabs above the grid.")
                    .foregroundStyle(DS.Colors.textSecondary)
            }
            .font(DS.Typography.caption)
            .lineSpacing(3)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(hex: 0x3B82F6).opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.sm)
                .stroke(Color(hex: 0x3B82F6).opacity(0.2), lineWidth: 1)
        )
        .padding(.top, 4)
    }

    // MARK: - Actions

    private func commitTag() {
        let tag = newTagText.trimmingCharacters(in: .whitespaces).lowercased()
        if !tag.isEmpty && !skill.tags.contains(tag) {
            library.addUserTag(tag, to: skill.uniqueKey)
        }
        newTagText = ""
        isAddingTag = false
    }

    private func cancelTag() {
        newTagText = ""
        isAddingTag = false
    }
}
