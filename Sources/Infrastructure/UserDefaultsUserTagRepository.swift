import Foundation
import Domain

/// Infrastructure: Persists user-added tags in UserDefaults
public actor UserDefaultsUserTagRepository: UserTagRepository {

    private static let storageKey = "skillsManager.userTags"

    public init() {}

    public func tags(for skillKey: String) -> Set<String> {
        loadAll()[skillKey] ?? []
    }

    public func addTag(_ tag: String, to skillKey: String) {
        let normalized = tag.trimmingCharacters(in: .whitespaces).lowercased()
        guard !normalized.isEmpty else { return }

        var all = loadAll()
        all[skillKey, default: []].insert(normalized)
        save(all)
    }

    public func removeTag(_ tag: String, from skillKey: String) {
        var all = loadAll()
        all[skillKey]?.remove(tag)
        if all[skillKey]?.isEmpty == true {
            all.removeValue(forKey: skillKey)
        }
        save(all)
    }

    public func allTagCounts() -> [String: Int] {
        let all = loadAll()
        var counts: [String: Int] = [:]
        for tags in all.values {
            for tag in tags {
                counts[tag, default: 0] += 1
            }
        }
        return counts
    }

    // MARK: - Persistence

    private func loadAll() -> [String: Set<String>] {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let decoded = try? JSONDecoder().decode([String: [String]].self, from: data) else {
            return [:]
        }
        return decoded.mapValues { Set($0) }
    }

    private func save(_ tags: [String: Set<String>]) {
        let serializable = tags.mapValues { Array($0) }
        if let data = try? JSONEncoder().encode(serializable) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }
}
