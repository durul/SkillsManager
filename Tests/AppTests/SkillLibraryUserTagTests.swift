import Testing
import Foundation
import Mockable
@testable import App
@testable import Domain

@Suite
@MainActor
struct SkillLibraryUserTagTests {

    // MARK: - SkillTags Creation

    @Test func `skillTags returns SkillTags with file tags and custom tags`() {
        let skill = makeSkill(id: "my-skill", tags: ["development", "swift"])
        let localCatalog = makeLocalCatalog(skills: [skill])
        let mockInstaller = MockSkillInstaller()
        let mockUserTags = MockUserTagRepository()

        given(mockUserTags).tags(for: .value("my-skill")).willReturn(["favorites"])

        let library = SkillLibrary(
            localCatalog: localCatalog,
            installer: mockInstaller,
            userTagRepository: mockUserTags
        )

        let tags = library.skillTags(for: skill)

        #expect(tags.fileTags == ["development", "swift"])
        #expect(tags.customTags == ["favorites"])
        #expect(tags.allTags == ["development", "favorites", "swift"])
    }

    // MARK: - Tag Counts

    @Test func `tagCounts includes both file tags and custom tags`() {
        let skill = makeSkill(id: "my-skill", tags: ["development"])
        let localCatalog = makeLocalCatalog(skills: [skill])
        let mockInstaller = MockSkillInstaller()
        let mockUserTags = MockUserTagRepository()

        given(mockUserTags).tags(for: .value("my-skill")).willReturn(["favorites"])

        let library = SkillLibrary(
            localCatalog: localCatalog,
            installer: mockInstaller,
            userTagRepository: mockUserTags
        )

        let counts = library.tagCounts

        #expect(counts["development"] == 1)
        #expect(counts["favorites"] == 1)
    }

    // MARK: - Filter By Tag

    @Test func `filteredSkills filters by custom tag`() {
        let skill1 = makeSkill(id: "skill-a", tags: ["development"])
        let skill2 = makeSkill(id: "skill-b", tags: ["testing"])
        let localCatalog = makeLocalCatalog(skills: [skill1, skill2])
        let mockInstaller = MockSkillInstaller()
        let mockUserTags = MockUserTagRepository()

        given(mockUserTags).tags(for: .value("skill-a")).willReturn(["favorites"])
        given(mockUserTags).tags(for: .value("skill-b")).willReturn([])

        let library = SkillLibrary(
            localCatalog: localCatalog,
            installer: mockInstaller,
            userTagRepository: mockUserTags
        )
        library.selectedTag = "favorites"

        #expect(library.filteredSkills.count == 1)
        #expect(library.filteredSkills.first?.id == "skill-a")
    }

    @Test func `filteredSkills filters by file tag`() {
        let skill = makeSkill(id: "skill-a", tags: ["development"])
        let localCatalog = makeLocalCatalog(skills: [skill])
        let mockInstaller = MockSkillInstaller()
        let mockUserTags = MockUserTagRepository()

        given(mockUserTags).tags(for: .value("skill-a")).willReturn([])

        let library = SkillLibrary(
            localCatalog: localCatalog,
            installer: mockInstaller,
            userTagRepository: mockUserTags
        )
        library.selectedTag = "development"

        #expect(library.filteredSkills.count == 1)
    }

    // MARK: - Shared Across Catalogs

    @Test func `skillTags uses skill id so tags are shared across catalogs`() {
        let mockInstaller = MockSkillInstaller()
        let mockUserTags = MockUserTagRepository()

        given(mockUserTags).tags(for: .value("my-skill")).willReturn(["favorites"])

        let localSkill = makeSkill(id: "my-skill", tags: [])
        let remoteSkill = Skill(
            id: "my-skill", name: "my-skill", description: "", version: "1.0.0",
            content: "", source: .remote(repoUrl: "https://github.com/test/repo"),
            repoPath: "skills"
        )

        let localCatalog = makeLocalCatalog(skills: [localSkill])
        let remoteCatalog = makeRemoteCatalog(skills: [remoteSkill])

        let library = SkillLibrary(
            localCatalog: localCatalog,
            remoteCatalogs: [remoteCatalog],
            installer: mockInstaller,
            userTagRepository: mockUserTags
        )

        // Both skills share the same id, so same SkillTags
        let localTags = library.skillTags(for: localSkill)
        let remoteTags = library.skillTags(for: remoteSkill)

        #expect(localTags === remoteTags)
        #expect(localTags.customTags == ["favorites"])
    }

    // MARK: - Helpers

    private func makeSkill(id: String, tags: [String] = []) -> Skill {
        Skill(
            id: id, name: id, description: "Test", version: "1.0.0",
            content: "", source: .local(provider: .claude),
            installedProviders: [.claude], tags: tags
        )
    }

    private func makeLocalCatalog(skills: [Skill] = []) -> SkillsCatalog {
        let repo = MockSkillRepository()
        given(repo).fetchAll().willReturn(skills)
        let catalog = SkillsCatalog(name: "Local", loader: repo)
        catalog.skills = skills
        return catalog
    }

    private func makeRemoteCatalog(skills: [Skill] = []) -> SkillsCatalog {
        let repo = MockSkillRepository()
        given(repo).fetchAll().willReturn(skills)
        let catalog = SkillsCatalog(url: "https://github.com/test/repo", loader: repo)
        catalog.skills = skills
        return catalog
    }
}
