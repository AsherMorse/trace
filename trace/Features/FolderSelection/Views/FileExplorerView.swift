import SwiftUI
import Observation

struct FileItem: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let isDirectory: Bool
    var children: [FileItem]?
    var isAccessDenied: Bool = false
    var depth: Int = 0
    var containsMarkdownFiles: Bool = false
    
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
    @State private var expandedItemIDs: Set<UUID> = []
    @State private var viewUpdateCounter = 0
    
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
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if item.isDirectory {
                                    toggleDirectory(item)
                                }
                            }
                    }
                }
                .listStyle(SidebarListStyle())
                .id("list_\(viewUpdateCounter)")
                .onAppear {
                    loadRootContents(from: folderURL)
                }
            } else {
                Text("No valid folder selected")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .frame(minWidth: 200, maxHeight: .infinity)
        .onChange(of: viewModel.selectedFolderURL) { oldValue, newValue in
            expandedItemIDs.removeAll()
            if let folderURL = newValue, viewModel.isValidFolder {
                loadRootContents(from: folderURL)
            } else {
                displayItems = []
                forceViewUpdate()
            }
        }
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
        guard let index = displayItems.firstIndex(where: { $0.id == item.id }) else {
            return
        }
        
        let isExpanded = expandedItemIDs.contains(item.id)
        
        if isExpanded {
            expandedItemIDs.remove(item.id)
            removeChildren(of: item, from: &displayItems)
            forceViewUpdate()
        } else {
            expandedItemIDs.insert(item.id)
            
            if let children = displayItems[index].children {
                insertChildren(children, afterParentIndex: index, into: &displayItems, parentDepth: item.depth)
                forceViewUpdate()
            } else {
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
        let indexToCheck = parentIndex + 1
        
        while indexToCheck < items.count {
            if items[indexToCheck].depth > parentDepth {
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
    }
    
    private func loadRootContents(from url: URL) {
        guard viewModel.selectedFolderURL?.startAccessingSecurityScopedResource() == true else {
            return
        }
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: .skipsHiddenFiles
            )
            
            let tempItems = sortURLs(contents).compactMap { url -> FileItem? in
                let isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                let item = FileItem(url: url, isDirectory: isDir, depth: 0)
                
                if item.isMarkdownFile {
                    return item
                } else if isDir {
                    let containsMD = directoryContainsMarkdownFiles(url)
                    if containsMD {
                        var dirItem = item
                        dirItem.containsMarkdownFiles = true
                        return dirItem
                    }
                }
                return nil
            }
            
            displayItems = tempItems
            
            forceViewUpdate()
        } catch {
            displayItems = []
        }
        
        viewModel.selectedFolderURL?.stopAccessingSecurityScopedResource()
    }
    
    private func loadDirectoryContents(for item: FileItem) {
        guard item.isDirectory else { 
            return 
        }
        
        let itemID = item.id
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: item.url,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: .skipsHiddenFiles
            )
            
            let filteredContents = sortURLs(contents).compactMap { url -> FileItem? in
                let isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                var newItem = FileItem(url: url, isDirectory: isDir, depth: item.depth + 1)
                
                if !isDir && url.pathExtension.lowercased() == "md" {
                    return newItem
                } else if isDir {
                    let containsMD = directoryContainsMarkdownFiles(url)
                    if containsMD {
                        newItem.containsMarkdownFiles = true
                        return newItem
                    }
                }
                
                return nil
            }
            
            DispatchQueue.main.async {
                if self.expandedItemIDs.contains(itemID) {
                    guard let itemIndex = self.displayItems.firstIndex(where: { $0.id == itemID }) else {
                        return
                    }
                    
                    var updatedItems = self.displayItems
                    updatedItems[itemIndex].children = filteredContents
                    
                    self.insertChildren(filteredContents, afterParentIndex: itemIndex, into: &updatedItems, parentDepth: item.depth)
                    
                    self.displayItems = updatedItems
                    self.forceViewUpdate()
                }
            }
        } catch {
            DispatchQueue.main.async {
                if self.expandedItemIDs.contains(itemID) {
                    guard let itemIndex = self.displayItems.firstIndex(where: { $0.id == itemID }) else {
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
    
    private func directoryContainsMarkdownFiles(_ directoryURL: URL) -> Bool {
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: directoryURL,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: .skipsHiddenFiles
            )
            
            for url in contents {
                let isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                if !isDir && url.pathExtension.lowercased() == "md" {
                    return true
                }
                
                if isDir && directoryContainsMarkdownFiles(url) {
                    return true
                }
            }
            
            return false
        } catch {
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