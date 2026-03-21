import SwiftUI
import Domain

/// Sheet: Unlink from provider or full uninstall
/// Matches prototype page 05-uninstall.html uninstall modal
struct UninstallSheet: View {
    let skill: Skill
    @Bindable var library: SkillLibrary
    @Environment(\.dismiss) private var dismiss

    @State private var action: UninstallAction = .unlink
    @State private var phase: Phase = .choose
    @State private var unlinkProvider: Provider = .claude

    enum UninstallAction {
        case unlink
        case fullUninstall
    }

    enum Phase {
        case choose
        case done
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Remove \(skill.displayName)")
                    .font(DS.Typography.topbarTitle)
                    .foregroundStyle(DS.Colors.textPrimary)

                Text("Choose how to remove this skill")
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
                switch phase {
                case .choose:
                    chooseBody
                case .done:
                    doneBody
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)

            // Footer
            footerView
        }
        .frame(width: 420)
        .background(DS.Colors.bgSecondary)
    }

    // MARK: - Choose

    private var chooseBody: some View {
        VStack(spacing: 12) {
            // Unlink option
            ForEach(Array(skill.installedProviders).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { provider in
                optionCard(
                    title: "Unlink from \(provider.displayName)",
                    description: "Remove the symlink from \(provider == .claude ? "~/.claude/skills/" : "~/.codex/skills/"). The skill stays in central storage and can be re-linked later.",
                    isSelected: action == .unlink && unlinkProvider == provider,
                    isDanger: false
                ) {
                    action = .unlink
                    unlinkProvider = provider
                }
            }

            // Full uninstall option
            optionCard(
                title: "Full Uninstall",
                description: "Remove from central storage ~/.agent/skills/\(skill.id)/ and all provider links. Cannot be undone.",
                isSelected: action == .fullUninstall,
                isDanger: true
            ) {
                action = .fullUninstall
            }
        }
    }

    private func optionCard(
        title: String,
        description: String,
        isSelected: Bool,
        isDanger: Bool,
        onSelect: @escaping () -> Void
    ) -> some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(DS.Typography.cardName)
                    .foregroundStyle(isDanger ? DS.Colors.red : DS.Colors.textPrimary)

                Text(description)
                    .font(DS.Typography.description)
                    .foregroundStyle(DS.Colors.textMuted)
                    .lineSpacing(4)
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

    // MARK: - Done

    private var doneBody: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark")
                .font(.system(size: 18))
                .foregroundStyle(DS.Colors.green)
                .frame(width: 48, height: 48)
                .background(Color(hex: 0x22C55E).opacity(0.12))
                .clipShape(Circle())
                .padding(.bottom, 4)

            if action == .unlink {
                Text("Unlinked from \(unlinkProvider.displayName)")
                    .font(DS.Typography.cardName)
                    .foregroundStyle(DS.Colors.textPrimary)

                VStack(spacing: 2) {
                    Text("Symlink removed. Skill still available in")
                        .font(DS.Typography.description)
                        .foregroundStyle(DS.Colors.textMuted)

                    Text("~/.agent/skills/\(skill.id)/")
                        .font(DS.Typography.monoSmall)
                        .foregroundStyle(DS.Colors.textMuted)
                }
            } else {
                Text("Uninstalled")
                    .font(DS.Typography.cardName)
                    .foregroundStyle(DS.Colors.textPrimary)

                Text("Skill removed from all providers and central storage.")
                    .font(DS.Typography.description)
                    .foregroundStyle(DS.Colors.textMuted)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack {
            Spacer()

            switch phase {
            case .choose:
                Button { dismiss() } label: {
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

                Button { performAction() } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "trash")
                            .font(.system(size: 11))
                        Text("Remove")
                    }
                    .font(DS.Typography.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(DS.Colors.red)
                    .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                }
                .buttonStyle(.plain)

            case .done:
                Button { dismiss() } label: {
                    Text("Done")
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
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .overlay(alignment: .top) {
            Divider().overlay(DS.Colors.border)
        }
    }

    // MARK: - Actions

    private func performAction() {
        Task {
            switch action {
            case .unlink:
                await library.uninstall(from: unlinkProvider)
            case .fullUninstall:
                // Uninstall from all providers
                for provider in skill.installedProviders {
                    await library.uninstall(from: provider)
                }
            }
            phase = .done
        }
    }
}
