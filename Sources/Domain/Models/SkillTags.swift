import Foundation
import Observation

/// A skill's tags — file-sourced + user-added custom tags
/// User thinks: "This skill has these tags. Some came from the file, some I added."
@Observable
@MainActor
public final class SkillTags {

    /// Tags from SKILL.md frontmatter (read-only)
    public let fileTags: [String]

    /// Tags added by the user (observable, persisted via repository)
    public var customTags: Set<String>

    /// Repository for persisting custom tags
    private let repository: UserTagRepository?

    /// Skill id for repository key
    private let skillId: String

    public init(
        skillId: String,
        fileTags: [String] = [],
        repository: UserTagRepository? = nil
    ) {
        self.skillId = skillId
        self.fileTags = fileTags
        self.repository = repository
        self.customTags = repository?.tags(for: skillId) ?? []
    }

    /// Test-only init without repository
    public init(fileTags: [String] = [], customTags: Set<String> = []) {
        self.skillId = ""
        self.fileTags = fileTags
        self.repository = nil
        self.customTags = customTags
    }

    // MARK: - Computed

    /// All tags combined, deduplicated, sorted
    public var allTags: [String] {
        var combined = Set(fileTags)
        combined.formUnion(customTags)
        return combined.sorted()
    }

    /// Whether this skill has a specific tag (file or custom)
    public func hasTag(_ tag: String) -> Bool {
        fileTags.contains(tag) || customTags.contains(tag)
    }

    // MARK: - Mutation

    /// Add a custom tag
    public func addCustomTag(_ tag: String) {
        let normalized = tag.trimmingCharacters(in: .whitespaces).lowercased()
        guard !normalized.isEmpty else { return }
        customTags.insert(normalized)
        repository?.addTag(normalized, to: skillId)
    }

    /// Remove a custom tag
    public func removeCustomTag(_ tag: String) {
        customTags.remove(tag)
        repository?.removeTag(tag, from: skillId)
    }

    // MARK: - Aggregate

    /// Compute tag counts from multiple SkillTags
    public static func tagCounts(from tagsList: [SkillTags]) -> [String: Int] {
        var counts: [String: Int] = [:]
        for tags in tagsList {
            for tag in tags.allTags {
                counts[tag, default: 0] += 1
            }
        }
        return counts
    }
}
