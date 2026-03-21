import SwiftUI
import Domain

/// Sheet: Install a skill and link to providers
/// Matches prototype page 04-install.html install modal
struct InstallSheet: View {
    let skill: Skill
    @Bindable var library: SkillLibrary
    @Environment(\.dismiss) private var dismiss

    @State private var selectedProviders: Set<Provider> = Set(Provider.allCases)
    @State private var phase: Phase = .configure

    enum Phase {
        case configure
        case installing
        case success
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Install \(skill.displayName)")
                    .font(DS.Typography.topbarTitle)
                    .foregroundStyle(DS.Colors.textPrimary)

                Text("Install to central storage and link to providers")
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
            VStack(spacing: 0) {
                switch phase {
                case .configure:
                    configureBody
                case .installing:
                    installingBody
                case .success:
                    successBody
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)

            // Footer
            footerView
        }
        .frame(width: 420)
        .background(DS.Colors.bgSecondary)
        .preferredColorScheme(.dark)
    }

    // MARK: - Configure

    private var configureBody: some View {
        VStack(spacing: 16) {
            StoragePath(label: "Install to", path: "~/.agent/skills/\(skill.id)/")

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "link")
                        .font(.system(size: 10))
                    Text("Link to providers")
                        .font(DS.Typography.caption)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(DS.Colors.textMuted)

                VStack(spacing: 8) {
                    ForEach(Provider.allCases) { provider in
                        providerCheckbox(provider)
                    }
                }
            }
        }
    }

    private func providerCheckbox(_ provider: Provider) -> some View {
        let isChecked = selectedProviders.contains(provider)

        return Button {
            if isChecked {
                selectedProviders.remove(provider)
            } else {
                selectedProviders.insert(provider)
            }
        } label: {
            HStack(spacing: 12) {
                Text(provider == .claude ? "C" : "X")
                    .font(.system(size: 14, weight: .bold))
                    .frame(width: 36, height: 36)
                    .background(provider == .claude
                        ? Color(hex: 0x3B82F6).opacity(0.12)
                        : Color(hex: 0x22C55E).opacity(0.12))
                    .foregroundStyle(provider == .claude ? DS.Colors.accent : DS.Colors.green)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(provider.displayName)
                        .font(DS.Typography.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(DS.Colors.textPrimary)

                    Text(provider == .claude
                        ? "~/.claude/skills/\(skill.id) \u{2192}"
                        : "~/.codex/skills/\(skill.id) \u{2192}")
                        .font(DS.Typography.monoSmall)
                        .foregroundStyle(DS.Colors.textMuted)
                }

                Spacer()

                // Checkbox
                RoundedRectangle(cornerRadius: 4)
                    .fill(isChecked ? DS.Colors.accent : .clear)
                    .frame(width: 18, height: 18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(isChecked ? DS.Colors.accent : DS.Colors.border, lineWidth: 2)
                    )
                    .overlay {
                        if isChecked {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
            }
            .padding(12)
            .background(isChecked ? Color(hex: 0x3B82F6).opacity(0.06) : DS.Colors.bgInput)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.sm)
                    .stroke(DS.Colors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Installing

    private var installingBody: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
                .padding(.bottom, 4)

            Text("Installing to ~/.agent/skills/...")
                .font(DS.Typography.body)
                .foregroundStyle(DS.Colors.textSecondary)

            Text("Linking to \(selectedProviderNames)")
                .font(DS.Typography.caption)
                .foregroundStyle(DS.Colors.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    // MARK: - Success

    private var successBody: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark")
                .font(.system(size: 18))
                .foregroundStyle(DS.Colors.green)
                .frame(width: 48, height: 48)
                .background(Color(hex: 0x22C55E).opacity(0.12))
                .clipShape(Circle())
                .padding(.bottom, 4)

            Text("Installed & Linked")
                .font(DS.Typography.cardName)
                .foregroundStyle(DS.Colors.textPrimary)

            VStack(spacing: 2) {
                Text("Stored in ")
                    .font(DS.Typography.description)
                    .foregroundStyle(DS.Colors.textMuted)
                +
                Text("~/.agent/skills/\(skill.id)/")
                    .font(DS.Typography.monoSmall)
                    .foregroundStyle(DS.Colors.textMuted)

                Text("Linked to \(selectedProviderNames)")
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
            case .configure:
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

                Button { install() } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.down")
                            .font(.system(size: 11))
                        Text("Install & Link")
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
                .disabled(selectedProviders.isEmpty)

            case .installing:
                EmptyView()

            case .success:
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

    private func install() {
        phase = .installing
        Task {
            await library.install(to: selectedProviders)
            phase = .success
        }
    }

    private var selectedProviderNames: String {
        selectedProviders
            .sorted(by: { $0.rawValue < $1.rawValue })
            .map(\.displayName)
            .joined(separator: " and ")
    }
}
