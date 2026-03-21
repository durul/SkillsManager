import Foundation
import Mockable

/// Protocol for managing user-added custom tags on skills
/// User tags are stored separately from SKILL.md frontmatter tags
@Mockable
public protocol UserTagRepository: Sendable {
    /// Get user-added tags for a skill
    func tags(for skillKey: String) -> Set<String>

    /// Add a custom tag to a skill
    func addTag(_ tag: String, to skillKey: String)

    /// Remove a custom tag from a skill
    func removeTag(_ tag: String, from skillKey: String)

    /// Get all user tags across all skills, with counts
    func allTagCounts() -> [String: Int]
}
