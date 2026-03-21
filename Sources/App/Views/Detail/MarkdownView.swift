import SwiftUI
import Markdown

/// Renders markdown content as styled SwiftUI views
struct MarkdownView: View {
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            let document = Document(parsing: content)
            MarkdownRenderer(document: document)
        }
    }
}

/// Renders a Markdown document as SwiftUI views
struct MarkdownRenderer: View {
    let document: Document

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            ForEach(Array(document.children.enumerated()), id: \.offset) { _, child in
                renderBlock(child)
            }
        }
    }

    @ViewBuilder
    private func renderBlock(_ markup: Markup) -> some View {
        switch markup {
        case let heading as Heading:
            HeadingView(heading: heading)

        case let paragraph as Paragraph:
            ParagraphView(paragraph: paragraph)

        case let codeBlock as CodeBlock:
            CodeBlockView(codeBlock: codeBlock)

        case let list as UnorderedList:
            UnorderedListView(list: list)

        case let list as OrderedList:
            OrderedListView(list: list)

        case let blockQuote as BlockQuote:
            BlockQuoteView(blockQuote: blockQuote)

        case _ as ThematicBreak:
            Rectangle()
                .fill(DS.Colors.border)
                .frame(height: 1)
                .padding(.vertical, DS.Spacing.md)

        case let htmlBlock as HTMLBlock:
            Text(htmlBlock.rawHTML)
                .font(DS.Typography.mono)
                .foregroundStyle(DS.Colors.textSecondary)

        default:
            Text(markup.format())
                .font(DS.Typography.body)
        }
    }
}

// MARK: - Block Views

private struct HeadingView: View {
    let heading: Heading

    var body: some View {
        Text(heading.plainText)
            .font(fontForLevel(heading.level))
            .fontWeight(.semibold)
            .foregroundStyle(DS.Colors.textPrimary)
            .padding(.top, topPadding)
            .padding(.bottom, DS.Spacing.xs)
    }

    private func fontForLevel(_ level: Int) -> Font {
        switch level {
        case 1: return .system(size: 20, weight: .bold)
        case 2: return .system(size: 16, weight: .semibold)
        case 3: return .system(size: 14, weight: .semibold)
        default: return .system(size: 13, weight: .semibold)
        }
    }

    private var topPadding: CGFloat {
        switch heading.level {
        case 1: return DS.Spacing.sm
        case 2: return DS.Spacing.xl
        default: return DS.Spacing.md
        }
    }
}

private struct ParagraphView: View {
    let paragraph: Paragraph

    var body: some View {
        Text(attributedString(for: paragraph))
            .font(DS.Typography.body)
            .lineSpacing(5)
            .foregroundStyle(DS.Colors.textSecondary)
    }

    private func attributedString(for paragraph: Paragraph) -> AttributedString {
        var result = AttributedString()
        for child in paragraph.children {
            result.append(renderInline(child))
        }
        return result
    }

    private func renderInline(_ markup: Markup) -> AttributedString {
        switch markup {
        case let text as Markdown.Text:
            return AttributedString(text.string)

        case let strong as Strong:
            var attr = AttributedString(strong.plainText)
            attr.font = .system(size: 13, weight: .semibold)
            attr.foregroundColor = Color(hex: 0xF1F5F9)
            return attr

        case let emphasis as Emphasis:
            var attr = AttributedString(emphasis.plainText)
            attr.font = .system(size: 13).italic()
            return attr

        case let code as InlineCode:
            var attr = AttributedString(code.code)
            attr.font = .system(size: 12, design: .monospaced)
            attr.foregroundColor = Color(hex: 0x3B82F6)
            attr.backgroundColor = Color(hex: 0x3B82F6).opacity(0.1)
            return attr

        case let link as Markdown.Link:
            var attr = AttributedString(link.plainText)
            attr.foregroundColor = Color(hex: 0x3B82F6)
            attr.underlineStyle = .single
            if let url = link.destination {
                attr.link = URL(string: url)
            }
            return attr

        case _ as SoftBreak:
            return AttributedString(" ")

        case _ as LineBreak:
            return AttributedString("\n")

        default:
            return AttributedString(markup.format())
        }
    }
}

private struct CodeBlockView: View {
    let codeBlock: CodeBlock

    @State private var isHovering = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let language = codeBlock.language, !language.isEmpty {
                HStack {
                    Text(language.uppercased())
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(DS.Colors.textMuted)
                    Spacer()

                    if isHovering {
                        Button {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(codeBlock.code, forType: .string)
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(DS.Colors.textMuted)
                        }
                        .buttonStyle(.plain)
                        .transition(.opacity)
                    }
                }
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.top, DS.Spacing.md)
                .padding(.bottom, DS.Spacing.xs)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                Text(codeBlock.code.trimmingCharacters(in: .whitespacesAndNewlines))
                    .font(DS.Typography.mono)
                    .foregroundStyle(DS.Colors.textPrimary)
                    .textSelection(.enabled)
                    .padding(.horizontal, DS.Spacing.lg)
                    .padding(.vertical, DS.Spacing.lg)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DS.Colors.bgInput)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.sm)
                .stroke(DS.Colors.border, lineWidth: 1)
        )
        .onHover { hovering in
            withAnimation(DS.Animation.quick) {
                isHovering = hovering
            }
        }
    }
}

private struct UnorderedListView: View {
    let list: UnorderedList

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            ForEach(Array(list.children.enumerated()), id: \.offset) { _, item in
                if let listItem = item as? ListItem {
                    HStack(alignment: .top, spacing: DS.Spacing.md) {
                        Circle()
                            .fill(DS.Colors.textMuted)
                            .frame(width: 5, height: 5)
                            .padding(.top, 6)

                        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                            ForEach(Array(listItem.children.enumerated()), id: \.offset) { _, child in
                                if let para = child as? Paragraph {
                                    ParagraphView(paragraph: para)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.leading, DS.Spacing.md)
    }
}

private struct OrderedListView: View {
    let list: OrderedList

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            ForEach(Array(list.children.enumerated()), id: \.offset) { index, item in
                if let listItem = item as? ListItem {
                    HStack(alignment: .top, spacing: DS.Spacing.md) {
                        Text("\(index + 1).")
                            .font(DS.Typography.body)
                            .foregroundStyle(DS.Colors.textSecondary)
                            .frame(width: 20, alignment: .trailing)

                        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                            ForEach(Array(listItem.children.enumerated()), id: \.offset) { _, child in
                                if let para = child as? Paragraph {
                                    ParagraphView(paragraph: para)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(.leading, DS.Spacing.md)
    }
}

private struct BlockQuoteView: View {
    let blockQuote: BlockQuote

    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(DS.Colors.accent.opacity(0.6))
                .frame(width: 3)

            VStack(alignment: .leading, spacing: DS.Spacing.md) {
                ForEach(Array(blockQuote.children.enumerated()), id: \.offset) { _, child in
                    if let para = child as? Paragraph {
                        ParagraphView(paragraph: para)
                    }
                }
            }
            .padding(.leading, DS.Spacing.lg)
        }
        .padding(.vertical, DS.Spacing.xs)
    }
}

// MARK: - Helper Extensions

extension Markup {
    var plainText: String {
        var result = ""
        for child in children {
            if let text = child as? Markdown.Text {
                result += text.string
            } else {
                result += child.plainText
            }
        }
        return result
    }
}
