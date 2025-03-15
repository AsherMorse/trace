import Foundation

enum JournalFileError: Error, LocalizedError {
    case folderNotSelected
    case accessDenied
    case fileNotFound
    case saveFailed
    case loadFailed
    
    var errorDescription: String? {
        switch self {
        case .folderNotSelected:
            return "No journal folder has been selected"
        case .accessDenied:
            return "Access to the journal folder was denied"
        case .fileNotFound:
            return "The requested journal entry could not be found"
        case .saveFailed:
            return "Failed to save the journal entry"
        case .loadFailed:
            return "Failed to load the journal entry"
        }
    }
}

protocol JournalFileServiceProtocol {
    func getEntryURL(for date: Date) -> URL?
    func loadEntry(for date: Date) async throws -> String
    func saveEntry(_ content: String, for date: Date) async throws
    func entryExists(for date: Date) -> Bool
}

class JournalFileService: JournalFileServiceProtocol {
    private let fileManager = FileManager.default
    private let calendar = Calendar.current
    
    func getEntryURL(for date: Date) -> URL? {
        guard let selectedFolder = FolderManager.shared.selectedFolderURL else {
            return nil
        }
        
        let components = formatDateComponents(from: date)
        
        let yearFolder = selectedFolder.appendingPathComponent(components.year)
        let monthFolder = yearFolder.appendingPathComponent(components.month)
        let fileURL = monthFolder.appendingPathComponent("\(components.day).md")
        
        return fileURL
    }
    
    func loadEntry(for date: Date) async throws -> String {
        guard let entryURL = getEntryURL(for: date) else {
            throw JournalFileError.folderNotSelected
        }
        
        guard fileManager.fileExists(atPath: entryURL.path) else {
            throw JournalFileError.fileNotFound
        }
        
        do {
            return try String(contentsOf: entryURL, encoding: .utf8)
        } catch {
            throw JournalFileError.loadFailed
        }
    }
    
    func saveEntry(_ content: String, for date: Date) async throws {
        guard let entryURL = getEntryURL(for: date) else {
            throw JournalFileError.folderNotSelected
        }
        
        let directory = entryURL.deletingLastPathComponent()
        
        do {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            
            try content.write(to: entryURL, atomically: true, encoding: .utf8)
        } catch {
            throw JournalFileError.saveFailed
        }
    }
    
    func entryExists(for date: Date) -> Bool {
        guard let entryURL = getEntryURL(for: date) else {
            return false
        }
        
        return fileManager.fileExists(atPath: entryURL.path)
    }
    
    // MARK: - Private Methods
    
    private func formatDateComponents(from date: Date) -> (year: String, month: String, day: String) {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        let year = String(format: "%04d", components.year ?? 2023)
        let month = String(format: "%02d", components.month ?? 1)
        let day = String(format: "%02d", components.day ?? 1)
        
        return (year, month, day)
    }
} 
