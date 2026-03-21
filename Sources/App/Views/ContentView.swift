import SwiftUI
import Domain

/// Page: Root view — 3-column layout matching prototype layout.css
/// Sidebar (260px) | Main Content | Detail Panel (420px, conditional)
struct ContentView: View {
    @State private var library = SkillLibrary()
    @State private var showAddCatalog = false
    @State private var showInstall = false
    @State private var showUninstall = false

    var body: some View {
        Group {
            if library.isEditing, let editor = library.skillEditor {
                SkillEditorView(
                    editor: editor,
                    onSave: { await library.saveEditing() },
                    onCancel: { library.cancelEditing() }
                )
            } else {
                mainLayout
            }
        }
        .background(DS.Colors.bgPrimary)
        .task {
            await library.loadSkills()
        }
        .sheet(isPresented: $showAddCatalog) {
            AddCatalogSheet(library: library)
        }
        .sheet(isPresented: $showInstall) {
            if let skill = library.selectedSkill {
                InstallSheet(skill: skill, library: library)
            }
        }
        .sheet(isPresented: $showUninstall) {
            if let skill = library.selectedSkill {
                UninstallSheet(skill: skill, library: library)
            }
        }
    }

    // MARK: - Main Layout

    private var mainLayout: some View {
        HStack(spacing: 0) {
            SidebarView(library: library, showAddCatalog: $showAddCatalog)

            Divider().overlay(DS.Colors.border)

            mainContent

            if library.selectedSkill != nil {
                Divider().overlay(DS.Colors.border)
                detailPanel
            }
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: 0) {
            topbar
            categoryTabs

            if isLocalSource {
                StatsBar(
                    totalSkills: library.totalSkillCount,
                    installedSkills: library.localSkillCount,
                    catalogCount: library.remoteCatalogs.count
                )
            }

            contentArea
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Topbar

    private var topbar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(topbarTitle)
                    .font(DS.Typography.topbarTitle)
                    .foregroundStyle(DS.Colors.textPrimary)

                Text(topbarSubtitle)
                    .font(DS.Typography.description)
                    .foregroundStyle(DS.Colors.textMuted)
            }

            Spacer()

            HStack(spacing: 8) {
                // View toggle
                HStack(spacing: 0) {
                    viewToggleButton(mode: .grid, icon: "square.grid.2x2")
                    viewToggleButton(mode: .list, icon: "list.bullet")
                }
                .background(DS.Colors.bgSecondary)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.sm)
                        .stroke(DS.Colors.border, lineWidth: 1)
                )

