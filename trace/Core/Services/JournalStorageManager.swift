import Foundation

protocol JournalStorageManagerProtocol {
    func saveEntry(_ entry: JournalEntry) async throws
    func loadEntry(for date: Date) async throws -> JournalEntry
    func entryExists(for date: Date) -> Bool
    func getAllEntryDates() async throws -> [Date]
}

class JournalStorageManager: JournalStorageManagerProtocol {
    private let fileService: JournalFileServiceProtocol
    
    init(fileService: JournalFileServiceProtocol = JournalFileService()) {
        self.fileService = fileService
        setupJournalDirectory()
    }
    
    
    func saveEntry(_ entry: JournalEntry) async throws {
        let markdownContent = entry.toMarkdown()
        try await fileService.saveEntry(markdownContent, for: entry.date)
    }
    
    func loadEntry(for date: Date) async throws -> JournalEntry {
        let markdownContent = try await fileService.loadEntry(for: date)
        
        guard let entry = JournalEntry(fromMarkdown: markdownContent, date: date) else {
            throw JournalFileError.loadFailed
        }
        
        var loadedEntry = entry
        loadedEntry.fileURL = fileService.getEntryURL(for: date)
        
        return loadedEntry
    }
    
    func entryExists(for date: Date) -> Bool {
        return fileService.entryExists(for: date)
    }
    
    func getAllEntryDates() async throws -> [Date] {
        guard let folderURL = FolderManager.shared.selectedFolderURL else {
            throw JournalFileError.folderNotSelected
        }
        
        let fileManager = FileManager.default
        var entryDates: [Date] = []
        
        let yearURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
            .filter { FileService.shared.isDirectory(at: $0) }
            .filter { isYearDirectory(url: $0) }
        
        for yearURL in yearURLs {
            let monthURLs = try fileManager.contentsOfDirectory(at: yearURL, includingPropertiesForKeys: nil)
                .filter { FileService.shared.isDirectory(at: $0) }
                .filter { isMonthDirectory(url: $0) }
            
            for monthURL in monthURLs {
                let dayFiles = try fileManager.contentsOfDirectory(at: monthURL, includingPropertiesForKeys: nil)
                    .filter { !FileService.shared.isDirectory(at: $0) }
                    .filter { $0.pathExtension == "md" }
                
                for dayFile in dayFiles {
                    if let date = parseDate(from: dayFile) {
                        entryDates.append(date)
                    }
                }
            }
        }
        
        return entryDates.sorted()
    }
    
    
    private func setupJournalDirectory() {
        guard let folderURL = FolderManager.shared.selectedFolderURL else {
            return
        }
        
        do {
            try FileService.shared.createDirectoryIfNeeded(at: folderURL)
        } catch {
            print("Error setting up journal directory: \(error.localizedDescription)")
        }
    }
    
    private func isYearDirectory(url: URL) -> Bool {
        let yearName = url.lastPathComponent
        return yearName.count == 4 && Int(yearName) != nil
    }
    
    private func isMonthDirectory(url: URL) -> Bool {
        let monthName = url.lastPathComponent
        return monthName.count == 2 && Int(monthName) != nil && (1...12).contains(Int(monthName)!)
    }
    
    private func parseDate(from fileURL: URL) -> Date? {
        let calendar = Calendar.current
        let filename = fileURL.deletingPathExtension().lastPathComponent
        
        guard let day = Int(filename),
              let month = Int(fileURL.deletingLastPathComponent().lastPathComponent),
              let year = Int(fileURL.deletingLastPathComponent().deletingLastPathComponent().lastPathComponent) else {
            return nil
        }
        
        let dateComponents = DateComponents(calendar: calendar, year: year, month: month, day: day)
        return dateComponents.date
    }
} 
