# Skills Manager Architecture

## Overview

Skills Manager is a macOS app that helps users discover, browse, install, and tag skills for AI coding assistants (Claude Code and Codex).

## Features

- Browse skills from remote GitHub repositories (like anthropics/skills)
- Browse skills from local directories (e.g., `~/projects/.agent/skills/`)
- View locally installed skills filtered by provider
- Search and filter skills by name, description, or tags
- Tag skills with global custom labels (persist across catalogs)
- View skill details with rendered markdown
- Edit local skill SKILL.md with split-pane editor and live preview
- Install skills to Claude Code (`~/.claude/skills`) and/or Codex (`~/.codex/skills`)
- Uninstall or unlink skills from providers
- Show provider badges indicating where a skill is installed

## Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                        SKILLS MANAGER ARCHITECTURE                          │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  DOMAIN LAYER (Sources/Domain/)                                              │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │                                                                        │  │
│  │  Skill (struct)                    ← Rich domain model with behavior  │  │
│  │  ├── id, name, description, version, content, tags                    │  │
│  │  ├── isInstalled, displayName, uniqueKey                              │  │
│  │  ├── isInstalledFor(_:), matches(query:), canBeInstalled              │  │
│  │  └── installing(for:), uninstalling(from:)                            │  │
│  │                                                                        │  │
│  │  SkillsCatalog (@Observable class) ← Owns and manages skills          │  │
│  │  ├── skills: [Skill], isLoading, errorMessage                         │  │
│  │  ├── loadSkills(), addSkill(), removeSkill()                          │  │
│  │  ├── updateInstallationStatus(), syncInstallationStatus()             │  │
│  │  └── allTags, skillCount, isLocal, isLocalDirectory                   │  │
│  │                                                                        │  │
│  │  SkillTags (@Observable class)     ← Global tag management aggregate  │  │
│  │  ├── globalTags: Set<String>       ← All user-created tags            │  │
│  │  ├── createTag(_:for:)             ← New tag + assign to skill        │  │
│  │  ├── assignTag(_:to:)              ← Assign existing tag              │  │
│  │  ├── removeTag(_:from:)            ← Unassign (tag stays global)      │  │
│  │  ├── hasTag(_:skill:)              ← Checks file + custom tags        │  │
│  │  ├── allTags(for:)                 ← Combined, sorted                 │  │
│  │  ├── tagCounts(for:)              ← Counts for skills in view         │  │
│  │  ├── availableTags(for:)           ← Global tags not yet on skill     │  │
│  │  └── repository: UserTagRepository ← CRUD persistence (injected)      │  │
│  │                                                                        │  │
│  │  SkillEditor (@Observable class)   ← Draft editing state              │  │
│  │  Provider (enum)                   ← .claude, .codex                  │  │
│  │  SkillSource (enum)                ← .local, .remote, .localDirectory │  │
│  │                                                                        │  │
│  │  Protocols (@Mockable):                                                │  │
│  │  ├── SkillRepository               ← fetchAll(), fetch(id:)           │  │
│  │  ├── SkillInstaller                ← install(_:to:), uninstall(_:from:)│ │
│  │  ├── SkillWriter                   ← save(_:)                         │  │
│  │  ├── UserTagRepository             ← allTags(), tags(for:), addTag(), │  │
│  │  │                                    removeTag()                      │  │
│  │  └── GitCLIClient                  ← clone(), pull()                  │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  INFRASTRUCTURE LAYER (Sources/Infrastructure/)                              │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐              │
│  │ MergedSkillRepo │  │ ClonedRepoSkill │  │ LocalDirectory  │              │
│  │ (claude+codex)  │  │ Repository      │  │ SkillRepository │              │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘              │
│           ▼                    ▼                     ▼                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────────┐             │
│  │ LocalSkillRepo  │  │ GitCLIClient    │  │ UserDefaultsUser │             │
│  │ (FileSystem)    │  │ (git clone/pull)│  │ TagRepository    │             │
│  └─────────────────┘  └─────────────────┘  └──────────────────┘             │
│  ┌─────────────────┐  ┌─────────────────┐                                   │
│  │ FileSystemSkill │  │ SkillParser     │                                   │
│  │ Installer       │  │ (SKILL.md)      │                                   │
│  └─────────────────┘  └─────────────────┘                                   │
│                                                                              │
│  APP LAYER (Sources/App/)                                                    │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │  SkillLibrary (@Observable) ← Coordinates catalogs + tags             │  │
│  │  ├── localCatalog, remoteCatalogs                                     │  │
│  │  ├── skillTags: SkillTags (single shared instance)                    │  │
│  │  ├── filteredSkills, tagCounts (computed, uses SkillTags)              │  │
│  │  └── install(), uninstall(), addCatalog(), removeCatalog()            │  │
│  │                                                                        │  │
│  │  Design Tokens (DS enum) ← Matches prototype tokens.css               │  │
│  │                                                                        │  │
│  │  Views (SwiftUI Atomic Design — no ViewModel layer):                   │  │
│  │  ┌──────────────────────────────────────────────────────────────────┐  │  │
│  │  │ Page: ContentView (3-column: sidebar | main | detail)           │  │  │
│  │  │                                                                  │  │  │
│  │  │ Organisms:                                                       │  │  │
│  │  │ ├── SidebarView (search, installed nav, catalogs, add catalog)  │  │  │
│  │  │ ├── SkillCardView / SkillRowView (grid/list skill display)      │  │  │
│  │  │ ├── SkillDetailView (right panel with all skill info)           │  │  │
│  │  │ └── SkillEditorView (split pane markdown editor + preview)      │  │  │
│  │  │                                                                  │  │  │
│  │  │ Molecules:                                                       │  │  │
│  │  │ ├── CategoryTabsBar (tag filter tabs with counts)               │  │  │
│  │  │ ├── StatsBar (total/installed/catalogs)                         │  │  │
│  │  │ └── ProviderLinkCard (provider icon + status)                   │  │  │
│  │  │                                                                  │  │  │
│  │  │ Atoms:                                                           │  │  │
│  │  │ ├── TagChip (version/category/provider/refs/scripts badges)     │  │  │
│  │  │ ├── EditableTagsView (file tags + custom tags + add/remove)     │  │  │
│  │  │ ├── FlowLayout (wrapping horizontal layout)                     │  │  │
│  │  │ ├── LinkStatusBadge, StoragePath                                │  │  │
│  │  │ └── MarkdownView (rendered markdown using swift-markdown)       │  │  │
│  │  │                                                                  │  │  │
│  │  │ Sheets:                                                          │  │  │
│  │  │ ├── AddCatalogSheet (GitHub URL / local directory picker)       │  │  │
│  │  │ ├── InstallSheet (provider checkboxes + progress + success)     │  │  │
│  │  │ └── UninstallSheet (unlink vs full uninstall)                   │  │  │
│  │  └──────────────────────────────────────────────────────────────────┘  │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────────────┘
```

## Layers

| Layer | Location | Purpose |
|-------|----------|---------|
| **Domain** | `Sources/Domain/` | Rich models, protocols, domain aggregates |
| **Infrastructure** | `Sources/Infrastructure/` | Repositories, clients, parsers, persistence |
| **App** | `Sources/App/` | SwiftUI views consuming domain directly (no ViewModel) |

## Domain Models

### Domain Model Hierarchy

```
SkillLibrary (@Observable, App layer coordinator)
├── localCatalog: SkillsCatalog     ← Installed skills (claude + codex)
├── remoteCatalogs: [SkillsCatalog] ← GitHub repos OR local directories
│   └── skills: [Skill]             ← Each catalog OWNS its skills
└── skillTags: SkillTags            ← Single shared instance for tag management
```

**Catalog Types:**
- **Local Catalog** (`url == nil`): Installed skills from `~/.claude/skills` and `~/.codex/skills`
- **GitHub Catalog** (`url` starts with `https://github.com/`): Skills from cloned GitHub repos
- **Local Directory Catalog** (`url` starts with `file://`): Skills from any local directory

