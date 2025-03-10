import SwiftUI

@Observable
final class FileTreeViewModel {
    private let fileManager: FileManager

    private(set) var rootDirectory: DirectoryItem?
    private(set) var currentDirectory: DirectoryItem?
    private(set) var isLoading: Bool = false
    private(set) var error: Error?

    var showNonMarkdownFiles: Bool = false

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
}

// MARK: - Directory Management

extension FileTreeViewModel {
    func setRootDirectory(_ url: URL) {
        let rootDir = DirectoryItem(url: url)
        self.rootDirectory = rootDir
        self.currentDirectory = rootDir
        loadDirectoryContents(for: rootDir)
    }

    func loadDirectoryContents(for directory: DirectoryItem) {
        guard !directory.isLoaded else { return }

        isLoading = true
        error = nil

        Task { @MainActor in
            do {
                let items = try await loadFileItems(from: directory.url)
                directory.addChildren(items)
                isLoading = false
            } catch {
                self.error = error
                isLoading = false
            }
        }
    }

    private func loadFileItems(from url: URL) async throws -> [FileItem] {
        let contents = try fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [
                .isDirectoryKey,
                .contentModificationDateKey,
                .creationDateKey,
                .fileSizeKey
            ],
            options: [.skipsHiddenFiles]
        )

        return contents.compactMap { url -> FileItem? in
            do {
                let resourceValues = try url.resourceValues(forKeys: [
                    .isDirectoryKey,
                    .contentModificationDateKey,
                    .creationDateKey,
                    .fileSizeKey
                ])

                let metadata = FileMetadata(
                    creationDate: resourceValues.creationDate,
                    modificationDate: resourceValues.contentModificationDate,
                    size: resourceValues.fileSize ?? 0,
                    isDirectory: resourceValues.isDirectory ?? false
                )

                return FileItem(url: url, metadata: metadata)
            } catch {
                print("Error reading file attributes for \(url.path): \(error)")
                return nil
            }
        }
    }
}

// MARK: - Navigation

extension FileTreeViewModel {
    func navigateToDirectory(_ directory: DirectoryItem) {
        if !directory.isLoaded {
            loadDirectoryContents(for: directory)
        }
        currentDirectory = directory
    }

    func navigateUp() {
        guard let parent = currentDirectory?.parent else { return }
        currentDirectory = parent
    }
}

// MARK: - Content Filtering

extension FileTreeViewModel {
    var currentDirectoryContents: [FileItem] {
        guard let directory = currentDirectory else { return [] }
        return showNonMarkdownFiles ? directory.children : directory.children.filter(\.isRelevant)
    }

    var markdownFilesInCurrentDirectory: [FileItem] {
        currentDirectoryContents.filter(\.isMarkdown)
    }

    var directoriesInCurrentDirectory: [FileItem] {
        currentDirectoryContents.filter(\.isDirectory)
    }
}
