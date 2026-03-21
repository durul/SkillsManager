import SwiftUI

/// Molecule: Horizontal scrollable tag filter tabs
/// Matches prototype .category-tabs style
struct CategoryTabsBar: View {
    let tagCounts: [String: Int]
    let totalCount: Int
    @Binding var selectedTag: String?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                // "All" tab
                tabButton(label: "All", count: totalCount, isActive: selectedTag == nil) {
                    selectedTag = nil
                }

                // Tag tabs sorted alphabetically
                ForEach(sortedTags, id: \.self) { tag in
                    tabButton(label: tag, count: tagCounts[tag] ?? 0, isActive: selectedTag == tag) {
                        selectedTag = tag
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .frame(height: 36)
        .background(DS.Colors.bgPrimary)
        .overlay(alignment: .bottom) {
            Divider().overlay(DS.Colors.border)
        }
    }

    private var sortedTags: [String] {
        tagCounts.keys.sorted()
    }

    private func tabButton(label: String, count: Int, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(label)
                    .font(DS.Typography.description)
                    .fontWeight(.medium)

                Text("\(count)")
                    .font(DS.Typography.micro)
                    .foregroundStyle(DS.Colors.textMuted)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .foregroundStyle(isActive ? DS.Colors.accent : DS.Colors.textMuted)
            .overlay(alignment: .bottom) {
                if isActive {
                    Rectangle()
                        .fill(DS.Colors.accent)
                        .frame(height: 2)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
