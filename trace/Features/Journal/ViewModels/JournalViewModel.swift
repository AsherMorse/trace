import SwiftUI

@Observable
final class JournalViewModel {
    // Core data properties
    var selectedDate: Date?
    var currentEntry: JournalEntry?
    var editedContent: String = ""
    var fileContent: String = ""
    var isDirty: Bool = false
    
    // UI state
    var isLoading: Bool = false
    var hasError: Bool = false
    var errorMessage: String?
    
    // Services
    private let fileService: JournalFileServiceProtocol
    private let storageManager: JournalStorageManagerProtocol
    
    // Auto-save functionality
    private var autoSaveTimer: Timer?
    private let autoSaveInterval: TimeInterval = 30
    
    init(
        fileService: JournalFileServiceProtocol = JournalFileService(),
        storageManager: JournalStorageManagerProtocol = JournalStorageManager()
    ) {
        self.fileService = fileService
        self.storageManager = storageManager
        
        if FolderManager.shared.hasSelectedFolder {
            openTodaysEntry()
        }
    }
    
    deinit {
        stopAutoSaveTimer()
    }
    
    // MARK: - Entry Management
    
    func updateEntrySection(_ updatedEntry: JournalEntry) {
        currentEntry = updatedEntry
        editedContent = updatedEntry.toMarkdown()
        isDirty = editedContent != fileContent
    }
    
    func reset() {
        selectedDate = nil
        currentEntry = nil
        editedContent = ""
        fileContent = ""
        isDirty = false
        isLoading = false
        hasError = false
        errorMessage = nil
        stopAutoSaveTimer()
    }
    
    // MARK: - Date and File Handling
    
    func getEntryURL(for date: Date) -> URL? {
        return fileService.getEntryURL(for: date)
    }
    
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
    
    // MARK: - Editing Functions
    
    func loadAndStartEditing() {
        editedContent = fileContent
        startAutoSaveTimer()
    }
    
    func discardChanges() {
        editedContent = fileContent
        isDirty = false
    }
    
    // MARK: - Save Functions
    
    func saveEdits() async throws {
        guard let date = selectedDate else { return }
        try await saveCurrentEntry()
    }
    
    func saveCurrentEntry() async throws {
        guard let date = selectedDate, isDirty else { return }
        
        isLoading = true
        
        do {
            if let entry = JournalEntry(fromMarkdown: editedContent, date: date) {
                try await storageManager.saveEntry(entry)
                fileContent = editedContent
                isDirty = false
                currentEntry = entry
            } else {
                throw JournalFileError.saveFailed
            }
            isLoading = false
            
        } catch {
            handleError(error)
            throw error
        }
    }
    
    // MARK: - Auto-Save Timer
    
    func startAutoSaveTimer() {
        stopAutoSaveTimer()
        
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: autoSaveInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if !self.isDirty {
                self.isDirty = self.editedContent != self.fileContent
                return
            }
            
            Task {
                do {
                    try await self.saveCurrentEntry()
                } catch {
                    self.handleError(error)
                }
            }
        }
    }
    
    func stopAutoSaveTimer() {
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
    }
    
    // MARK: - Content Loading
    
    func loadContent(for date: Date?) {
        guard let date = date else {
            reset()
            return
        }
        
        guard FolderManager.shared.hasSelectedFolder else {
            hasError = true
            errorMessage = "No folder selected. Please select a folder first."
            return
        }
        
        isLoading = true
        hasError = false
        
        Task { @MainActor in
            do {
                if storageManager.entryExists(for: date) {
                    let entry = try await storageManager.loadEntry(for: date)
                    currentEntry = entry
                    fileContent = entry.toMarkdown()
                    editedContent = fileContent
                } else {
                    fileContent = ""
                    editedContent = ""
                    currentEntry = JournalEntry(date: date)
                }
                isLoading = false
            } catch {
                handleError(error)
            }
        }
    }
    
    // MARK: - Entry Operations
    
    func createEntry(for date: Date) {
        guard FolderManager.shared.hasSelectedFolder else {
            hasError = true
            errorMessage = "No folder selected. Please select a folder first."
            return
        }
        
        isLoading = true
        
        Task { @MainActor in
            do {
                let entry = JournalEntry(date: date)
                try await storageManager.saveEntry(entry)
                
                selectedDate = date
                currentEntry = entry
                fileContent = entry.toMarkdown()
                editedContent = fileContent
                isLoading = false
            } catch {
                handleError(error)
            }
        }
    }
    
    func openTodaysEntry() {
        let today = Date()
        
        if FolderManager.shared.hasSelectedFolder && storageManager.entryExists(for: today) {
            selectedDate = today
        } else if FolderManager.shared.hasSelectedFolder {
            createEntry(for: today)
        } else {
            hasError = true
            errorMessage = "No folder selected. Please select a folder first."
        }
    }
    
    func resetFolderSelection() {
        reset()
        FolderManager.shared.resetFolderSelection()
    }
    
    func handleError(_ error: Error) {
        hasError = true
        errorMessage = error.localizedDescription
        isLoading = false
    }
    
    // MARK: - Property Observers
    
    func dateChanged(from oldValue: Date?) {
        if selectedDate != oldValue {
            loadContent(for: selectedDate)
            stopAutoSaveTimer()
            startAutoSaveTimer()
        }
    }
    
    func contentChanged(from oldValue: String) {
        let wasDirty = isDirty
        
        isDirty = editedContent != fileContent
        
        if isDirty {
            if let date = selectedDate {
                currentEntry = JournalEntry(fromMarkdown: editedContent, date: date)
            }
        }
    }
} 
