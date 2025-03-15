import SwiftUI

@Observable
class JournalViewModel {
    var selectedDate: Date? {
        didSet {
            if selectedDate != oldValue {
                loadContent(for: selectedDate)
                stopAutoSaveTimer()
                startAutoSaveTimer()
                
                if let date = selectedDate {
                    print("📆 Selected date changed to: \(formatDate(date))")
                } else {
                    print("📆 Selected date cleared")
                }
            }
        }
    }
    var fileContent: String = ""
    var isLoading: Bool = false
    var hasError: Bool = false
    var errorMessage: String?
    
    var editedContent: String = "" {
        didSet {
            let wasDirty = isDirty
            let oldContentLength = oldValue.count
            let newContentLength = editedContent.count
            
            // Check if content has changed and update dirty flag
            isDirty = editedContent != fileContent
            
            print("📝 Content changed: \(oldContentLength) → \(newContentLength) chars | isDirty: \(isDirty)")
            
            if isDirty {
                print("🔍 DIFF - Edited length: \(editedContent.count), File length: \(fileContent.count)")
                // Log a sample of the first difference to help diagnose
                if editedContent.count > 0 && fileContent.count > 0 {
                    for (i, (editedChar, fileChar)) in zip(editedContent, fileContent).enumerated() {
                        if editedChar != fileChar {
                            let editedSnippet = String(editedContent.dropFirst(max(0, i-10)).prefix(20))
                            let fileSnippet = String(fileContent.dropFirst(max(0, i-10)).prefix(20))
                            print("📝 First difference at position \(i):")
                            print("   Edited: ...\(editedSnippet)...")
                            print("   File:   ...\(fileSnippet)...")
                            break
                        }
                    }
                    
                    // If lengths are different but no character differences found in the range checked
                    if editedContent.count != fileContent.count && editedContent.prefix(min(editedContent.count, fileContent.count)) == fileContent.prefix(min(editedContent.count, fileContent.count)) {
                        print("📝 Content lengths differ but beginnings match. One has additional content at the end.")
                    }
                }
            }
            
            if isDirty != wasDirty {
                print("🔄 Dirty state changed: \(isDirty ? "Entry has unsaved changes" : "Entry is clean")")
            }
            
            // Update currentEntry when editedContent changes
            updateCurrentEntryFromMarkdown()
        }
    }
    var isDirty: Bool = false {
        didSet {
            if isDirty != oldValue {
                print("🚩 isDirty flag changed from \(oldValue) to \(isDirty)")
            }
        }
    }
    
    // Current parsed entry from the markdown, for use by the section views
    var currentEntry: JournalEntry?
    
    private let fileService: JournalFileServiceProtocol
    private let storageManager: JournalStorageManagerProtocol
    private var autoSaveTimer: Timer?
    private let autoSaveInterval: TimeInterval = 30 // Seconds
    
    init(fileService: JournalFileServiceProtocol = JournalFileService(), 
         storageManager: JournalStorageManagerProtocol = JournalStorageManager()) {
        self.fileService = fileService
        self.storageManager = storageManager
        
        print("📓 JournalViewModel initialized")
        
        if FolderManager.shared.hasSelectedFolder {
            print("📁 Journal folder is already selected, opening today's entry")
            openTodaysEntry()
        } else {
            print("⚠️ No journal folder selected")
        }
    }
    
    deinit {
        print("🗑️ JournalViewModel being deallocated, stopping auto-save timer")
        stopAutoSaveTimer()
    }
    
    // Update the editedContent based on changes in a section
    func updateEntrySection(_ updatedEntry: JournalEntry) {
        print("🔄 Updating entry section with new data")
        
        // Save the current entry with the updated section
        if var entry = currentEntry {
            // Update only the specific section that changed
            // We'd need to be more selective here in a real implementation
            currentEntry = updatedEntry
            
            // Convert the updated entry to markdown and update editedContent
            editedContent = updatedEntry.toMarkdown()
            print("✅ Updated editedContent from section change")
        } else {
            print("⚠️ Cannot update section: No current entry")
            currentEntry = updatedEntry
            editedContent = updatedEntry.toMarkdown()
        }
    }
    
