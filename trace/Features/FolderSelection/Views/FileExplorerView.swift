import SwiftUI
import Observation
import OSLog

struct FileItem: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let isDirectory: Bool
    var isExpanded: Bool = false  // Now part of the item itself
    var children: [FileItem]?
    var isAccessDenied: Bool = false
    var depth: Int = 0  // Track the depth of each item for indentation
    
    static func == (lhs: FileItem, rhs: FileItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct FileExplorerView: View {
    @Bindable var viewModel: FolderSelectionViewModel
    // Use a flat list instead of a hierarchical structure
    @State private var displayItems: [FileItem] = []
    @State private var viewUpdateCounter = 0
    private let logger = Logger(subsystem: "com.yourcompany.trace", category: "FileExplorer")
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Files")
                .font(.headline)
                .padding(.top)
                .padding(.horizontal)
            
            if viewModel.isValidFolder, let folderURL = viewModel.selectedFolderURL {
                List {
                    let _ = self.viewUpdateCounter // Force refresh when counter changes
                    
                    ForEach(displayItems) { item in
                        singleFileRow(item)
                    }
                }
                .id("list_\(viewUpdateCounter)") // Force entire list to refresh
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
                Button(action: {
                    logger.info("Toggling directory: \(item.url.lastPathComponent)")
                    toggleDirectory(item)
                }) {
                    HStack {
                        Image(systemName: item.isExpanded ? "chevron.down" : "chevron.right")
                            .frame(width: 12)
                        
                        Image(systemName: item.isAccessDenied ? "folder.badge.questionmark" : "folder")
                            .foregroundColor(item.isAccessDenied ? .orange : .primary)
                        
                        Text(item.url.lastPathComponent)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(.leading, CGFloat(item.depth * 16))
                }
                .buttonStyle(.plain)
            } else {
                HStack {
                    Image(systemName: "doc")
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
        // Find the item in the flat list
        guard let index = displayItems.firstIndex(where: { $0.id == item.id }) else {
            logger.warning("Could not find item to toggle: \(item.url.lastPathComponent)")
            return
        }
        
        var updatedItems = displayItems
        let currentExpanded = updatedItems[index].isExpanded
        
        if currentExpanded {
            // Collapse: remove all children from the display list
            logger.info("Collapsing directory: \(item.url.lastPathComponent)")
            updatedItems[index].isExpanded = false
            
            // Remove all items that are children of this item
            removeChildren(of: item, from: &updatedItems)
        } else {
            // Expand: add children to the display list
            logger.info("Expanding directory: \(item.url.lastPathComponent)")
            updatedItems[index].isExpanded = true
            
            if let children = updatedItems[index].children {
                // We already have children, just add them to the display
                logger.info("Using existing \(children.count) children for \(item.url.lastPathComponent)")
                insertChildren(children, afterParentIndex: index, into: &updatedItems, parentDepth: item.depth)
            } else {
                // Mark as loading by setting an empty array
                updatedItems[index].children = []
                displayItems = updatedItems
                forceViewUpdate()
                
                // Load the directory contents
                loadDirectoryContents(for: item)
                return
            }
        }
        
        // Update the display items
        displayItems = updatedItems
        forceViewUpdate()
    }
    
    private func insertChildren(_ children: [FileItem], afterParentIndex parentIndex: Int, into items: inout [FileItem], parentDepth: Int) {
        // Create copies of the children with updated depth
        var childrenToInsert: [FileItem] = []
        
        for var child in children {
            child.depth = parentDepth + 1
            childrenToInsert.append(child)
        }
        
        // Insert all children after the parent
        items.insert(contentsOf: childrenToInsert, at: parentIndex + 1)
    }
    
    private func removeChildren(of parent: FileItem, from items: inout [FileItem]) {
        // Find all indices that are children of this parent (based on depth and position)
        guard let parentIndex = items.firstIndex(where: { $0.id == parent.id }) else { return }
        
        let parentDepth = parent.depth
        var indexToCheck = parentIndex + 1
        
        while indexToCheck < items.count {
            if items[indexToCheck].depth > parentDepth {
                // This is a child or nested child, remove it
                items.remove(at: indexToCheck)
            } else {
                // We've reached the end of this parent's children
                break
            }
        }
    }
    
    private func forceViewUpdate() {
        viewUpdateCounter += 1
        logger.info("Forcing view update with counter: \(viewUpdateCounter)")
    }
    
    private func loadRootContents(from url: URL) {
        // Make sure we have access to the root folder
        guard viewModel.selectedFolderURL?.startAccessingSecurityScopedResource() == true else {
            logger.error("Cannot access root folder with security scope")
            return
        }
        
        do {
            // Try to read directory contents directly
            let contents = try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: .skipsHiddenFiles
            )
            
            logger.info("Successfully loaded root directory with \(contents.count) items")
            let sortedContents = sortURLs(contents)
            displayItems = sortedContents.map { url in
                let isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                return FileItem(url: url, isDirectory: isDir, depth: 0)
            }
            
            forceViewUpdate()
        } catch {
            logger.error("Failed to load root directory: \(error.localizedDescription)")
            displayItems = []
        }
        
        // Release the security-scoped resource access when we're done with the initial load
        viewModel.selectedFolderURL?.stopAccessingSecurityScopedResource()
    }
    
    private func loadDirectoryContents(for item: FileItem) {
        guard item.isDirectory else { 
            logger.info("Skipping directory load: Not a directory")
            return 
        }
        
        logger.info("Loading contents for directory: \(item.url.lastPathComponent)")
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: item.url,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: .skipsHiddenFiles
            )
            
            logger.info("Directory \(item.url.lastPathComponent) loaded with \(contents.count) items")
            let sortedContents = sortURLs(contents)
            let children = sortedContents.map { url in
                let isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                return FileItem(url: url, isDirectory: isDir, depth: item.depth + 1)
            }
            
            // Find the item index in the display items
            guard let itemIndex = displayItems.firstIndex(where: { $0.id == item.id }) else {
                logger.warning("Could not find item to update: \(item.url.lastPathComponent)")
                return
            }
            
            // Log children that will be inserted
            for (index, child) in children.enumerated() {
                logger.info("  Child \(index + 1): \(child.url.lastPathComponent) (\(child.isDirectory ? "directory" : "file"))")
            }
            
            // Update the item with its children
            var updatedItems = displayItems
            updatedItems[itemIndex].children = children
            
            // Insert the children into the flat list
            insertChildren(children, afterParentIndex: itemIndex, into: &updatedItems, parentDepth: item.depth)
            
            // Update the display items
            displayItems = updatedItems
            forceViewUpdate()
        } catch {
            logger.warning("Failed to load directory \(item.url.lastPathComponent): \(error.localizedDescription)")
            
            // Find the item index in the display items
            guard let itemIndex = displayItems.firstIndex(where: { $0.id == item.id }) else {
                logger.warning("Could not find item to update: \(item.url.lastPathComponent)")
                return
            }
            
            // Mark the directory as access denied
            var updatedItems = displayItems
            updatedItems[itemIndex].isAccessDenied = true
            updatedItems[itemIndex].children = []
            
            // Update the display items
            displayItems = updatedItems
            forceViewUpdate()
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