### SkillsCatalog

Rich domain class that owns and manages its skills. Follows Tell-Don't-Ask principle.

```swift
@Observable
@MainActor
public final class SkillsCatalog: Identifiable {
    public let id: UUID
    public let url: String?           // nil for local catalog
    public let name: String

    public var skills: [Skill] = []   // Catalog OWNS its skills
    public var isLoading: Bool = false

    // Tell-Don't-Ask: catalog manages its own skills
    public func loadSkills() async { ... }
    public func addSkill(_ skill: Skill) { ... }
    public func removeSkill(uniqueKey: String) { ... }
    public func updateInstallationStatus(for uniqueKey: String, to providers: Set<Provider>) { ... }
    public func syncInstallationStatus(with installedSkills: [Skill]) { ... }
}
```

### SkillTags

Domain aggregate for the tags feature. Single `@Observable` instance shared across the app.

```swift
@Observable
@MainActor
public final class SkillTags {
    public private(set) var globalTags: Set<String>     // All user-created tags
    private var assignments: [String: Set<String>]      // skillId -> custom tags

    // Queries (user's mental model)
    public func allTags(for skill: Skill) -> [String]   // file + custom, sorted
    public func hasTag(_ tag: String, skill: Skill) -> Bool
    public func tagCounts(for skills: [Skill]) -> [String: Int]  // includes global tags
    public func availableTags(for skillId: String) -> Set<String>

    // Commands
    public func createTag(_ tag: String, for skillId: String)    // new tag + assign
    public func assignTag(_ tag: String, to skillId: String)     // assign existing
    public func removeTag(_ tag: String, from skillId: String)   // unassign

    private let repository: UserTagRepository?  // CRUD only
}
```

