import SwiftUI
import Observation
import OSLog

struct FileItem: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let isDirectory: Bool
    var children: [FileItem]?
    var isAccessDenied: Bool = false
    var depth: Int = 0
    var containsMarkdownFiles: Bool = false // Track if this directory contains markdown files
    
    var isMarkdownFile: Bool {
        !isDirectory && url.pathExtension.lowercased() == "md"
    }
    
    static func == (lhs: FileItem, rhs: FileItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct FileExplorerView: View {
    @Bindable var viewModel: FolderSelectionViewModel
    @State private var displayItems: [FileItem] = []
    @State private var expandedItemIDs: Set<UUID> = [] // Central state for tracking expanded items
    @State private var viewUpdateCounter = 0
    private let logger = Logger(subsystem: "com.yourcompany.trace", category: "FileExplorer")
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Markdown Files")
                .font(.headline)
                .padding(.top)
                .padding(.horizontal)
            
            if viewModel.isValidFolder, let folderURL = viewModel.selectedFolderURL {
                List {
                    let _ = self.viewUpdateCounter
                    
                    ForEach(displayItems) { item in
                        singleFileRow(item)
                            .contentShape(Rectangle()) // Ensure the entire row is clickable
                            .onTapGesture {
                                if item.isDirectory {
                                    toggleDirectory(item)
                                }
                            }
                    }
                }
                .listStyle(SidebarListStyle()) // Use sidebar style for better visual feedback
                .id("list_\(viewUpdateCounter)")
                .onAppear {
                    logger.info("Loading root contents from \(folderURL.path)")
                    loadRootContents(from: folderURL)
                }
            } else {
                Text("No valid folder selected")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .frame(minWidth: 200, maxHeight: .infinity)
    }
    
    private func singleFileRow(_ item: FileItem) -> some View {
        Group {
            if item.isDirectory {
                HStack {
                    Image(systemName: expandedItemIDs.contains(item.id) ? "chevron.down" : "chevron.right")
                        .frame(width: 12)
                    
                    Image(systemName: item.isAccessDenied ? "folder.badge.questionmark" : "folder")
                        .foregroundColor(item.isAccessDenied ? .orange : .primary)
                    
                    Text(item.url.lastPathComponent)
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.leading, CGFloat(item.depth * 16))
            } else {
                HStack {
                    Image(systemName: "doc.text")
                        .frame(width: 12)
                    Text(item.url.lastPathComponent)
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.leading, CGFloat(item.depth * 16 + 12))
            }
        }
    }
    
    private func toggleDirectory(_ item: FileItem) {
        logger.info("Toggling directory: \(item.url.lastPathComponent)")
        
        guard let index = displayItems.firstIndex(where: { $0.id == item.id }) else {
            logger.warning("Could not find item to toggle: \(item.url.lastPathComponent)")
            return
        }
        
        let isExpanded = expandedItemIDs.contains(item.id)
        
        if isExpanded {
            logger.info("Collapsing directory: \(item.url.lastPathComponent)")
            expandedItemIDs.remove(item.id)
            removeChildren(of: item, from: &displayItems)
            forceViewUpdate()
        } else {
            logger.info("Expanding directory: \(item.url.lastPathComponent)")
            expandedItemIDs.insert(item.id)
            
            if let children = displayItems[index].children {
                logger.info("Using existing \(children.count) children for \(item.url.lastPathComponent)")
                insertChildren(children, afterParentIndex: index, into: &displayItems, parentDepth: item.depth)
                forceViewUpdate()
            } else {
                // We need to load children
                // Don't remove the expanded state during async operation
                forceViewUpdate()
                loadDirectoryContents(for: item)
            }
        }
    }
    
    private func insertChildren(_ children: [FileItem], afterParentIndex parentIndex: Int, into items: inout [FileItem], parentDepth: Int) {
        var childrenToInsert: [FileItem] = []
        
        for var child in children {
            child.depth = parentDepth + 1
            childrenToInsert.append(child)
        }
        
        items.insert(contentsOf: childrenToInsert, at: parentIndex + 1)
    }
    
    private func removeChildren(of parent: FileItem, from items: inout [FileItem]) {
        guard let parentIndex = items.firstIndex(where: { $0.id == parent.id }) else { return }
        
        let parentDepth = parent.depth
        var indexToCheck = parentIndex + 1
        
        while indexToCheck < items.count {
            if items[indexToCheck].depth > parentDepth {
                // Also remove from expanded IDs if it's a directory
                if items[indexToCheck].isDirectory {
                    expandedItemIDs.remove(items[indexToCheck].id)
                }
                items.remove(at: indexToCheck)
            } else {
                break
            }
        }
    }
    
    private func forceViewUpdate() {
        viewUpdateCounter += 1
        logger.info("Forcing view update with counter: \(viewUpdateCounter)")
    }
    
    private func loadRootContents(from url: URL) {
        guard viewModel.selectedFolderURL?.startAccessingSecurityScopedResource() == true else {
            logger.error("Cannot access root folder with security scope")
            return
        }
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: .skipsHiddenFiles
            )
            
            logger.info("Successfully loaded root directory with \(contents.count) items")
            
            // First check which directories contain markdown files
            var tempItems = sortURLs(contents).compactMap { url -> FileItem? in
                let isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                let item = FileItem(url: url, isDirectory: isDir, depth: 0)
                
                if item.isMarkdownFile {
                    // If this is a markdown file, include it
                    return item
                } else if isDir {
                    // For directories, check if they contain markdown files
                    let containsMD = directoryContainsMarkdownFiles(url)
                    if containsMD {
                        var dirItem = item
                        dirItem.containsMarkdownFiles = true
                        return dirItem
                    }
                }
                return nil // Skip non-markdown files and directories without markdown
            }
            
            logger.info("Filtered to \(tempItems.count) markdown-related items")
            displayItems = tempItems
            
            forceViewUpdate()
        } catch {
            logger.error("Failed to load root directory: \(error.localizedDescription)")
            displayItems = []
        }
        
        viewModel.selectedFolderURL?.stopAccessingSecurityScopedResource()
    }
    
    private func loadDirectoryContents(for item: FileItem) {
        guard item.isDirectory else { 
            logger.info("Skipping directory load: Not a directory")
            return 
        }
        
        logger.info("Loading contents for directory: \(item.url.lastPathComponent)")
        
        // Store the item ID we're currently loading
        let itemID = item.id
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: item.url,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: .skipsHiddenFiles
            )
            
            // Filter for markdown files and relevant directories
            let filteredContents = sortURLs(contents).compactMap { url -> FileItem? in
                let isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                var newItem = FileItem(url: url, isDirectory: isDir, depth: item.depth + 1)
                
                if !isDir && url.pathExtension.lowercased() == "md" {
                    // Keep markdown files
                    return newItem
                } else if isDir {
                    // Check if the directory contains any markdown files
                    let containsMD = directoryContainsMarkdownFiles(url)
                    if containsMD {
                        newItem.containsMarkdownFiles = true
                        return newItem
                    }
                }
                
                return nil // Skip non-markdown files and directories without markdown
            }
            
            logger.info("Directory \(item.url.lastPathComponent) filtered to \(filteredContents.count) markdown-related items")
            
            // Use DispatchQueue.main.async to ensure UI updates happen on the main thread
            DispatchQueue.main.async {
                // Check if the directory is still expanded before updating UI
                if self.expandedItemIDs.contains(itemID) {
                    guard let itemIndex = self.displayItems.firstIndex(where: { $0.id == itemID }) else {
                        self.logger.warning("Could not find item to update: \(item.url.lastPathComponent)")
                        return
                    }
                    
                    for (index, child) in filteredContents.enumerated() {
                        self.logger.info("  Child \(index + 1): \(child.url.lastPathComponent) (\(child.isDirectory ? "directory" : "file"))")
                    }
                    
                    var updatedItems = self.displayItems
                    updatedItems[itemIndex].children = filteredContents
                    
                    self.insertChildren(filteredContents, afterParentIndex: itemIndex, into: &updatedItems, parentDepth: item.depth)
                    
                    self.displayItems = updatedItems
                    self.forceViewUpdate()
                } else {
                    self.logger.info("Directory no longer expanded, skipping UI update for: \(item.url.lastPathComponent)")
                }
            }
        } catch {
            logger.warning("Failed to load directory \(item.url.lastPathComponent): \(error.localizedDescription)")
            
            // Use DispatchQueue.main.async to ensure UI updates happen on the main thread
            DispatchQueue.main.async {
                // Check if the directory is still expanded before updating UI
                if self.expandedItemIDs.contains(itemID) {
                    guard let itemIndex = self.displayItems.firstIndex(where: { $0.id == itemID }) else {
                        self.logger.warning("Could not find item to update: \(item.url.lastPathComponent)")
                        return
                    }
                    
                    var updatedItems = self.displayItems
                    updatedItems[itemIndex].isAccessDenied = true
                    updatedItems[itemIndex].children = []
                    
                    self.displayItems = updatedItems
                    self.forceViewUpdate()
                }
            }
        }
    }
    
    // Helper function to check if a directory contains any markdown files
    private func directoryContainsMarkdownFiles(_ directoryURL: URL) -> Bool {
        do {
            // First check direct child files
            let contents = try FileManager.default.contentsOfDirectory(
                at: directoryURL,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: .skipsHiddenFiles
            )
            
            // Check for any markdown files in this directory
            for url in contents {
                let isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                if !isDir && url.pathExtension.lowercased() == "md" {
                    return true
                }
                
                // Recursively check subdirectories
                if isDir {
                    if directoryContainsMarkdownFiles(url) {
                        return true
                    }
                }
            }
            
            return false
        } catch {
            // In case of error, don't show the directory
            return false
        }
    }
    
    private func sortURLs(_ urls: [URL]) -> [URL] {
        return urls.sorted { url1, url2 in
            let isDir1 = (try? url1.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
            let isDir2 = (try? url2.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
            
            if isDir1 && !isDir2 {
                return true
            } else if !isDir1 && isDir2 {
                return false
            } else {
                return url1.lastPathComponent.localizedCaseInsensitiveCompare(url2.lastPathComponent) == .orderedAscending
            }
        }
    }
}

struct FileExplorerView_Previews: PreviewProvider {
    static var previews: some View {
        FileExplorerView(viewModel: FolderSelectionViewModel())
    }
} 