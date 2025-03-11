import SwiftUI

// Simple Calendar Button
struct CalendarButton: View {
    @Binding var showCalendar: Bool
    
    var body: some View {
        Button(action: {
            showCalendar.toggle()
        }) {
            Label("Calendar", systemImage: "calendar")
                .labelStyle(.titleAndIcon)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.regular)
        .help("Toggle calendar view")
    }
}

// Archived legacy version of MainAppView from AppCoordinatorView
struct LegacyMainView: View {
    var folderViewModel: FolderSelectionViewModel
    @State private var showFolderSettings = false
    @State private var selectedFileURL: URL? = nil
    @State private var showNewFileAlert = false
    @State private var newFileName = ""
    @State private var fileExplorerViewModel: FileExplorerViewModel?
    @State private var showDeleteConfirmation = false
    @State private var showRenameAlert = false
    @State private var renameFileName = ""
    @State private var showCalendar = false
    
    var body: some View {
        NavigationSplitView {
            FileExplorerView(
                viewModel: folderViewModel,
                onFileSelected: { url in
                    selectedFileURL = url
                }
            )
            .onViewModelCreated { viewModel in
                fileExplorerViewModel = viewModel
            }
        } detail: {
            VStack(spacing: 0) {
                // Header with buttons
                HStack {
                    Text("Trace Journal")
                        .font(.title)
                        .padding(.vertical)
                    
                    Spacer()
                    
                    Button(action: {
                        showNewFileAlert = true
                        newFileName = "New Entry \(formattedDate()).md"
                    }) {
                        Label("New File", systemImage: "doc.badge.plus")
                    }
                    .padding(.horizontal)
                    .disabled(folderViewModel.selectedFolderURL == nil || !folderViewModel.isValidFolder)
                    
                    if selectedFileURL != nil {
                        Button(action: {
                            if let url = selectedFileURL {
                                renameFileName = url.lastPathComponent
                                showRenameAlert = true
                            }
                        }) {
                            Label("Rename", systemImage: "pencil")
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            Label("Delete", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal)
                    }
                    
                    CalendarButton(showCalendar: $showCalendar)
                        .padding(.horizontal)
                    
                    Button("Change Journal Folder") {
                        showFolderSettings = true
                    }
                    .padding(.horizontal)
                    
                    Button("Reset Folder Selection") {
                        FolderManager.shared.resetFolderSelection()
                        folderViewModel.validateSelectedFolder()
                        selectedFileURL = nil
                    }
                    .foregroundColor(.red)
                }
                .padding(.horizontal)
                
                Divider()
                
                // Content area
                if showCalendar {
                    CalendarView()
                        .padding()
                        .transition(.opacity)
                } else if selectedFileURL != nil {
                    MarkdownContentView(fileURL: selectedFileURL)
                } else {
                    VStack {
                        Text("Journal folder: \(folderViewModel.displayPath)")
                            .font(.callout)
                            .padding()
                        
                        Text("Select a markdown file to view its contents")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .sheet(isPresented: $showFolderSettings) {
                FolderSelectionView(viewModel: folderViewModel)
            }
            .alert("Create New File", isPresented: $showNewFileAlert) {
                TextField("File name", text: $newFileName)
                    .autocorrectionDisabled(true)
                
                Button("Cancel", role: .cancel) {}
                
                Button("Create") {
                    createNewFile()
                }
            } message: {
                Text("Enter a name for the new markdown file")
            }
            .alert("Rename File", isPresented: $showRenameAlert) {
                TextField("File name", text: $renameFileName)
                    .autocorrectionDisabled(true)
                
                Button("Cancel", role: .cancel) {}
                
                Button("Rename") {
                    renameSelectedFile()
                }
            } message: {
                Text("Enter a new name for the file")
            }
            .confirmationDialog(
                "Delete File",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    deleteSelectedFile()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                if let url = selectedFileURL {
                    Text("Are you sure you want to delete '\(url.lastPathComponent)'? This action cannot be undone.")
                } else {
                    Text("No file selected")
                }
            }
        }
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    private func createNewFile() {
        guard let folderURL = folderViewModel.selectedFolderURL,
              folderViewModel.isValidFolder else {
            return
        }
        
        // Ensure the filename has a .md extension
        var fileName = newFileName
        if !fileName.lowercased().hasSuffix(".md") {
            fileName += ".md"
        }
        
        let newFileURL = folderURL.appendingPathComponent(fileName)
        
        do {
            // Create a new empty file
            try "# \(fileName.replacingOccurrences(of: ".md", with: ""))\n\n".write(to: newFileURL, atomically: true, encoding: .utf8)
            
            // Refresh file explorer
            fileExplorerViewModel?.folderDidChange()
            
            // Select the new file
            selectedFileURL = newFileURL
        } catch {
            print("Error creating file: \(error.localizedDescription)")
        }
    }
    
    private func renameSelectedFile() {
        guard let currentURL = selectedFileURL else { return }
        
        // Ensure the filename has a .md extension
        var newName = renameFileName
        if !newName.lowercased().hasSuffix(".md") {
            newName += ".md"
        }
        
        let directoryURL = currentURL.deletingLastPathComponent()
        let newURL = directoryURL.appendingPathComponent(newName)
        
        do {
            try FileManager.default.moveItem(at: currentURL, to: newURL)
            
            // Refresh file explorer
            fileExplorerViewModel?.folderDidChange()
            
            // Update selection to the renamed file
            selectedFileURL = newURL
        } catch {
            print("Error renaming file: \(error.localizedDescription)")
        }
    }
    
    private func deleteSelectedFile() {
        guard let fileURL = selectedFileURL else { return }
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            
            // Refresh file explorer
            fileExplorerViewModel?.folderDidChange()
            
            // Clear selection
            selectedFileURL = nil
        } catch {
            print("Error deleting file: \(error.localizedDescription)")
        }
    }
}

struct LegacyMainView_Previews: PreviewProvider {
    static var previews: some View {
        LegacyMainView(folderViewModel: FolderSelectionViewModel())
    }
} 