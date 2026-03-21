import Testing
import Foundation
import Mockable
@testable import Domain

@Suite
@MainActor
struct SkillTagsTests {

    // MARK: - All Tags

    @Test func `allTags combines file tags and custom tags`() {
        let tags = SkillTags(fileTags: ["development", "swift"], customTags: ["favorites"])

        #expect(tags.allTags == ["development", "favorites", "swift"])
    }

    @Test func `allTags deduplicates when custom tag matches file tag`() {
        let tags = SkillTags(fileTags: ["development", "swift"], customTags: ["swift", "favorites"])

        #expect(tags.allTags == ["development", "favorites", "swift"])
    }

    @Test func `allTags returns sorted`() {
        let tags = SkillTags(fileTags: ["zebra"], customTags: ["alpha"])

        #expect(tags.allTags == ["alpha", "zebra"])
    }

    @Test func `allTags empty when no tags`() {
        let tags = SkillTags(fileTags: [], customTags: [])

        #expect(tags.allTags.isEmpty)
    }

    // MARK: - Has Tag

    @Test func `hasTag finds file tag`() {
        let tags = SkillTags(fileTags: ["development"], customTags: [])

        #expect(tags.hasTag("development") == true)
        #expect(tags.hasTag("testing") == false)
    }

    @Test func `hasTag finds custom tag`() {
        let tags = SkillTags(fileTags: [], customTags: ["favorites"])

        #expect(tags.hasTag("favorites") == true)
        #expect(tags.hasTag("testing") == false)
    }

    // MARK: - Add Custom Tag

    @Test func `addCustomTag mutates customTags`() {
        let tags = SkillTags(fileTags: ["development"], customTags: [])

        tags.addCustomTag("favorites")

        #expect(tags.customTags == ["favorites"])
        #expect(tags.fileTags == ["development"])
    }

    @Test func `addCustomTag normalizes to lowercase and trims`() {
        let tags = SkillTags(fileTags: [], customTags: [])

        tags.addCustomTag("  MyTag  ")

        #expect(tags.customTags == ["mytag"])
    }

    @Test func `addCustomTag ignores empty string`() {
        let tags = SkillTags(fileTags: [], customTags: [])

        tags.addCustomTag("   ")

        #expect(tags.customTags.isEmpty)
    }

    @Test func `addCustomTag ignores duplicate`() {
        let tags = SkillTags(fileTags: [], customTags: ["favorites"])

        tags.addCustomTag("favorites")

        #expect(tags.customTags.count == 1)
    }

    // MARK: - Remove Custom Tag

    @Test func `removeCustomTag removes tag`() {
        let tags = SkillTags(fileTags: ["development"], customTags: ["favorites", "my-team"])

        tags.removeCustomTag("favorites")

        #expect(tags.customTags == ["my-team"])
        #expect(tags.fileTags == ["development"])
    }

    @Test func `removeCustomTag does not affect file tags`() {
        let tags = SkillTags(fileTags: ["development"], customTags: [])

        tags.removeCustomTag("development")

        #expect(tags.fileTags == ["development"])
    }

    // MARK: - Tag Counts

    @Test func `tagCounts from multiple SkillTags`() {
        let tags1 = SkillTags(fileTags: ["development", "swift"], customTags: ["favorites"])
        let tags2 = SkillTags(fileTags: ["development"], customTags: ["favorites", "my-team"])

        let counts = SkillTags.tagCounts(from: [tags1, tags2])

        #expect(counts["development"] == 2)
        #expect(counts["swift"] == 1)
        #expect(counts["favorites"] == 2)
        #expect(counts["my-team"] == 1)
    }

    // MARK: - Init with Repository

    @Test func `init loads custom tags from repository`() {
        let repo = MockUserTagRepository()
        given(repo).tags(for: .value("my-skill")).willReturn(["favorites", "my-team"])

        let tags = SkillTags(skillId: "my-skill", fileTags: ["dev"], repository: repo)

        #expect(tags.customTags == ["favorites", "my-team"])
        #expect(tags.fileTags == ["dev"])
    }

    @Test func `addCustomTag persists to repository`() {
        let repo = MockUserTagRepository()
        given(repo).tags(for: .any).willReturn([])
        given(repo).addTag(.any, to: .any).willReturn(())

        let tags = SkillTags(skillId: "my-skill", fileTags: [], repository: repo)
        tags.addCustomTag("favorites")

        #expect(tags.customTags.contains("favorites"))
    }

    @Test func `removeCustomTag persists to repository`() {
        let repo = MockUserTagRepository()
        given(repo).tags(for: .any).willReturn(["favorites"])
        given(repo).removeTag(.any, from: .any).willReturn(())

        let tags = SkillTags(skillId: "my-skill", fileTags: [], repository: repo)
        tags.removeCustomTag("favorites")

        #expect(!tags.customTags.contains("favorites"))
    }
}
