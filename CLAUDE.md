# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

```bash
# Build the project
swift build

# Run all tests
swift test

# Run tests for a specific target
swift test --filter DomainTests
swift test --filter InfrastructureTests
swift test --filter AppTests

# Run a specific test suite
swift test --filter "SkillTests"
swift test --filter "SkillTagsTests"

# Run a specific test by name
swift test --filter "SkillTests/skill displays provider name when set"

# Run the app
swift run SkillsManager
```

## Architecture

Three-layer architecture with clean separation:

```
┌─────────────────────────────────────────────────────────────────────┐
│  Domain (Sources/Domain/)                                           │
│  - Rich domain models (Skill, SkillsCatalog, SkillTags, Provider)   │
│  - Domain aggregates (@Observable: SkillsCatalog, SkillTags)        │
│  - Protocols with @Mockable for DI                                  │
│  - Pure business logic, no external dependencies                    │
├─────────────────────────────────────────────────────────────────────┤
│  Infrastructure (Sources/Infrastructure/)                           │
│  - Repository implementations (LocalSkillRepository, GitHub, Git)   │
│  - MergedSkillRepository for combining multiple sources             │
│  - UserDefaultsUserTagRepository for tag persistence                │
│  - External integrations (GitCLIClient, SkillParser)                │
│  - File system operations (FileSystemSkillInstaller)                │
├─────────────────────────────────────────────────────────────────────┤
│  App (Sources/App/)                                                 │
│  - SwiftUI views with Atomic Design (Atoms/Molecules/Organisms)     │
│  - SkillLibrary (@Observable) coordinates catalogs + tags           │
│  - Design tokens (DS enum) matching prototype tokens.css            │
│  - No ViewModel layer — views consume domain directly               │
└─────────────────────────────────────────────────────────────────────┘
```

**Key patterns:**
- Views consume domain models directly - no ViewModel layer
- `@Mockable` protocol annotation generates mocks for testing
- `MOCKING` compiler flag enabled for Domain, Infrastructure, and their tests
- Tell-Don't-Ask: objects encapsulate behavior with their data
- SwiftUI Atomic Design: Atoms → Molecules → Organisms → Pages

## Domain Model Hierarchy

```
SkillLibrary (@Observable, App layer coordinator)
├── localCatalog: SkillsCatalog     ← Installed skills (claude + codex)
├── remoteCatalogs: [SkillsCatalog] ← GitHub repos OR local directories
│   └── skills: [Skill]             ← Each catalog owns its skills
└── skillTags: SkillTags            ← Single shared tag management instance
```

### Key Domain Classes

**SkillsCatalog** - Rich domain class that owns skills:
```swift
@Observable
public final class SkillsCatalog {
    public var skills: [Skill] = []

    // Tell-Don't-Ask: catalog manages its own skills
    public func loadSkills() async { ... }
    public func addSkill(_ skill: Skill) { ... }
    public func removeSkill(uniqueKey: String) { ... }
    public func updateInstallationStatus(for uniqueKey: String, to providers: Set<Provider>) { ... }
    public func syncInstallationStatus(with installedSkills: [Skill]) { ... }
}
```

**SkillTags** - Domain aggregate for global tag management:
```swift
@Observable
public final class SkillTags {
    public private(set) var globalTags: Set<String>  // All user-created tags

    // Queries
    public func allTags(for skill: Skill) -> [String]        // file + custom, sorted
    public func hasTag(_ tag: String, skill: Skill) -> Bool
    public func tagCounts(for skills: [Skill]) -> [String: Int]
    public func availableTags(for skillId: String) -> Set<String>

    // Commands
    public func createTag(_ tag: String, for skillId: String)  // new tag + assign
    public func assignTag(_ tag: String, to skillId: String)   // assign existing
    public func removeTag(_ tag: String, from skillId: String) // unassign
}
```

