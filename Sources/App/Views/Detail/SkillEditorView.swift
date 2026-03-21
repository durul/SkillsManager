import SwiftUI
import Domain

/// Organism: Split pane markdown editor with live preview
/// Matches prototype page 06-edit-skill.html + editor.css
struct SkillEditorView: View {
    @Bindable var editor: SkillEditor
    let onSave: () async -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            topbar
            editorPanes
        }
        .background(DS.Colors.bgPrimary)
    }

    // MARK: - Topbar

    private var topbar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Edit: \(editor.original.name)")
                    .font(DS.Typography.topbarTitle)
                    .foregroundStyle(DS.Colors.textPrimary)

                Text("Local skill — ~/.claude/skills/\(editor.original.id)/")
                    .font(DS.Typography.description)
                    .foregroundStyle(DS.Colors.textMuted)
            }

            Spacer()

            Button(action: onCancel) {
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
                Task { await onSave() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11))
                    Text("Save")
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
            .disabled(!editor.isDirty)
            .opacity(editor.isDirty ? 1.0 : 0.5)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .frame(minHeight: DS.Layout.topbarHeight)
        .overlay(alignment: .bottom) {
            Divider().overlay(DS.Colors.border)
        }
    }

    // MARK: - Editor Panes

    private var editorPanes: some View {
        HStack(spacing: 0) {
            // Left: text editor
            VStack(spacing: 0) {
                paneHeader(title: "SKILL.md") {
                    if editor.isDirty {
                        Text("Modified")
                            .font(DS.Typography.micro)
                            .foregroundStyle(DS.Colors.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color(hex: 0xF59E0B).opacity(0.12))
                            .clipShape(Capsule())
                    }
                }

                TextEditor(text: $editor.draft)
                    .font(DS.Typography.editor)
                    .foregroundStyle(DS.Colors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .background(DS.Colors.bgPrimary)
                    .padding(16)
            }

            Divider().overlay(DS.Colors.border)

            // Right: preview
            VStack(spacing: 0) {
                paneHeader(title: "Preview") { EmptyView() }

                ScrollView {
                    MarkdownView(content: editor.draft)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                }
            }
        }
    }

    private func paneHeader<Trailing: View>(title: String, @ViewBuilder trailing: () -> Trailing) -> some View {
        HStack {
            Text(title)
                .font(DS.Typography.sectionTitle)
                .tracking(0.5)
                .foregroundStyle(DS.Colors.textMuted)

            Spacer()

            trailing()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            Divider().overlay(DS.Colors.border)
        }
    }
}