**User mental model:**
> "I create tags to organize my skills. Once a tag exists, I can assign it to any skill.
> Tags are global — they show in the filter bar regardless of which catalog I'm viewing."

### SkillLibrary

Coordinates catalogs and tags. Views consume this directly.

```swift
@Observable
@MainActor
public final class SkillLibrary {
    public let localCatalog: SkillsCatalog
    public var remoteCatalogs: [SkillsCatalog]
    public let skillTags: SkillTags              // Single shared instance

    // Computed (uses SkillTags for tag-aware filtering)
    public var filteredSkills: [Skill] { ... }   // filters by source, provider, tag, search
    public var tagCounts: [String: Int] {        // delegates to skillTags.tagCounts(for:)
        skillTags.tagCounts(for: selectedCatalog.skills)
    }

    // Actions
    public func install(to providers: Set<Provider>) async { ... }
    public func uninstall(from provider: Provider) async { ... }
    public func addCatalog(url: String) { ... }
    public func removeCatalog(_ catalog: SkillsCatalog) { ... }
    public func startEditing() { ... }
    public func saveEditing() async { ... }
}
```

### Skill

Rich domain model representing an installable skill.

```swift
public struct Skill: Sendable, Equatable, Identifiable {
    public let id: String               // Folder name, shared across catalogs
    public let name: String
    public let description: String
    public let version: String
    public let content: String           // Full SKILL.md content
    public let source: SkillSource
    public let tags: [String]            // From SKILL.md frontmatter
    public var installedProviders: Set<Provider>

    // Computed behavior
    public var isInstalled: Bool { !installedProviders.isEmpty }
    public var displayName: String { ... }
    public var uniqueKey: String { ... }   // repoPath/id for deduplication
    public func isInstalledFor(_ provider: Provider) -> Bool
    public func matches(query: String) -> Bool
    public var canBeInstalled: Bool
    public var isFullyInstalled: Bool
    public var isEditable: Bool
}
```

### Provider

Pure value object representing installation targets.

```swift
public enum Provider: String, CaseIterable, Sendable {
    case codex
    case claude
    public var displayName: String  // "Codex" or "Claude Code"
}
```

### SkillSource

```swift
public enum SkillSource: Sendable, Equatable {
    case local(provider: Provider)
    case remote(repoUrl: String)
    case localDirectory(path: String)
}
```

## Component Interactions