**SkillLibrary** - Coordinates catalogs and tags:
```swift
@Observable
public final class SkillLibrary {
    public let localCatalog: SkillsCatalog
    public var remoteCatalogs: [SkillsCatalog]
    public let skillTags: SkillTags

    public var filteredSkills: [Skill] {
        // Filters by source, provider, tag (via skillTags), and search
    }
    public var tagCounts: [String: Int] {
        skillTags.tagCounts(for: selectedCatalog.skills)
    }
}
```

## TDD Approach (Chicago School)

This project follows **Chicago School TDD** (state-based testing):

- Test **state changes** and **return values**, not method call interactions
- Use `given().willReturn()` to stub mock data
- Avoid `verify().called()` for interaction testing
- Use Swift Testing framework (`@Test`, `@Suite`, `#expect`)

Example pattern:
```swift
@Test func `install adds skill to local catalog`() async {
    let remoteSkill = makeRemoteSkill(id: "test")
    let localCatalog = makeLocalCatalog()
    let mockInstaller = MockSkillInstaller()

    given(mockInstaller).install(.any, to: .any).willReturn(remoteSkill.installing(for: .claude))

    let library = SkillLibrary(localCatalog: localCatalog, installer: mockInstaller)
    library.selectedSkill = remoteSkill

    await library.install(to: [.claude])

    #expect(localCatalog.skills.count == 1)
}
```

## Domain Model Design

Domain models encapsulate behavior matching user's mental model:

```swift
public struct Skill: Sendable, Equatable, Identifiable {
    // User asks: "What name should I see?"
    public var displayName: String { ... }

    // User asks: "Is this skill installed?"
    public var isInstalled: Bool { !installedProviders.isEmpty }

    // User asks: "Can I edit this skill?"
    public var isEditable: Bool { source.isLocal }

    // User asks: "Is this installed everywhere?"
    public var isFullyInstalled: Bool { ... }
}
```

**SkillTags** models the user's mental model for tagging:
> "I create tags to organize my skills. Tags are global labels.
> Once a tag exists, I can assign it to any skill.
> Tags show in the filter bar regardless of which catalog I'm viewing."

## Tell-Don't-Ask Principle

Objects bundle data with behavior. Instead of:
```swift
// BAD: Asking for data and operating on it
for index in catalog.skills.indices {
    if catalog.skills[index].uniqueKey == uniqueKey {
        catalog.skills[index] = catalog.skills[index].withInstalledProviders(providers)
    }
}
```

Use:
```swift
// GOOD: Tell the object what to do
catalog.updateInstallationStatus(for: uniqueKey, to: providers)
```

## Skill Sources

The app manages skills from multiple sources:

- **Local Catalog**: Installed skills from `~/.claude/skills/` and `~/.codex/skills/`
  - Uses `MergedSkillRepository` to combine claude + codex providers
- **Remote Catalogs**: GitHub repositories or local directories containing skills
  - GitHub: Uses `ClonedRepoSkillRepository` to clone and parse skills
  - Local: Uses `LocalDirectorySkillRepository` for `file://` URLs

### Source Filter
```swift
public enum SourceFilter: Hashable {
    case allInstalled               // Show localCatalog.skills
    case provider(Provider)         // Filter by specific provider
    case remote(repoId: UUID)       // Show remoteCatalog.skills
}
```

## Persistence

- **Remote catalogs** persisted via `UserDefaults` using `SkillsCatalog.Data` (Codable)
- **User tags** persisted via `UserDefaultsUserTagRepository`
- **Local catalog** rebuilt from filesystem on each load

## SwiftUI View Structure (Atomic Design)

```
ContentView (Page — 3-column layout)
├── SidebarView (Organism)
├── Main Content
│   ├── Topbar + CategoryTabsBar (Molecule) + StatsBar (Molecule)
│   └── SkillCardView / SkillRowView (grid/list)
├── SkillDetailView (Organism, right panel)
│   └── EditableTagsView (Atom — file tags + custom tags)
└── Sheets: AddCatalogSheet, InstallSheet, UninstallSheet
```

Design tokens in `DS` enum match the HTML prototype's `tokens.css`.
