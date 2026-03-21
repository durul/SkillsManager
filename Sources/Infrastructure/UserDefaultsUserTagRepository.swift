import Foundation
import Domain

/// Infrastructure: Persists user tags in UserDefaults
public final class UserDefaultsUserTagRepository: UserTagRepository, @unchecked Sendable {

    private static let assignmentsKey = "skillsManager.userTags"
    private static let globalTagsKey = "skillsManager.globalTags"

    public init() {}

    public func allTags() -> Set<String> {
        guard let data = UserDefaults.standard.data(forKey: Self.globalTagsKey),
              let decoded = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return Set(decoded)
    }

    public func tags(for skillId: String) -> Set<String> {
        loadAssignments()[skillId] ?? []
    }

    public func addTag(_ tag: String, to skillId: String) {
        // Save global tag
        var global = allTags()
        global.insert(tag)
        saveGlobalTags(global)

        // Save assignment
        var all = loadAssignments()
        all[skillId, default: []].insert(tag)
        saveAssignments(all)
    }

    public func removeTag(_ tag: String, from skillId: String) {
        var all = loadAssignments()
        all[skillId]?.remove(tag)
        if all[skillId]?.isEmpty == true {
            all.removeValue(forKey: skillId)
        }
        saveAssignments(all)
    }

    // MARK: - Persistence

    private func loadAssignments() -> [String: Set<String>] {
        guard let data = UserDefaults.standard.data(forKey: Self.assignmentsKey),
              let decoded = try? JSONDecoder().decode([String: [String]].self, from: data) else {
            return [:]
        }
        return decoded.mapValues { Set($0) }
    }

    private func saveAssignments(_ assignments: [String: Set<String>]) {
        let serializable = assignments.mapValues { Array($0).sorted() }
        if let data = try? JSONEncoder().encode(serializable) {
            UserDefaults.standard.set(data, forKey: Self.assignmentsKey)
        }
    }

    private func saveGlobalTags(_ tags: Set<String>) {
        if let data = try? JSONEncoder().encode(Array(tags).sorted()) {
            UserDefaults.standard.set(data, forKey: Self.globalTagsKey)
        }
    }
}