| Component | Purpose | Dependencies |
|-----------|---------|--------------|
| `Skill` | Rich domain model | None |
| `SkillsCatalog` | Owns skills, Tell-Don't-Ask | SkillRepository |
| `SkillTags` | Global tag management aggregate | UserTagRepository |
| `SkillLibrary` | Coordinates catalogs + tags | SkillsCatalog, SkillTags, SkillInstaller |
| `SkillEditor` | Draft editing state | SkillWriter |
| `MergedSkillRepository` | Combines claude + codex repos | SkillRepository[] |
| `LocalSkillRepository` | Reads local installed skills | FileSystem |
| `ClonedRepoSkillRepository` | Fetches from cloned GitHub repo | GitCLIClient |
| `LocalDirectorySkillRepository` | Reads from any directory | FileSystem |
| `UserDefaultsUserTagRepository` | Persists user tags | UserDefaults |
| `SkillParser` | Parses SKILL.md frontmatter | None |
| `FileSystemSkillInstaller` | Copies skills to provider paths | FileSystem |

## Data Flow

### Browsing Skills

```
User selects source ──▶ SkillLibrary.selectedSource changes
                                    │
                                    ▼
                        selectedCatalog computed ──▶ filteredSkills recomputes
                                    │
                                    ▼
                        tagCounts recomputes via skillTags.tagCounts(for:)
                                    │
                                    ▼
                        SwiftUI observes @Observable changes, updates UI
```

### Tagging a Skill

```
User adds tag "swift" to skill ──▶ SkillTags.createTag("swift", for: skillId)
                                            │
                                            ▼
                                  globalTags.insert("swift")     ← @Observable
                                  assignments[skillId] += "swift" ← @Observable
                                  repository.addTag(...)          ← persists
                                            │
                                            ▼
                                  tagCounts recomputes (includes global "swift")
                                  CategoryTabsBar shows "swift" tab
                                  EditableTagsView shows cyan chip
```

### Installing a Skill

```
User clicks "Install" ──▶ InstallSheet ──▶ User selects providers
                                                    │
                                                    ▼
                            SkillLibrary.install(to: providers)
                                                    │
                                                    ▼
                            FileSystemSkillInstaller copies to paths
                                                    │
                                                    ▼
                            localCatalog.addSkill(installedSkill)
                            All catalogs sync installation status
```

## SwiftUI View Architecture (Atomic Design)

```
ContentView (Page)
├── SidebarView (Organism)
│   ├── Search TextField
│   ├── Installed section (All / Claude Code / Codex nav items)
│   ├── Catalogs section (remote catalogs with context menu)
│   └── Add Catalog button
├── Main Content
│   ├── Topbar (title + subtitle + view toggle + refresh)
│   ├── CategoryTabsBar (Molecule — tag filter tabs)
│   ├── StatsBar (Molecule — total/installed/catalogs, local view only)
│   └── Skills Grid/List
│       ├── SkillCardView (grid mode — card with name, desc, tags, icon)
│       └── SkillRowView (list mode — compact row)
└── SkillDetailView (Organism, conditional right panel)
    ├── Header (name + source + close)
    ├── Description
    ├── EditableTagsView (Atom — purple file tags + cyan custom tags)
    ├── Metadata grid (version, refs, scripts, source)
    ├── Storage path
    ├── Provider link cards (Molecule)
    ├── Content preview (MarkdownView)
    └── Footer (uninstall / edit / install buttons)
```

## Design Tokens

All UI styling uses `DS` enum (`Sources/App/Theme/DesignTokens.swift`) matching the HTML prototype's `tokens.css`:

- **Colors**: Dark theme (`#0F172A` bg, `#F1F5F9` text, `#3B82F6` accent)
- **Typography**: System fonts matching prototype sizes (16px titles, 13px body, 11px captions)
- **Spacing**: 6px sm, 8px md, 12px lg, 16px xl, 24px xxxl
- **Radius**: 6px sm, 10px md, 14px lg
- **Layout**: 260px sidebar, 420px detail panel, 300px min card width

## Project Structure

