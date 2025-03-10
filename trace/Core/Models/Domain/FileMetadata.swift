import Foundation

struct FileMetadata {
    let creationDate: Date?
    let modificationDate: Date?
    let size: Int?
    let isDirectory: Bool
    
    var formattedSize: String {
        guard let size = size else { return "Unknown size" }
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(size))
    }
    
    func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedCreationDate: String {
        return formattedDate(creationDate)
    }
    
    var formattedModificationDate: String {
        return formattedDate(modificationDate)
    }
} 