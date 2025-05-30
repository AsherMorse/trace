import SwiftUI

@Observable
final class JournalViewModel {
    
    var selectedDate: Date? {
        didSet { if selectedDate != oldValue { handleDateChange() } }
    }
    var currentEntry: JournalEntry? {
        didSet { if currentEntry != oldValue { handleEntryChange() } }
    }
    var editedContent: String = "" {
        didSet { handleContentChange() }
    }
    var fileContent: String = ""
    var isDirty: Bool = false
    
    var isLoading: Bool = false
    var hasError: Bool = false
    var errorMessage: String?
    
    var showingDeleteConfirmation = false
    var itemToDeleteType = ""
    var itemToDeleteIndex = -1
    
    private let fileService: JournalFileServiceProtocol
    private let storageManager: JournalStorageManagerProtocol
    
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
    
    func updateEntrySection(_ updatedEntry: JournalEntry) {
        currentEntry = updatedEntry
        editedContent = updatedEntry.toMarkdown()
        
        isDirty = fileContent != editedContent
        
        NotificationCenter.default.post(name: .journalEntryUpdated, object: nil)
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
    
    func getEntryURL(for date: Date) -> URL? {
        fileService.getEntryURL(for: date)
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
    
    func loadAndStartEditing() {
        editedContent = fileContent
        startAutoSaveTimer()
    }
    
    func discardChanges() {
        editedContent = fileContent
        isDirty = false
    }
    
    func saveEdits() async throws {
        guard selectedDate != nil, isDirty else { return }
        try await saveCurrentEntry()
    }
    
    func saveCurrentEntry() async throws {
        guard let date = selectedDate else { return }
        
        isLoading = true
        
        do {
            if let entry = currentEntry {
                if isDirty {
                    try await storageManager.saveEntry(entry)
                    fileContent = editedContent
                    isDirty = false
                }
            } else if let entry = JournalEntry(fromMarkdown: editedContent, date: date) {
                try await storageManager.saveEntry(entry)
                fileContent = editedContent
                currentEntry = entry
                isDirty = false
            } else {
                throw JournalFileError.saveFailed
            }
            
            isLoading = false
        } catch {
            handleError(error)
            throw error
        }
    }
    
    func startAutoSaveTimer() {
        stopAutoSaveTimer()
        
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: autoSaveInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if !self.isDirty && self.editedContent != self.fileContent {
                self.isDirty = true
            }
            
            if self.isDirty {
                Task {
                    try? await self.saveCurrentEntry()
                }
            }
        }
    }
    
    func stopAutoSaveTimer() {
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
    }
    
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
                    
                    isDirty = false
                } else {
                    let newEntry = JournalEntry(date: date)
                    currentEntry = newEntry
                    fileContent = ""
                    editedContent = ""
                    isDirty = false
                }
                isLoading = false
            } catch {
                handleError(error)
            }
        }
    }
    
    func createEntry(for date: Date) {
        guard FolderManager.shared.hasSelectedFolder else {
            hasError = true
            errorMessage = "No folder selected. Please select a folder first."
            return
        }
        
        isLoading = true
        
        Task { @MainActor in
            do {
                if storageManager.entryExists(for: date) {
                    loadContent(for: date)
                    return
                }
                
                let entry = JournalEntry(date: date)
                
                selectedDate = date
                currentEntry = entry
                fileContent = entry.toMarkdown()
                editedContent = fileContent
                isDirty = false
                isLoading = false
                
                if !entry.isEmpty {
                    try await storageManager.saveEntry(entry)
                }
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
    
    private func handleDateChange() {
        loadContent(for: selectedDate)
        stopAutoSaveTimer()
        startAutoSaveTimer()
    }
    
    private func handleContentChange() {
        isDirty = editedContent != fileContent
        
        if isDirty, let date = selectedDate,
           let entry = JournalEntry(fromMarkdown: editedContent, date: date) {
            currentEntry = entry
        }
    }
    
    private func handleEntryChange() {
        if let entry = currentEntry {
            let newContent = entry.toMarkdown()
            
            if editedContent != newContent {
                editedContent = newContent
            }
            
            isDirty = fileContent != editedContent
        }
        
        NotificationCenter.default.post(name: .journalEntryUpdated, object: nil)
    }
    
    
    func deleteMediaItem(at index: Int) {
        guard var entry = currentEntry, 
              index >= 0 && index < entry.creativityLearning.booksMedia.count else { return }
        entry.removeMediaItem(at: index)
        updateEntrySection(entry)
        Task { @MainActor in
            try? await saveCurrentEntry()
        }
    }
    
    func deleteInteraction(at index: Int) {
        guard var entry = currentEntry,
              index >= 0 && index < entry.social.meaningfulInteractions.count else { return }
        entry.removeInteraction(at: index)
        updateEntrySection(entry)
        Task { @MainActor in
            try? await saveCurrentEntry()
        }
    }
    
    func deleteWorkItem(at index: Int) {
        guard var entry = currentEntry,
              index >= 0 && index < entry.workCareer.workItems.count else { return }
        entry.removeWorkItem(at: index)
        updateEntrySection(entry)
        Task { @MainActor in
            try? await saveCurrentEntry()
        }
    }
    
    func deleteMeeting(at index: Int) {
        guard var entry = currentEntry,
              index >= 0 && index < entry.workCareer.meetings.count else { return }
        entry.removeMeeting(at: index)
        updateEntrySection(entry)
        Task { @MainActor in
            try? await saveCurrentEntry()
        }
    }
    
    func isSectionEmpty(_ section: JournalSection) -> Bool {
        guard let entry = currentEntry else { return true }
        
        switch section {
        case .dailyCheckIn:
            return entry.dailyCheckIn.isEmpty
        case .personalGrowth:
            return entry.personalGrowth.isEmpty
        case .wellbeing:
            return entry.wellbeing.isEmpty
        case .creativityLearning:
            return entry.creativityLearning.isEmpty
        case .social:
            return entry.social.isEmpty
        case .workCareer:
            return entry.workCareer.isEmpty
        }
    }
} 
