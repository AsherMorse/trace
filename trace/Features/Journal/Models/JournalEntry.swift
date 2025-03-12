import Foundation

struct JournalEntry {
    let date: Date
    let content: String
    let fileURL: URL
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
    
    var title: String {
        // Extract title from content or use formatted date
        return formattedDate
    }
} 