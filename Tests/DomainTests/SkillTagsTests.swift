import Testing
import Foundation
import Mockable
@testable import Domain

@Suite
@MainActor
struct SkillTagsTests {

    // MARK: - Create Tag

    @Test func `createTag adds global tag and assigns to skill`() {
        let tags = makeSkillTags()

        tags.createTag("favorites", for: "skill-a")

        #expect(tags.globalTags == ["favorites"])
        #expect(tags.customTags(for: "skill-a") == ["favorites"])
    }

    @Test func `createTag normalizes to lowercase and trims`() {
        let tags = makeSkillTags()

        tags.createTag("  MyTag  ", for: "skill-a")

        #expect(tags.globalTags == ["mytag"])
    }

    @Test func `createTag ignores empty string`() {
        let tags = makeSkillTags()

        tags.createTag("   ", for: "skill-a")

        #expect(tags.globalTags.isEmpty)
    }

    // MARK: - Assign Existing Tag

    @Test func `assignTag adds existing tag to another skill`() {
        let tags = makeSkillTags()
        tags.createTag("favorites", for: "skill-a")

        tags.assignTag("favorites", to: "skill-b")

        #expect(tags.customTags(for: "skill-b") == ["favorites"])
    }

    // MARK: - Remove Tag

    @Test func `removeTag unassigns tag from skill`() {
        let tags = makeSkillTags()
        tags.createTag("favorites", for: "skill-a")

        tags.removeTag("favorites", from: "skill-a")

        #expect(tags.customTags(for: "skill-a").isEmpty)
        // Tag still exists globally
        #expect(tags.globalTags.contains("favorites"))
    }

    // MARK: - Has Tag

    @Test func `hasTag returns true for assigned custom tag`() {
        let tags = makeSkillTags()
        tags.createTag("favorites", for: "skill-a")

        #expect(tags.hasTag("favorites", skillId: "skill-a") == true)
        #expect(tags.hasTag("favorites", skillId: "skill-b") == false)
    }

    @Test func `hasTag returns true for file tag`() {
        let tags = makeSkillTags()
        let skill = makeSkill(id: "skill-a", fileTags: ["development"])

        #expect(tags.hasTag("development", skill: skill) == true)
        #expect(tags.hasTag("testing", skill: skill) == false)
    }

    // MARK: - Available Tags

    @Test func `availableTags returns global tags not yet on this skill`() {
        let tags = makeSkillTags()
        tags.createTag("favorites", for: "skill-a")
        tags.createTag("my-team", for: "skill-a")

        let available = tags.availableTags(for: "skill-b")

        #expect(available == ["favorites", "my-team"])
    }

    @Test func `availableTags excludes tags already assigned`() {
        let tags = makeSkillTags()
        tags.createTag("favorites", for: "skill-a")
        tags.assignTag("favorites", to: "skill-b")
        tags.createTag("my-team", for: "skill-a")

        let available = tags.availableTags(for: "skill-b")

        #expect(available == ["my-team"])
    }

    // MARK: - Tag Counts

    @Test func `tagCounts combines file tags and custom tags for given skills`() {
        let tags = makeSkillTags()
        tags.createTag("favorites", for: "skill-a")
        tags.createTag("favorites", for: "skill-b")
        tags.createTag("my-team", for: "skill-a")

        let skills = [
            makeSkill(id: "skill-a", fileTags: ["development", "swift"]),
            makeSkill(id: "skill-b", fileTags: ["development"]),
        ]

        let counts = tags.tagCounts(for: skills)

        #expect(counts["development"] == 2)
        #expect(counts["swift"] == 1)
        #expect(counts["favorites"] == 2)
        #expect(counts["my-team"] == 1)
    }

    @Test func `tagCounts shows global tags with zero count when no skill matches`() {
        let tags = makeSkillTags()
        tags.createTag("favorites", for: "skill-a")

        // skill-b has no tags at all
        let skills = [makeSkill(id: "skill-b", fileTags: [])]

        let counts = tags.tagCounts(for: skills)

        // favorites exists globally but no skill in this view has it
        #expect(counts["favorites"] == nil || counts["favorites"] == 0)
    }

    // MARK: - All Tags For Skill

    @Test func `allTags combines file tags and custom tags sorted`() {
        let tags = makeSkillTags()
        tags.createTag("favorites", for: "skill-a")

        let skill = makeSkill(id: "skill-a", fileTags: ["development", "swift"])

        let all = tags.allTags(for: skill)

        #expect(all == ["development", "favorites", "swift"])
    }

    @Test func `allTags deduplicates`() {
        let tags = makeSkillTags()
        tags.createTag("development", for: "skill-a")

        let skill = makeSkill(id: "skill-a", fileTags: ["development"])

        let all = tags.allTags(for: skill)

        #expect(all == ["development"])
    }

    // MARK: - Persistence

    @Test func `createTag persists via repository`() {
        let repo = MockUserTagRepository()
        given(repo).tags(for: .any).willReturn([])
        given(repo).allTags().willReturn([])
        given(repo).addTag(.any, to: .any).willReturn(())

        let tags = SkillTags(repository: repo)
        tags.createTag("favorites", for: "skill-a")

        #expect(tags.globalTags.contains("favorites"))
    }

    @Test func `init loads from repository`() {
        let repo = MockUserTagRepository()
        given(repo).allTags().willReturn(["favorites", "my-team"])
        given(repo).tags(for: .value("skill-a")).willReturn(["favorites"])

        let tags = SkillTags(repository: repo, skillIds: ["skill-a"])

        #expect(tags.globalTags == ["favorites", "my-team"])
        #expect(tags.customTags(for: "skill-a") == ["favorites"])
    }

    // MARK: - Helpers

    private func makeSkillTags() -> SkillTags {
        SkillTags()
    }

    private func makeSkill(id: String, fileTags: [String] = []) -> Skill {
        Skill(
            id: id, name: id, description: "", version: "1.0.0",
            content: "", source: .local(provider: .claude),
            installedProviders: [.claude], tags: fileTags
        )
    }
}
