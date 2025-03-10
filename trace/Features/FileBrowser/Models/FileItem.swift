import Foundation

struct FileItem: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let metadata: FileMetadata

    var name: String {
        url.lastPathComponent
    }

    var path: String {
        url.path
    }

    var isDirectory: Bool {
        metadata.isDirectory
    }

    var fileExtension: String? {
        url.pathExtension.isEmpty ? nil : url.pathExtension
    }

    static func == (lhs: FileItem, rhs: FileItem) -> Bool {
        lhs.url == rhs.url
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}

// MARK: - File Type Detection

extension FileItem {
    enum FileType: Equatable {
        case directory
        case markdown
        case other

        var description: String {
            switch self {
            case .directory: return "Folder"
            case .markdown: return "Markdown"
            case .other: return "Other"
            }
        }
    }

    var type: FileType {
        if isDirectory {
            return .directory
        }

        guard let ext = fileExtension?.lowercased() else {
            return .other
        }

        switch ext {
        case "md", "markdown":
            return .markdown
        default:
            return .other
        }
    }

    var isMarkdown: Bool {
        type == .markdown
    }

    var isRelevant: Bool {
        isDirectory || isMarkdown
    }
}

// MARK: - UI Display Properties

extension FileItem {
    var iconSystemName: String {
        switch type {
        case .directory: return "folder"
        case .markdown: return "doc.text"
        case .other: return "doc"
        }
    }

    var displaySize: String {
        isDirectory ? "--" : metadata.formattedSize
    }

    var displayDate: String {
        metadata.formattedModificationDate
    }
}
