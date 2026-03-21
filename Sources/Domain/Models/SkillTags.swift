import Foundation
import Observation

/// Domain aggregate for the tags feature
/// User thinks: "I create tags to organize my skills. Any skill can belong to any tag."
@Observable
@MainActor
public final class SkillTags {

    /// All user-created tags (global registry)
    public private(set) var globalTags: Set<String> = []

    /// Skill assignments: skillId -> set of custom tags
    private var assignments: [String: Set<String>] = [:]

    /// Repository for persistence (CRUD only)
    private let repository: UserTagRepository?

    // MARK: - Init

    /// Production init: loads state from repository
    public init(repository: UserTagRepository, skillIds: [String] = []) {
        self.repository = repository
        self.globalTags = repository.allTags()
        for skillId in skillIds {
            let tags = repository.tags(for: skillId)
            if !tags.isEmpty {
                assignments[skillId] = tags
            }
        }
    }

    /// Test init: no persistence
    public init() {
        self.repository = nil
    }

    // MARK: - Queries

    /// Custom tags assigned to a skill
    public func customTags(for skillId: String) -> Set<String> {
        assignments[skillId] ?? []
    }

    /// Whether a skill has a specific custom tag
    public func hasTag(_ tag: String, skillId: String) -> Bool {
        assignments[skillId]?.contains(tag) == true
    }

    /// Whether a skill has a tag (file or custom)
    public func hasTag(_ tag: String, skill: Skill) -> Bool {
        skill.tags.contains(tag) || hasTag(tag, skillId: skill.id)
    }

    /// All tags for a skill (file + custom), deduplicated, sorted
    public func allTags(for skill: Skill) -> [String] {
        var combined = Set(skill.tags)
        combined.formUnion(customTags(for: skill.id))
        return combined.sorted()
    }

    /// Global tags not yet assigned to this skill
    public func availableTags(for skillId: String) -> Set<String> {
        globalTags.subtracting(customTags(for: skillId))
    }

    /// Tag counts for a set of skills (file tags + custom tags)
    public func tagCounts(for skills: [Skill]) -> [String: Int] {
        var counts: [String: Int] = [:]
        for skill in skills {
            for tag in allTags(for: skill) {
                counts[tag, default: 0] += 1
            }
        }
        return counts
    }

    // MARK: - Commands

    /// Create a new tag and assign it to a skill
    public func createTag(_ tag: String, for skillId: String) {
        let normalized = tag.trimmingCharacters(in: .whitespaces).lowercased()
        guard !normalized.isEmpty else { return }

        globalTags.insert(normalized)
        assignments[skillId, default: []].insert(normalized)
        repository?.addTag(normalized, to: skillId)
    }

    /// Assign an existing global tag to a skill
    public func assignTag(_ tag: String, to skillId: String) {
        guard globalTags.contains(tag) else { return }
        assignments[skillId, default: []].insert(tag)
        repository?.addTag(tag, to: skillId)
    }

    /// Remove a tag from a skill (tag stays global)
    public func removeTag(_ tag: String, from skillId: String) {
        assignments[skillId]?.remove(tag)
        if assignments[skillId]?.isEmpty == true {
            assignments.removeValue(forKey: skillId)
        }
        repository?.removeTag(tag, from: skillId)
    }

    /// Load tags for additional skill ids (e.g. when new catalog loads)
    public func loadSkillTags(for skillIds: [String]) {
        guard let repo = repository else { return }
        for skillId in skillIds {
            let tags = repo.tags(for: skillId)
            if !tags.isEmpty {
                assignments[skillId] = tags
            }
        }
    }
}
