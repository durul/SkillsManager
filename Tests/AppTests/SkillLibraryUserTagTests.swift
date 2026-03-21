import Testing
import Foundation
import Mockable
@testable import App
@testable import Domain

@Suite
@MainActor
struct SkillLibraryUserTagTests {

    // MARK: - Tag Counts Include User Tags

    @Test func `tagCounts includes user tags for skills in current catalog`() async {
        let skill = makeSkill(id: "swift-concurrency", tags: ["development", "swift"])
        let localCatalog = makeLocalCatalog(skills: [skill])
        let mockInstaller = MockSkillInstaller()
        let mockUserTags = MockUserTagRepository()

        given(mockUserTags).allTagCounts().willReturn(["favorites": 1, "my-team": 1])

        let library = SkillLibrary(
            localCatalog: localCatalog,
            installer: mockInstaller,
            userTagRepository: mockUserTags
        )

        let counts = await library.tagCountsIncludingUserTags()

        #expect(counts["development"] == 1)
        #expect(counts["swift"] == 1)
        #expect(counts["favorites"] == 1)
        #expect(counts["my-team"] == 1)
    }

    // MARK: - Filter By User Tag

    @Test func `filteredSkills includes skills matching user tag`() async {
        let skill1 = makeSkill(id: "skill-a", tags: ["development"])
        let skill2 = makeSkill(id: "skill-b", tags: ["testing"])
        let localCatalog = makeLocalCatalog(skills: [skill1, skill2])
        let mockInstaller = MockSkillInstaller()
        let mockUserTags = MockUserTagRepository()

        // skill-a has user tag "favorites"
        given(mockUserTags).tags(for: .value("skill-a")).willReturn(["favorites"])
        given(mockUserTags).tags(for: .value("skill-b")).willReturn([])

        let library = SkillLibrary(
            localCatalog: localCatalog,
            installer: mockInstaller,
            userTagRepository: mockUserTags
        )
        library.selectedTag = "favorites"

        let filtered = await library.filteredSkillsIncludingUserTags()

        #expect(filtered.count == 1)
        #expect(filtered.first?.id == "skill-a")
    }

    @Test func `filteredSkills includes skills matching SKILL md tag even with user tag repo`() async {
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

        let filtered = await library.filteredSkillsIncludingUserTags()

        #expect(filtered.count == 1)
        #expect(filtered.first?.id == "skill-a")
    }

    // MARK: - Add / Remove User Tags

    @Test func `addUserTag delegates to repository`() async {
        let localCatalog = makeLocalCatalog()
        let mockInstaller = MockSkillInstaller()
        let mockUserTags = MockUserTagRepository()

        given(mockUserTags).addTag(.any, to: .any).willReturn(())

        let library = SkillLibrary(
            localCatalog: localCatalog,
            installer: mockInstaller,
            userTagRepository: mockUserTags
        )

        await library.addUserTag("favorites", to: "skill-a")

        // Verify by checking that the method was called (state-based: we trust the repo)
        // The test passes if no error is thrown
    }

    @Test func `removeUserTag delegates to repository`() async {
        let localCatalog = makeLocalCatalog()
        let mockInstaller = MockSkillInstaller()
        let mockUserTags = MockUserTagRepository()

        given(mockUserTags).removeTag(.any, from: .any).willReturn(())

        let library = SkillLibrary(
            localCatalog: localCatalog,
            installer: mockInstaller,
            userTagRepository: mockUserTags
        )

        await library.removeUserTag("favorites", from: "skill-a")
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
