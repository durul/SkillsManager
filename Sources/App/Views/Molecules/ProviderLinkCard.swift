import SwiftUI
import Domain

/// Molecule: Provider card with icon, name, path, and link status
/// Matches prototype .provider-card style
struct ProviderLinkCard: View {
    let provider: Provider
    let isInstalled: Bool
    var pathSuffix: String = ""

    var body: some View {
        HStack(spacing: 12) {
            // Provider icon
            Text(provider == .claude ? "C" : "X")
                .font(.system(size: 14, weight: .bold))
                .frame(width: 36, height: 36)
                .background(provider == .claude
                    ? Color(hex: 0x3B82F6).opacity(0.12)
                    : Color(hex: 0x22C55E).opacity(0.12))
                .foregroundStyle(provider == .claude ? DS.Colors.accent : DS.Colors.green)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(provider.displayName)
                    .font(DS.Typography.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(DS.Colors.textPrimary)

                Text(providerPath)
                    .font(DS.Typography.monoSmall)
                    .foregroundStyle(DS.Colors.textMuted)
            }

            Spacer()

            // Status
            LinkStatusBadge(isLinked: isInstalled)
        }
        .padding(12)
        .background(isInstalled ? Color(hex: 0x22C55E).opacity(0.12) : DS.Colors.bgInput)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.sm)
                .stroke(isInstalled ? DS.Colors.green : DS.Colors.border, lineWidth: 1)
        )
    }

    private var providerPath: String {
        let base = provider == .claude ? "~/.claude/skills/" : "~/.codex/skills/"
        if isInstalled {
            return base + " \u{2190} symlink"
        }
        return base + pathSuffix
    }
}
