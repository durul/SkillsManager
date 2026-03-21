import SwiftUI

/// Atom: Monospace path display with a small label
/// Matches prototype .install-path style
struct StoragePath: View {
    let label: String
    let path: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label.uppercased())
                .font(DS.Typography.micro)
                .foregroundStyle(DS.Colors.textMuted)
                .tracking(0.3)

            Text(path)
                .font(DS.Typography.mono)
                .foregroundStyle(DS.Colors.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DS.Colors.bgInput)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.sm)
                .stroke(DS.Colors.border, lineWidth: 1)
        )
    }
}
