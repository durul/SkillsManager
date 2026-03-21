import Foundation
import Mockable

/// Protocol for managing user-added custom tags on skills
/// User tags are stored separately from SKILL.md frontmatter tags
@Mockable
public protocol UserTagRepository: Sendable {
    /// Get user-added tags for a skill
    func tags(for skillKey: String) async -> Set<String>

    /// Add a custom tag to a skill
    func addTag(_ tag: String, to skillKey: String) async

    /// Remove a custom tag from a skill
    func removeTag(_ tag: String, from skillKey: String) async

    /// Get all user tags across all skills, with counts
    func allTagCounts() async -> [String: Int]
}
