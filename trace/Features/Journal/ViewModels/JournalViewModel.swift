import SwiftUI

@Observable
class JournalViewModel {
    var selectedDate: Date? {
        didSet {
            if selectedDate != oldValue {
                loadContent(for: selectedDate)
            }
        }
    }
    var fileContent: String = ""
    var isLoading: Bool = false
    var hasError: Bool = false
    var errorMessage: String?
    
    var isEditing: Bool = false
    var editedContent: String = ""
    
    private let fileService: JournalFileServiceProtocol
    
    init(fileService: JournalFileServiceProtocol = JournalFileService()) {
        self.fileService = fileService
        // Check if folder is selected and open today's entry
        if FolderManager.shared.hasSelectedFolder {
            openTodaysEntry()
        }
    }
    
    // MARK: - Public Methods
    
    // MARK: Formatting
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    func formatDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    // MARK: Editing
    
    func startEditing() {
        editedContent = fileContent
        isEditing = true
    }
    
    func cancelEditing() {
        isEditing = false
        editedContent = ""
    }
    
    func saveEdits() async throws {
        guard let date = selectedDate else {
            return
        }
        
        isLoading = true
        
        do {
            try await fileService.saveEntry(editedContent, for: date)
            fileContent = editedContent
            isLoading = false
            isEditing = false
        } catch {
            handleError(error)
            isEditing = false
            throw error
        }
    }
    
    // MARK: Content Management
    
    func loadContent(for date: Date?) {
        guard let date = date else {
            clearState()
            return
        }
        
        // Make sure a folder is selected
        guard FolderManager.shared.hasSelectedFolder else {
            hasError = true
            errorMessage = "No folder selected. Please select a folder first."
            return
        }
        
        isLoading = true
        hasError = false
        
        Task { @MainActor in
            do {
                if fileService.entryExists(for: date) {
                    fileContent = try await fileService.loadEntry(for: date)
                } else {
                    fileContent = ""
                }
                isLoading = false
            } catch {
                handleError(error)
            }
        }
    }
    
    func createEntry(for date: Date) {
        // Make sure a folder is selected
        guard FolderManager.shared.hasSelectedFolder else {
            hasError = true
            errorMessage = "No folder selected. Please select a folder first."
            return
        }
        
        isLoading = true
        
        Task { @MainActor in
            do {
                let newEntryContent = "# Journal Entry\n\nStart writing your thoughts here..."
                try await fileService.saveEntry(newEntryContent, for: date)
                
                selectedDate = date
                fileContent = newEntryContent
                isLoading = false
            } catch {
                handleError(error)
            }
        }
    }
    
    func openTodaysEntry() {
        // If there's already an entry for today, load it; otherwise, create one
        let today = Date()
        
        if FolderManager.shared.hasSelectedFolder && fileService.entryExists(for: today) {
            selectedDate = today
        } else if FolderManager.shared.hasSelectedFolder {
            createEntry(for: today)
        } else {
            hasError = true
            errorMessage = "No folder selected. Please select a folder first."
        }
    }
    
    func resetFolderSelection() {
        clearState()
        FolderManager.shared.resetFolderSelection()
    }
    
    func handleError(_ error: Error) {
        hasError = true
        errorMessage = error.localizedDescription
        isLoading = false
        
        // Print the error for debugging
        print("Journal error: \(error.localizedDescription)")
    }
    
    // MARK: - Private Methods
    
    private func clearState() {
        selectedDate = nil
        fileContent = ""
        isLoading = false
        hasError = false
        errorMessage = nil
    }
} 
