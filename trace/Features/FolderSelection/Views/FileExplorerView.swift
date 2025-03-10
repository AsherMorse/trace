import SwiftUI
import Observation

// MARK: - trace/Features/FolderSelection/Models/FileItem.swift

struct FileItem: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let isDirectory: Bool
    var children: [FileItem]?
    var isAccessDenied = false
    var depth = 0
    
    var isMarkdownFile: Bool {
        !isDirectory && url.pathExtension.lowercased() == "md"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - trace/Core/Services/FileBrowserService.swift
// Handles file system operations with performance optimizations via caching

@Observable
fileprivate class FileBrowser {
    private let fileManager = FileManager.default
    // Cache to avoid expensive repeated filesystem checks
    private static var markdownDirectoryCache = [String: Bool]()
    
    func loadContents(of url: URL, depth: Int = 0) -> [FileItem] {
        do {
            let contents = try fileManager.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: .skipsHiddenFiles
            )
            
            return sortedContents(contents).compactMap { fileURL in
                let isDir = (try? fileURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                
                if !isDir && fileURL.pathExtension.lowercased() == "md" {
                    return FileItem(url: fileURL, isDirectory: false, depth: depth)
                } else if isDir && directoryContainsMarkdownFiles(fileURL) {
                    return FileItem(url: fileURL, isDirectory: true, depth: depth)
                }
                return nil
            }
        } catch {
            return []
        }
    }
    
    private func directoryContainsMarkdownFiles(_ directoryURL: URL) -> Bool {
        let pathKey = directoryURL.path
        
        // Return cached result if available to avoid expensive directory traversal
        if let cachedResult = FileBrowser.markdownDirectoryCache[pathKey] {
            return cachedResult
        }
        
        var hasMarkdownFiles = false
        var childrenToProcess = [URL]()
        
        do {
            let contents = try fileManager.contentsOfDirectory(
                at: directoryURL,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: .skipsHiddenFiles
            )
            
            for url in contents {
                let isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                
                if !isDir && url.pathExtension.lowercased() == "md" {
                    hasMarkdownFiles = true
                    break
                } else if isDir {
                    // Check cache first before adding to processing queue
                    if let cachedChildResult = FileBrowser.markdownDirectoryCache[url.path] {
                        if cachedChildResult {
                            hasMarkdownFiles = true
                            break
                        }
                    } else {
                        childrenToProcess.append(url)
                    }
                }
            }
            
            // If we haven't found markdown files yet, check child directories
            if !hasMarkdownFiles {
                for childURL in childrenToProcess {
                    if directoryContainsMarkdownFiles(childURL) {
                        hasMarkdownFiles = true
                        break
                    }
                }
            }
        } catch { /* Ignore access errors as we'll just skip inaccessible directories */ }
        
        // Cache the result to avoid redundant filesystem checks
        FileBrowser.markdownDirectoryCache[pathKey] = hasMarkdownFiles
        
        return hasMarkdownFiles
    }
    
    private func sortedContents(_ urls: [URL]) -> [URL] {
        urls.sorted { url1, url2 in
            let isDir1 = (try? url1.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
            let isDir2 = (try? url2.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
            
            // Folders always come before files
            if isDir1 != isDir2 {
                return isDir1
            }
            return url1.lastPathComponent.localizedCaseInsensitiveCompare(url2.lastPathComponent) == .orderedAscending
        }
    }
}

// MARK: - trace/Features/FolderSelection/ViewModels/FileExplorerViewModel.swift

@Observable
class FileExplorerViewModel {
    // State
    private(set) var items = [FileItem]()
    private(set) var expandedItemIDs = Set<UUID>()
    var updateCounter = 0
    
    // Dependencies
    private let folderViewModel: FolderSelectionViewModel
    private let fileBrowser = FileBrowser()
    
    init(folderViewModel: FolderSelectionViewModel) {
        self.folderViewModel = folderViewModel
    }
    
    // MARK: - Public Interface
    
    var selectedFolderURL: URL? {
        folderViewModel.selectedFolderURL
    }
    
    var isValidFolder: Bool {
        folderViewModel.isValidFolder
    }
    
    func folderDidChange() {
        expandedItemIDs.removeAll()
        
        if let folderURL = selectedFolderURL, isValidFolder {
            loadRootContents(from: folderURL)
        } else {
            items = []
            refresh()
        }
    }
    
    func toggleDirectory(_ item: FileItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        
        if expandedItemIDs.contains(item.id) {
            expandedItemIDs.remove(item.id)
            removeChildren(of: item)
        } else {
            expandedItemIDs.insert(item.id)
            
            if let children = items[index].children {
                // Use cached children if available for better performance
                insertChildren(children, afterParentIndex: index, parentDepth: item.depth)
            } else {
                loadDirectoryContents(for: item)
            }
        }
    }
    
    func loadInitialContents() {
        if let folderURL = selectedFolderURL, isValidFolder {
            loadRootContents(from: folderURL)
        }
    }
    
    // MARK: - Private Implementation
    
    private func insertChildren(_ children: [FileItem], afterParentIndex parentIndex: Int, parentDepth: Int) {
        let childrenToInsert = children.map { child -> FileItem in
            var newChild = child
            newChild.depth = parentDepth + 1
            return newChild
        }
        
        items.insert(contentsOf: childrenToInsert, at: parentIndex + 1)
        refresh()
    }
    
    private func removeChildren(of parent: FileItem) {
        guard let parentIndex = items.firstIndex(where: { $0.id == parent.id }) else { return }
        
        let parentDepth = parent.depth
        var index = parentIndex + 1
        
        while index < items.count {
            let item = items[index]
            if item.depth > parentDepth {
                if item.isDirectory {
                    expandedItemIDs.remove(item.id)
                }
                items.remove(at: index)
                // Index stays the same as we removed an item
            } else {
                break
            }
        }
        
        refresh()
    }
    
    private func loadRootContents(from url: URL) {
        withSecurityAccess {
            items = fileBrowser.loadContents(of: url)
            refresh()
        }
    }
    
    private func loadDirectoryContents(for item: FileItem) {
        guard item.isDirectory else { return }
        
        let itemID = item.id
        let children = fileBrowser.loadContents(of: item.url, depth: item.depth + 1)
        
        Task { @MainActor in
            guard expandedItemIDs.contains(itemID),
                  let itemIndex = items.firstIndex(where: { $0.id == itemID }) else { return }
            
            // Check for access denial to show the appropriate UI indicators
            if children.isEmpty {
                do {
                    let _ = try FileManager.default.contentsOfDirectory(at: item.url, includingPropertiesForKeys: nil)
                } catch {
                    items[itemIndex].isAccessDenied = true
                }
            }
            
            items[itemIndex].children = children
            insertChildren(children, afterParentIndex: itemIndex, parentDepth: item.depth)
        }
    }
    
    // Force view to redraw when content changes
    private func refresh() {
        updateCounter += 1
    }
    
    // Security-scoped resources need explicit access management
    private func withSecurityAccess(perform action: () -> Void) {
        guard selectedFolderURL?.startAccessingSecurityScopedResource() == true else { return }
        defer { selectedFolderURL?.stopAccessingSecurityScopedResource() }
        action()
    }
}

// MARK: - trace/Features/FolderSelection/Views/FileExplorerView.swift

struct FileExplorerView: View {
    @State private var viewModel: FileExplorerViewModel
    
    init(viewModel: FolderSelectionViewModel) {
        // Initialize our view model with the folder selection view model
        self._viewModel = State(initialValue: FileExplorerViewModel(folderViewModel: viewModel))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Markdown Files")
                .font(.headline)
                .padding(.top)
                .padding(.horizontal)
            
            fileList
        }
        .frame(minWidth: 200, maxHeight: .infinity)
        .onChange(of: viewModel.selectedFolderURL) { _, _ in
            viewModel.folderDidChange()
        }
    }
    
    @ViewBuilder
    private var fileList: some View {
        if viewModel.isValidFolder, viewModel.selectedFolderURL != nil {
            List {
                let _ = viewModel.updateCounter // Force view update when counter changes
                
                ForEach(viewModel.items) { item in
                    fileRow(for: item)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if item.isDirectory {
                                viewModel.toggleDirectory(item)
                            }
                        }
                }
            }
            .listStyle(SidebarListStyle())
            .id("file_list_\(viewModel.updateCounter)")
            .task { viewModel.loadInitialContents() }
        } else {
            Text("No valid folder selected")
                .foregroundColor(.secondary)
                .padding()
        }
    }
    
    private func fileRow(for item: FileItem) -> some View {
        HStack {
            if item.isDirectory {
                Image(systemName: viewModel.expandedItemIDs.contains(item.id) ? "chevron.down" : "chevron.right")
                    .frame(width: 12)
                
                Image(systemName: item.isAccessDenied ? "folder.badge.questionmark" : "folder")
                    .foregroundColor(item.isAccessDenied ? .orange : .primary)
            } else {
                Image(systemName: "doc.text")
                    .frame(width: 12)
            }
            
            Text(item.url.lastPathComponent)
                .lineLimit(1)
            
            Spacer()
        }
        .padding(.leading, item.isDirectory ? CGFloat(item.depth * 16) : CGFloat(item.depth * 16 + 12))
    }
}

// MARK: - Previews

struct FileExplorerView_Previews: PreviewProvider {
    static var previews: some View {
        FileExplorerView(viewModel: FolderSelectionViewModel())
    }
} 
