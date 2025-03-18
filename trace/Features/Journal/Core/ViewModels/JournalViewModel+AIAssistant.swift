import Foundation

extension JournalViewModel {
    func applyAIGeneratedContent(_ content: String, for date: Date) throws {
        guard !content.isEmpty else { return }
        
        guard let entry = JournalEntry(fromMarkdown: content, date: date) else {
            throw JournalFileError.saveFailed
        }
        
        updateEntrySection(entry)
        
        isDirty = true
    }
    
    var canUseAIAssistant: Bool {
        return FolderManager.shared.hasSelectedFolder && selectedDate != nil
    }
} 