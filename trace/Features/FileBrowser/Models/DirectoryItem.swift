import Foundation

final class DirectoryItem: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let name: String
    let path: String

    private(set) var parent: DirectoryItem?
    private(set) var children: [FileItem] = []
    private(set) var isLoaded: Bool = false

    var isExpanded: Bool = false

    init(url: URL, parent: DirectoryItem? = nil) {
        self.url = url
        self.name = url.lastPathComponent
        self.path = url.path
        self.parent = parent
    }

    static func == (lhs: DirectoryItem, rhs: DirectoryItem) -> Bool {
        lhs.url == rhs.url
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}

// MARK: - Children Management

extension DirectoryItem {
    func addChildren(_ items: [FileItem]) {
        children = items
        isLoaded = true
    }

    func clearChildren() {
        children = []
        isLoaded = false
    }

    func childDirectories() -> [DirectoryItem] {
        children
            .filter(\.isDirectory)
            .map { DirectoryItem(url: $0.url, parent: self) }
    }
}

// MARK: - Directory State

extension DirectoryItem {
    var isEmpty: Bool {
        isLoaded && children.isEmpty
    }

    var markdownCount: Int {
        children.filter(\.isMarkdown).count
    }

    var directoryCount: Int {
        children.filter(\.isDirectory).count
    }

    var hasMarkdownFiles: Bool {
        markdownCount > 0
    }
}