                // Refresh
                Button {
                    Task { await library.refresh() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11))
                        .foregroundStyle(DS.Colors.textMuted)
                        .frame(width: 28, height: 28)
                        .overlay(
                            RoundedRectangle(cornerRadius: DS.Radius.sm)
                                .stroke(DS.Colors.border, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .frame(minHeight: DS.Layout.topbarHeight)
        .overlay(alignment: .bottom) {
            Divider().overlay(DS.Colors.border)
        }
    }

    private func viewToggleButton(mode: ViewMode, icon: String) -> some View {
        Button {
            library.viewMode = mode
        } label: {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(library.viewMode == mode ? DS.Colors.accent : DS.Colors.textMuted)
                .frame(width: 30, height: 26)
                .background(library.viewMode == mode ? Color(hex: 0x3B82F6).opacity(0.12) : .clear)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Category Tabs

    private var categoryTabs: some View {
        CategoryTabsBar(
            tagCounts: library.tagCounts,
            totalCount: library.selectedCatalog.skillCount,
            selectedTag: $library.selectedTag
        )
    }

    // MARK: - Content Area

    private var contentArea: some View {
        Group {
            if library.isLoading {
                loadingView
            } else if library.filteredSkills.isEmpty {
                emptyStateView
            } else {
                scrollableContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var scrollableContent: some View {
        ScrollView {
            switch library.viewMode {
            case .grid:
                gridView
            case .list:
                listView
            }
        }
        .padding(DS.Layout.contentPadding)
    }

    private var gridView: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: DS.Layout.cardMinWidth), spacing: DS.Layout.gridGap)],
            spacing: DS.Layout.gridGap
        ) {
            ForEach(library.filteredSkills, id: \.listId) { skill in
                SkillCardView(
                    skill: skill,
                    isSelected: library.selectedSkill?.listId == skill.listId,
                    onSelect: { library.select(skill) }
                )
            }
        }
    }

    private var listView: some View {
        LazyVStack(spacing: 0) {
            ForEach(library.filteredSkills, id: \.listId) { skill in
                SkillRowView(
                    skill: skill,
                    isSelected: library.selectedSkill?.listId == skill.listId,
                    onSelect: { library.select(skill) }
                )
            }
        }
    }

    // MARK: - Empty / Loading States

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading skills...")
                .font(DS.Typography.body)
                .foregroundStyle(DS.Colors.textSecondary)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 0) {
            Spacer()

            // Icon
            Image(systemName: "book")
                .font(.system(size: 32))
                .foregroundStyle(DS.Colors.accent)
                .frame(width: 80, height: 80)
                .background(Color(hex: 0x3B82F6).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.bottom, 24)

            Text("No Skills Yet")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(DS.Colors.textPrimary)
                .padding(.bottom, 8)

            Text("Skills extend your AI coding assistants with specialized knowledge.\nAdd a skill catalog to browse and install skills for Claude Code or Codex.")
                .font(DS.Typography.cardName)
                .foregroundStyle(DS.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .frame(maxWidth: 400)
                .padding(.bottom, 32)

            Button {
                showAddCatalog = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 11))
                    Text("Add Your First Catalog")
                }
                .font(DS.Typography.cardName)
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(DS.Colors.accent)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
            }
            .buttonStyle(.plain)
            .padding(.bottom, 40)

            // Getting started cards
            HStack(spacing: 16) {
                gettingStartedCard(
                    icon: "link",
                    iconBg: Color(hex: 0xA855F7).opacity(0.12),
                    iconFg: DS.Colors.purple,
                    title: "From GitHub",
                    description: "Clone a repository of skills. Great for team-shared or community catalogs."
                )

                gettingStartedCard(
                    icon: "folder",
                    iconBg: Color(hex: 0xF59E0B).opacity(0.12),
                    iconFg: DS.Colors.orange,
                    title: "From Local Folder",
                    description: "Point to a local directory. Perfect for skills you're developing or private collections."
                )
            }
            .frame(maxWidth: 600)

            Spacer()
        }
        .padding(40)
    }

    private func gettingStartedCard(icon: String, iconBg: Color, iconFg: Color, title: String, description: String) -> some View {
        Button {
            showAddCatalog = true
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .frame(width: 40, height: 40)
                    .background(iconBg)
                    .foregroundStyle(iconFg)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Text(title)
                    .font(DS.Typography.cardName)
                    .foregroundStyle(DS.Colors.textPrimary)

                Text(description)
                    .font(DS.Typography.description)
                    .foregroundStyle(DS.Colors.textMuted)
                    .lineSpacing(4)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DS.Colors.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.md)
                    .stroke(DS.Colors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Detail Panel

    private var detailPanel: some View {
        Group {
            if let skill = library.selectedSkill {
                SkillDetailView(
                    skill: skill,
                    library: library,
                    onClose: { library.selectedSkill = nil },
                    onInstall: { showInstall = true },
                    onUninstall: { showUninstall = true }
                )
            }
        }
    }

    // MARK: - Computed Helpers

    private var isLocalSource: Bool {
        switch library.selectedSource {
        case .allInstalled, .provider: return true
        case .remote: return false
        }
    }

    private var topbarTitle: String {
        switch library.selectedSource {
        case .allInstalled: return "All Installed Skills"
        case .provider(let p): return p.displayName
        case .remote(let id):
            return library.remoteCatalogs.first { $0.id == id }?.name ?? "Catalog"
        }
    }

    private var topbarSubtitle: String {
        switch library.selectedSource {
        case .allInstalled:
            let count = library.localSkillCount
            return "\(count) skills across \(Provider.allCases.count) providers"
        case .provider(let p):
            let count = library.filteredSkills.count
            return "\(count) skills for \(p.displayName)"
        case .remote(let id):
            guard let catalog = library.remoteCatalogs.first(where: { $0.id == id }) else { return "" }
            let count = catalog.skillCount
            if let url = catalog.url {
                return "\(count) skills \u{2014} \(url)"
            }
            return "\(count) skills"
        }
    }
}
