import SwiftUI
import Domain

/// Atom: A small tag badge matching prototype .tag styles
/// Used for version, category, provider, refs, scripts
struct TagChip: View {
    let text: String
    let style: Style

    enum Style {
        case version     // --bg-input, --text-muted, mono
        case category    // --purple-subtle, --purple
        case claude      // --accent-subtle, --accent
        case codex       // --green-subtle, --green
        case refs        // --cyan-subtle, --cyan
        case scripts     // --orange-subtle, --orange

        var backgroundColor: Color {
            switch self {
            case .version: return DS.Colors.bgInput
            case .category: return Color(hex: 0xA855F7).opacity(0.12)
            case .claude: return Color(hex: 0x3B82F6).opacity(0.12)
            case .codex: return Color(hex: 0x22C55E).opacity(0.12)
            case .refs: return Color(hex: 0x06B6D4).opacity(0.12)
            case .scripts: return Color(hex: 0xF59E0B).opacity(0.12)
            }
        }

        var foregroundColor: Color {
            switch self {
            case .version: return DS.Colors.textMuted
            case .category: return DS.Colors.purple
            case .claude: return DS.Colors.accent
            case .codex: return DS.Colors.green
            case .refs: return DS.Colors.cyan
            case .scripts: return DS.Colors.orange
            }
        }
    }

    var body: some View {
        Text(text)
            .font(style == .version ? DS.Typography.monoSmall : DS.Typography.tag)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(style.backgroundColor)
            .foregroundStyle(style.foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

// MARK: - Convenience

extension TagChip {
    /// Create a version tag like "v2.1.0"
    static func version(_ v: String) -> TagChip {
        TagChip(text: "v\(v)", style: .version)
    }

    /// Create a category tag
    static func category(_ name: String) -> TagChip {
        TagChip(text: name, style: .category)
    }

    /// Create a provider tag
    static func provider(_ provider: Provider) -> TagChip {
        TagChip(
            text: provider.displayName,
            style: provider == .claude ? .claude : .codex
        )
    }
}
