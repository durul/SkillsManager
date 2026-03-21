import SwiftUI

/// Molecule: Stats row showing total/installed/catalogs
/// Matches prototype .stats-bar style
struct StatsBar: View {
    let totalSkills: Int
    let installedSkills: Int
    let catalogCount: Int

    var body: some View {
        HStack(spacing: 24) {
            statItem(
                icon: "book",
                value: totalSkills,
                label: "Total Skills",
                color: DS.Colors.accent,
                bgColor: Color(hex: 0x3B82F6).opacity(0.12)
            )

            statItem(
                icon: "checkmark",
                value: installedSkills,
                label: "Installed",
                color: DS.Colors.green,
                bgColor: Color(hex: 0x22C55E).opacity(0.12)
            )

            statItem(
                icon: "link",
                value: catalogCount,
                label: "Catalogs",
                color: DS.Colors.purple,
                bgColor: Color(hex: 0xA855F7).opacity(0.12)
            )
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }

    private func statItem(icon: String, value: Int, label: String, color: Color, bgColor: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .frame(width: 32, height: 32)
                .background(bgColor)
                .foregroundStyle(color)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 0) {
                Text("\(value)")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundStyle(DS.Colors.textPrimary)

                Text(label)
                    .font(DS.Typography.caption)
                    .foregroundStyle(DS.Colors.textMuted)
            }
        }
    }
}
