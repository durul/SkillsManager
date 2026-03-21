import Foundation
import Mockable

/// Protocol for persisting user-created tags (CRUD only)
@Mockable
public protocol UserTagRepository: Sendable {
    /// Get all globally created tags
    func allTags() -> Set<String>

    /// Get tags assigned to a skill
    func tags(for skillId: String) -> Set<String>

    /// Add a tag to a skill (creates the tag globally if new)
    func addTag(_ tag: String, to skillId: String)

    /// Remove a tag from a skill
    func removeTag(_ tag: String, from skillId: String)
}