```
SkillsManager/
├── Sources/
│   ├── Domain/
│   │   ├── Models/
│   │   │   ├── Skill.swift
│   │   │   ├── Provider.swift
│   │   │   ├── SkillSource.swift
│   │   │   ├── SkillsCatalog.swift
│   │   │   ├── SkillTags.swift          # @Observable tag management aggregate
│   │   │   ├── SkillEditor.swift
│   │   │   └── SkillsRepository.swift   # Default catalog data
│   │   └── Protocols/
│   │       ├── SkillRepository.swift     # @Mockable
│   │       ├── UserTagRepository.swift   # @Mockable
│   │       └── GitCLIClient.swift        # @Mockable
│   ├── Infrastructure/
│   │   ├── Repositories/
│   │   │   └── MergedSkillRepository.swift
│   │   ├── Local/
│   │   │   ├── LocalSkillRepository.swift
│   │   │   ├── LocalDirectorySkillRepository.swift
│   │   │   ├── LocalSkillWriter.swift
│   │   │   └── ProviderPathResolver.swift
│   │   ├── Git/
│   │   │   └── ClonedRepoSkillRepository.swift
│   │   ├── Parser/
│   │   │   └── SkillParser.swift
│   │   ├── Installer/
│   │   │   └── FileSystemSkillInstaller.swift
│   │   └── UserDefaultsUserTagRepository.swift
│   └── App/
│       ├── SkillsManagerApp.swift
│       ├── SkillLibrary.swift            # @Observable coordinator
│       ├── AppSettings.swift
│       ├── Theme/
│       │   └── DesignTokens.swift        # DS enum (colors, typography, spacing)
│       └── Views/
│           ├── ContentView.swift          # Root 3-column layout
│           ├── Sidebar/
│           │   ├── SidebarView.swift
│           │   └── SkillRowView.swift     # SkillCardView + SkillRowView
│           ├── Detail/
│           │   ├── SkillDetailView.swift
│           │   ├── SkillEditorView.swift
│           │   └── MarkdownView.swift
│           ├── Atoms/
│           │   ├── TagChip.swift
│           │   ├── EditableTagsView.swift
│           │   ├── FlowLayout.swift
│           │   ├── LinkStatusBadge.swift
│           │   └── StoragePath.swift
│           ├── Molecules/
│           │   ├── CategoryTabsBar.swift
│           │   ├── StatsBar.swift
│           │   └── ProviderLinkCard.swift
│           ├── Sheets/
│           │   ├── AddCatalogSheet.swift
│           │   ├── InstallSheet.swift
│           │   └── UninstallSheet.swift
│           └── Settings/
│               └── SettingsView.swift
└── Tests/
    ├── DomainTests/
    │   ├── SkillTests.swift
    │   ├── SkillTagsTests.swift          # 16 tests for tag aggregate
    │   ├── SkillEditorTests.swift
    │   └── ProviderTests.swift
    ├── AppTests/
    │   ├── SkillLibraryTests.swift
    │   └── SkillLibraryUserTagTests.swift # Cross-catalog tag tests
    └── InfrastructureTests/
        ├── SkillParserTests.swift
        ├── LocalSkillRepositoryTests.swift
        ├── LocalDirectorySkillRepositoryTests.swift
        ├── ClonedRepoSkillRepositoryTests.swift
        └── FileSystemSkillInstallerTests.swift
```

## Key Patterns

- **Rich Domain Models** — Behavior encapsulated in models (Skill, SkillTags, SkillsCatalog)
- **Tell-Don't-Ask** — Objects manage their own state; callers tell objects what to do
- **Domain Aggregates** — SkillTags is an @Observable aggregate managing the entire tags feature
- **Protocol-Based DI** — `@Mockable` protocols for testability (SkillRepository, UserTagRepository)
- **Chicago School TDD** — Test state changes and return values, not interactions
- **No ViewModel Layer** — Views consume domain models directly
- **SwiftUI Atomic Design** — Atoms → Molecules → Organisms → Pages
- **@Observable Classes** — SkillsCatalog, SkillTags, SkillLibrary drive SwiftUI reactivity
- **Design Tokens** — DS enum mirrors prototype CSS variables for consistent styling