    // Parse the current markdown to update the currentEntry property
    private func updateCurrentEntryFromMarkdown() {
        if let date = selectedDate {
            currentEntry = JournalEntry(fromMarkdown: editedContent, date: date)
        }
    }
    
    func getEntryURL(for date: Date) -> URL? {
        let url = fileService.getEntryURL(for: date)
        print("📄 Entry URL for \(formatDate(date)): \(url?.path ?? "nil")")
        return url
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
        print("✏️ Started editing entry")
        let oldContent = editedContent
        editedContent = fileContent
        print("✏️ Loaded content into editor: '\(oldContent)' → '\(editedContent)'")
        startAutoSaveTimer()
    }
    
    func discardChanges() {
        print("🚫 Discarding changes")
        print("🔍 Before discard - Edited: \(editedContent.count) chars, File: \(fileContent.count) chars, isDirty: \(isDirty)")
        editedContent = fileContent
        isDirty = false
        print("🔍 After discard - Edited: \(editedContent.count) chars, File: \(fileContent.count) chars, isDirty: \(isDirty)")
    }
    
    func saveEdits() async throws {
        guard let date = selectedDate else {
            print("⚠️ Cannot save edits: No date selected")
            return
        }
        
        print("💾 Manual save requested for \(formatDate(date))")
        print("💾 Before manual save - isDirty: \(isDirty), Edited: \(editedContent.count) chars, File: \(fileContent.count) chars")
        try await saveCurrentEntry()
        print("✅ Manual save completed")
    }
    
    func saveCurrentEntry() async throws {
        guard let date = selectedDate else {
            print("⚠️ Save aborted: No date selected")
            return
        }
        
        print("🔍 Save check - isDirty: \(isDirty)")
        print("🔍 Save check - Edited content chars: \(editedContent.count)")
        print("🔍 Save check - File content chars: \(fileContent.count)")
        print("🔍 Save check - Are contents equal?: \(editedContent == fileContent)")
        
        guard isDirty else {
            print("ℹ️ Skipping save: No changes detected (isDirty is false)")
            print("ℹ️ Debug comparison - editedContent hash: \(editedContent.hashValue)")
            print("ℹ️ Debug comparison - fileContent hash: \(fileContent.hashValue)")
            return
        }
        
        print("🔄 Starting save operation for \(formatDate(date))")
        isLoading = true
        
        do {
            print("📝 Converting markdown to JournalEntry object")
            if let entry = JournalEntry(fromMarkdown: editedContent, date: date) {
                print("💾 Saving entry to storage...")
                try await storageManager.saveEntry(entry)
                print("✅ Entry saved successfully")
                
                print("🔄 Before updating fileContent - Old: \(fileContent.count) chars, New: \(editedContent.count) chars")
                fileContent = editedContent
                isDirty = false
                print("🔄 Updated file content and reset dirty flag - isDirty now: \(isDirty)")
            } else {
                print("❌ Failed to create entry from markdown")
                throw JournalFileError.saveFailed
            }
            isLoading = false
            
        } catch {
            print("❌ Save operation failed: \(error.localizedDescription)")
            handleError(error)
            throw error
        }
    }
    
