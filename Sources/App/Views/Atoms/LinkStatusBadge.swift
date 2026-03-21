import SwiftUI

/// Atom: "Linked" / "Not linked" status pill
/// Matches prototype .provider-status and .link-status styles
struct LinkStatusBadge: View {
    let isLinked: Bool

    var body: some View {
        Text(isLinked ? "Linked" : "Not linked")
            .font(DS.Typography.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(isLinked ? Color(hex: 0x22C55E).opacity(0.12) : DS.Colors.bgInput)
            .foregroundStyle(isLinked ? DS.Colors.green : DS.Colors.textMuted)
            .clipShape(Capsule())
    }
}
