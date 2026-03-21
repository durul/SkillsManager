import Testing
import Foundation
import Mockable
@testable import App
@testable import Domain

@Suite
@MainActor
struct SkillLibraryUserTagTests {

    // MARK: - Tag Counts Include User Tags

    @Test func `tagCounts includes user tags for skills in current catalog`() {
        let skill = makeSkill(id: "swift-concurrency", tags: ["development", "swift"])
        let localCatalog = makeLocalCatalog(skills: [skill])
        let mockInstaller = MockSkillInstaller()
        let mockUserTags = MockUserTagRepository()

        given(mockUserTags).tags(for: .value("swift-concurrency")).willReturn(["favorites", "my-team"])

        let library = SkillLibrary(
            localCatalog: localCatalog,
            installer: mockInstaller,
            userTagRepository: mockUserTags
        )

        let counts = library.tagCounts

        #expect(counts["development"] == 1)
        #expect(counts["swift"] == 1)
        #expect(counts["favorites"] == 1)
        #expect(counts["my-team"] == 1)
    }

    // MARK: - Filter By User Tag

    @Test func `filteredSkills includes skills matching user tag`() {
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

        let filtered = library.filteredSkills

        #expect(filtered.count == 1)
        #expect(filtered.first?.id == "skill-a")
    }

    @Test func `filteredSkills includes skills matching SKILL md tag`() {
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

        let filtered = library.filteredSkills

        #expect(filtered.count == 1)
        #expect(filtered.first?.id == "skill-a")
    }

    // MARK: - Add / Remove User Tags

    @Test func `addUserTag delegates to repository`() {
        let localCatalog = makeLocalCatalog()
        let mockInstaller = MockSkillInstaller()
        let mockUserTags = MockUserTagRepository()

        given(mockUserTags).addTag(.any, to: .any).willReturn(())

        let library = SkillLibrary(
            localCatalog: localCatalog,
            installer: mockInstaller,
            userTagRepository: mockUserTags
        )

        library.addUserTag("favorites", to: "skill-a")
    }

    @Test func `removeUserTag delegates to repository`() {
        let localCatalog = makeLocalCatalog()
        let mockInstaller = MockSkillInstaller()
        let mockUserTags = MockUserTagRepository()

        given(mockUserTags).removeTag(.any, from: .any).willReturn(())

        let library = SkillLibrary(
            localCatalog: localCatalog,
            installer: mockInstaller,
            userTagRepository: mockUserTags
        )

        library.removeUserTag("favorites", from: "skill-a")
    }

    // MARK: - Helpers

    private func makeSkill(id: String, tags: [String] = []) -> Skill {
        Skill(
            id: id,
            name: id,
            description: "Test skill",
            version: "1.0.0",
            content: "",
            source: .local(provider: .claude),
            installedProviders: [.claude],
            tags: tags
        )
    }

    private func makeLocalCatalog(skills: [Skill] = []) -> SkillsCatalog {
        let repo = MockSkillRepository()
        given(repo).fetchAll().willReturn(skills)
        let catalog = SkillsCatalog(name: "Local", loader: repo)
        catalog.skills = skills
        return catalog
    }
}