    func startAutoSaveTimer() {
        stopAutoSaveTimer()
        
        print("⏱️ Starting auto-save timer (interval: \(autoSaveInterval) seconds)")
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: autoSaveInterval, repeats: true) { [weak self] _ in
            guard let self = self else {
                print("⚠️ Auto-save skipped: ViewModel has been deallocated")
                return
            }
            
            print("⏱️ Auto-save timer fired - Current state:")
            print("⏱️ isDirty: \(self.isDirty)")
            print("⏱️ Edited content chars: \(self.editedContent.count)")
            print("⏱️ File content chars: \(self.fileContent.count)")
            print("⏱️ Are contents identical?: \(self.editedContent == self.fileContent)")
            
            if !self.isDirty {
                print("ℹ️ Auto-save skipped: No changes to save (isDirty is false)")
                
                // Additional debug info
                if self.editedContent != self.fileContent {
                    print("⚠️ WARNING: Content differs but isDirty is false!")
                    print("⚠️ This indicates a potential bug in dirty state tracking")
                    
                    // Force update isDirty
                    self.isDirty = self.editedContent != self.fileContent
                    print("⚠️ Corrected isDirty to: \(self.isDirty)")
                }
                return
            }
            
            print("⏱️ Auto-save timer triggered - Saving changes")
            Task {
                do {
                    print("🔄 Running auto-save operation...")
                    try await self.saveCurrentEntry()
                    print("✅ Auto-save completed successfully")
                } catch {
                    print("❌ Auto-save failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func stopAutoSaveTimer() {
        if autoSaveTimer != nil {
            print("⏱️ Stopping auto-save timer")
            autoSaveTimer?.invalidate()
            autoSaveTimer = nil
        }
    }
    
    func loadContent(for date: Date?) {
        guard let date = date else {
            print("ℹ️ Clearing state due to nil date")
            clearState()
            return
        }
        
        print("📂 Loading content for \(formatDate(date))")
        
        guard FolderManager.shared.hasSelectedFolder else {
            print("⚠️ Cannot load: No folder selected")
            hasError = true
            errorMessage = "No folder selected. Please select a folder first."
            return
        }
        
        isLoading = true
        hasError = false
        
        Task { @MainActor in
            do {
                if storageManager.entryExists(for: date) {
                    print("🔍 Entry exists, loading from storage")
                    let entry = try await storageManager.loadEntry(for: date)
                    currentEntry = entry
                    fileContent = entry.toMarkdown()
                    editedContent = fileContent // Initialize edited content
                    print("✅ Entry loaded successfully - Content length: \(fileContent.count) chars")
                } else {
                    print("ℹ️ No entry exists for this date, using empty content")
                    fileContent = ""
                    editedContent = ""
                    currentEntry = JournalEntry(date: date)
                }
                isLoading = false
            } catch {
                print("❌ Failed to load entry: \(error.localizedDescription)")
                handleError(error)
            }
        }
    }
    
    func createEntry(for date: Date) {
        print("🆕 Creating new entry for \(formatDate(date))")
        
        guard FolderManager.shared.hasSelectedFolder else {
            print("⚠️ Cannot create entry: No folder selected")
            hasError = true
            errorMessage = "No folder selected. Please select a folder first."
            return
        }
        
        isLoading = true
        
        Task { @MainActor in
            do {
                print("📝 Creating new JournalEntry object")
                let entry = JournalEntry(date: date)
                
                print("💾 Saving new entry to storage")
                try await storageManager.saveEntry(entry)
                
                print("🔄 Updating view state with new entry")
                selectedDate = date
                currentEntry = entry
                fileContent = entry.toMarkdown()
                editedContent = fileContent // Initialize edited content
                print("✅ New entry created successfully - Content length: \(fileContent.count) chars")
                isLoading = false
            } catch {
                print("❌ Failed to create entry: \(error.localizedDescription)")
                handleError(error)
            }
        }
    }
    
    func openTodaysEntry() {
        let today = Date()
        print("📅 Opening today's entry (\(formatDate(today)))")
        
        if FolderManager.shared.hasSelectedFolder && storageManager.entryExists(for: today) {
            print("🔍 Today's entry exists, loading it")
            selectedDate = today
        } else if FolderManager.shared.hasSelectedFolder {
            print("🆕 Today's entry doesn't exist, creating it")
            createEntry(for: today)
        } else {
            print("⚠️ Cannot open today's entry: No folder selected")
            hasError = true
            errorMessage = "No folder selected. Please select a folder first."
        }
    }
    
    func resetFolderSelection() {
        print("🔄 Resetting folder selection")
        clearState()
        FolderManager.shared.resetFolderSelection()
    }
    
    func handleError(_ error: Error) {
        print("❌ Error handled: \(error.localizedDescription)")
        hasError = true
        errorMessage = error.localizedDescription
        isLoading = false
        
        print("Journal error: \(error.localizedDescription)")
    }
    
    private func clearState() {
        print("🧹 Clearing view state")
        selectedDate = nil
        fileContent = ""
        editedContent = ""
        currentEntry = nil
        isLoading = false
        hasError = false
        errorMessage = nil
        isDirty = false
        stopAutoSaveTimer()
    }
}
