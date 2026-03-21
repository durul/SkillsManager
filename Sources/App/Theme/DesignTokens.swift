import SwiftUI

// MARK: - Design Tokens
// Matches prototype/components/tokens.css exactly

enum DS {

    // MARK: - Colors (from tokens.css :root)

    enum Colors {
        // Backgrounds
        static let bgPrimary = Color(hex: 0x0F172A)
        static let bgSecondary = Color(hex: 0x1E293B)
        static let bgCard = Color(hex: 0x1E293B)
        static let bgCardHover = Color(hex: 0x263549)
        static let bgSurface = Color(hex: 0x0F172A)
        static let bgInput = Color(hex: 0x0F172A)

        // Borders
        static let border = Color(hex: 0x334155)
        static let borderLight = Color(hex: 0x475569)

        // Text
        static let textPrimary = Color(hex: 0xF1F5F9)
        static let textSecondary = Color(hex: 0x94A3B8)
        static let textMuted = Color(hex: 0x64748B)

        // Accent
        static let accent = Color(hex: 0x3B82F6)
        static let accentHover = Color(hex: 0x2563EB)
        static let accentSubtle = Color(hex: 0x3B82F6).opacity(0.12)

        // Status
        static let green = Color(hex: 0x22C55E)
        static let greenSubtle = Color(hex: 0x22C55E).opacity(0.12)
        static let orange = Color(hex: 0xF59E0B)
        static let orangeSubtle = Color(hex: 0xF59E0B).opacity(0.12)
        static let red = Color(hex: 0xEF4444)
        static let redSubtle = Color(hex: 0xEF4444).opacity(0.12)
        static let purple = Color(hex: 0xA855F7)
        static let purpleSubtle = Color(hex: 0xA855F7).opacity(0.12)
        static let cyan = Color(hex: 0x06B6D4)
        static let cyanSubtle = Color(hex: 0x06B6D4).opacity(0.12)
    }

    // MARK: - Typography

    enum Typography {
        // Prototype uses IBM Plex Sans + JetBrains Mono
        // SwiftUI equivalent: system fonts with matching sizes

        /// Topbar title: 16px semi-bold
        static let topbarTitle = Font.system(size: 16, weight: .semibold)

        /// Detail panel name: 18px bold
        static let detailName = Font.system(size: 18, weight: .bold)

        /// Skill card name: 14px semi-bold
        static let cardName = Font.system(size: 14, weight: .semibold)

        /// Sidebar header: 15px semi-bold
        static let sidebarHeader = Font.system(size: 15, weight: .semibold)

        /// Nav item: 13px regular
        static let navItem = Font.system(size: 13)

        /// Body text: 13px
        static let body = Font.system(size: 13)

        /// Description: 12px
        static let description = Font.system(size: 12)

        /// Section title: 11px semi-bold
        static let sectionTitle = Font.system(size: 11, weight: .semibold)

        /// Caption/muted: 11px
        static let caption = Font.system(size: 11)

        /// Tag text: 10px medium
        static let tag = Font.system(size: 10, weight: .medium)

        /// Micro labels: 10px
        static let micro = Font.system(size: 10)

        /// Monospace (code, paths, versions)
        static let mono = Font.system(size: 12, design: .monospaced)

        /// Monospace small
        static let monoSmall = Font.system(size: 11, design: .monospaced)

        /// Editor text: 13px mono
        static let editor = Font.system(size: 13, design: .monospaced)
    }

    // MARK: - Spacing

    enum Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 6
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
        static let xxl: CGFloat = 20
        static let xxxl: CGFloat = 24
    }

    // MARK: - Radius (from tokens.css)

    enum Radius {
        /// --radius-sm: 6px
        static let sm: CGFloat = 6
        /// --radius: 10px
        static let md: CGFloat = 10
        /// --radius-lg: 14px
        static let lg: CGFloat = 14
    }

    // MARK: - Layout (from layout.css)

    enum Layout {
        /// Sidebar width: 260px
        static let sidebarWidth: CGFloat = 260
        /// Detail panel width: 420px
        static let detailWidth: CGFloat = 420
        /// Skill card min width: 300px
        static let cardMinWidth: CGFloat = 300
        /// Topbar min height: 52px
        static let topbarHeight: CGFloat = 52
        /// Content area padding: 20px vertical, 24px horizontal
        static let contentPadding = EdgeInsets(top: 20, leading: 24, bottom: 20, trailing: 24)
        /// Sidebar padding horizontal: 16px
        static let sidebarPadding: CGFloat = 16
        /// Grid gap: 16px
        static let gridGap: CGFloat = 16
    }

    // MARK: - Animation (from tokens.css --transition: 200ms ease)

    enum Animation {
        static let quick = SwiftUI.Animation.easeOut(duration: 0.15)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.2)
    }

    // MARK: - Shadows (from tokens.css --shadow)

    enum Shadows {
        static let card = ShadowStyle(color: .black.opacity(0.3), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Shadow Style

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Color Hex Init

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle(isSelected: Bool = false, isHovering: Bool = false) -> some View {
        self
            .background(DS.Colors.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.md, style: .continuous)
                    .stroke(
                        isSelected ? DS.Colors.accent :
                            (isHovering ? DS.Colors.borderLight : DS.Colors.border),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isHovering ? DS.Shadows.card.color : .clear,
                radius: isHovering ? DS.Shadows.card.radius : 0,
                x: 0,
                y: isHovering ? DS.Shadows.card.y : 0
            )
    }
}
