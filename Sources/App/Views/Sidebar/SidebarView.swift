import SwiftUI
import Domain

/// Organism: Left sidebar with search, installed nav, catalogs nav, add catalog button
/// Matches prototype sidebar.css + app-shell.js renderSidebar()
struct SidebarView: View {
    @Bindable var library: SkillLibrary
    @Binding var showAddCatalog: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            // Search
            searchBox

            // Source sections
            ScrollView {
                VStack(spacing: 4) {
                    installedSection
                    catalogsSection
                }
                .padding(.vertical, 8)
            }

            // Footer: Add Catalog
            footer
        }
        .frame(width: DS.Layout.sidebarWidth)
        .background(DS.Colors.bgSecondary)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "book")
                .font(.system(size: 14))
                .foregroundStyle(DS.Colors.accent)

            Text("Skills Manager")
                .font(DS.Typography.sidebarHeader)
                .foregroundStyle(DS.Colors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .overlay(alignment: .bottom) {
            Divider().overlay(DS.Colors.border)
        }
    }

    // MARK: - Search

    private var searchBox: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12))
                .foregroundStyle(DS.Colors.textMuted)

            TextField("Search skills...", text: $library.searchQuery)
                .font(DS.Typography.body)
                .textFieldStyle(.plain)
                .foregroundStyle(DS.Colors.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(DS.Colors.bgInput)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.sm)
                .stroke(DS.Colors.border, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    // MARK: - Installed Section

    private var installedSection: some View {
        VStack(spacing: 0) {
            sectionHeader(title: "Installed", count: library.localSkillCount)

            navItem(
                icon: "folder",
                label: "All Installed",
                badge: "\(library.localSkillCount)",
                badgeIsInstalled: true,
                isActive: library.selectedSource == .allInstalled
            ) {
                library.selectedSource = .allInstalled
            }

            navItem(
                icon: "cube",
                label: "Claude Code",
                badge: "\(library.claudeSkillCount)",
                badgeIsInstalled: true,
                isActive: library.selectedSource == .provider(.claude)
            ) {
                library.selectedSource = .provider(.claude)
            }

            navItem(
                icon: "square.grid.3x3.square",
                label: "Codex",
                badge: "\(library.codexSkillCount)",
                badgeIsInstalled: true,
                isActive: library.selectedSource == .provider(.codex)
            ) {
                library.selectedSource = .provider(.codex)
            }
        }
    }

    // MARK: - Catalogs Section

    private var catalogsSection: some View {
        VStack(spacing: 0) {
            sectionHeader(title: "Catalogs", count: library.remoteCatalogs.count)

            ForEach(library.remoteCatalogs) { catalog in
                navItem(
                    icon: catalog.isLocalDirectory ? "folder" : "link",
                    label: catalog.name,
                    badge: "\(catalog.skillCount)",
                    badgeIsInstalled: false,
                    isActive: library.selectedSource == .remote(repoId: catalog.id)
                ) {
                    library.selectedSource = .remote(repoId: catalog.id)
                }
                .contextMenu {
                    if !catalog.isOfficial {
                        Button(role: .destructive) {
                            library.removeCatalog(catalog)
                        } label: {
                            Label("Remove Catalog", systemImage: "trash")
                        }
                    }
                }
            }

            if library.remoteCatalogs.isEmpty {
                Text("No catalogs added yet.\nAdd one to get started.")
                    .font(DS.Typography.description)
                    .foregroundStyle(DS.Colors.textMuted)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 0) {
            Divider().overlay(DS.Colors.border)

            Button {
                showAddCatalog = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 11))
                    Text("Add Catalog")
                        .font(DS.Typography.description)
                }
                .foregroundStyle(DS.Colors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(.clear)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.sm)
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                        .foregroundStyle(DS.Colors.border)
                )
            }
            .buttonStyle(.plain)
            .padding(16)
        }
    }

    // MARK: - Components

    private func sectionHeader(title: String, count: Int) -> some View {
        HStack {
            Text(title.uppercased())
                .font(DS.Typography.sectionTitle)
                .tracking(0.5)
                .foregroundStyle(DS.Colors.textMuted)

            Spacer()

            Text("\(count)")
                .font(DS.Typography.micro)
                .fontWeight(.medium)
                .padding(.horizontal, 6)
                .padding(.vertical, 1)
                .background(DS.Colors.bgInput)
                .foregroundStyle(DS.Colors.textMuted)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    private func navItem(
        icon: String,
        label: String,
        badge: String,
        badgeIsInstalled: Bool,
        isActive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .frame(width: 16)

                Text(label)
                    .font(DS.Typography.navItem)
                    .lineLimit(1)

                Spacer()

                Text(badge)
                    .font(DS.Typography.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 1)
                    .background(badgeIsInstalled
                        ? Color(hex: 0x22C55E).opacity(0.12)
                        : Color(hex: 0x3B82F6).opacity(0.12))
                    .foregroundStyle(badgeIsInstalled ? DS.Colors.green : DS.Colors.accent)
                    .clipShape(Capsule())
            }
            .padding(.vertical, 7)
            .padding(.leading, 24)
            .padding(.trailing, 16)
            .foregroundStyle(isActive ? DS.Colors.accent : DS.Colors.textSecondary)
            .background(isActive ? Color(hex: 0x3B82F6).opacity(0.12) : .clear)
            .overlay(alignment: .leading) {
                if isActive {
                    Rectangle()
                        .fill(DS.Colors.accent)
                        .frame(width: 2)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
