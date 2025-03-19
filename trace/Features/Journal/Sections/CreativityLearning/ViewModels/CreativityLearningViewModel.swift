import SwiftUI

@Observable
final class CreativityLearningViewModel {
    
    var ideas: String = ""
    var learningLog: String = ""
    var projects: String = ""
    var mediaItems: [JournalMediaItem] = []
    var id = UUID()
    
    var showingAddMedia: Bool = false
    var newMediaTitle: String = ""
    var newMediaCreator: String = ""
    var newMediaNotes: String = ""
    var newMediaStatus: String = "Not Started"
    
    var isValid: Bool {
        !ideas.isEmpty || !learningLog.isEmpty || !projects.isEmpty || !mediaItems.isEmpty
    }
    
    init(entry: JournalCreativityLearning? = nil) {
        if let entry = entry {
            self.ideas = entry.ideas
            self.learningLog = entry.learningLog
            self.projects = entry.projects
            self.mediaItems = entry.booksMedia
        }
    }
    
    func toModel() -> JournalCreativityLearning {
        var model = JournalCreativityLearning()
        model.ideas = ideas
        model.learningLog = learningLog
        model.projects = projects
        model.booksMedia = mediaItems
        return model
    }
    
    func reset() {
        ideas = ""
        learningLog = ""
        projects = ""
        mediaItems = []
        resetNewMediaFields()
    }
    
    func addMediaItem() {
        let item = JournalMediaItem(
            title: newMediaTitle,
            creator: newMediaCreator,
            status: newMediaStatus,
            notes: newMediaNotes
        )
        mediaItems.append(item)
        resetNewMediaFields()
        showingAddMedia = false
    }
    
    func resetNewMediaFields() {
        newMediaTitle = ""
        newMediaCreator = ""
        newMediaNotes = ""
        newMediaStatus = "Not Started"
    }
    
    func updateMediaItemStatus(index: Int, status: String) {
        guard index >= 0 && index < mediaItems.count else { return }
        mediaItems[index].status = status
    }
} 
