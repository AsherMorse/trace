import SwiftUI

@Observable
final class WorkCareerViewModel {
    
    var items: [JournalWorkItem] = []
    var meetings: [JournalMeeting] = []
    var challenges: String = ""
    var achievements: String = ""
    var ideas: String = ""
    var id = UUID()
    
    
    var showingAddWorkItem: Bool = false
    var newWorkItemTitle: String = ""
    var newWorkItemDescription: String = ""
    var newWorkItemStatus: String = "To Do"
    var newWorkItemPriority: String = "Medium"
    
    
    var showingAddMeeting: Bool = false
    var newMeetingTitle: String = ""
    var newMeetingAttendees: String = ""
    var newMeetingNotes: String = ""
    var newMeetingActionItems: String = ""
    
    var isValid: Bool {
        !items.isEmpty || !meetings.isEmpty || !challenges.isEmpty || !achievements.isEmpty
    }
    
    init(entry: JournalWorkCareer? = nil) {
        if let entry = entry {
            self.items = entry.workItems
            self.meetings = entry.meetings
            self.challenges = entry.challenges
            self.achievements = entry.wins
            self.ideas = entry.workIdeas
        }
    }
    
    func toModel() -> JournalWorkCareer {
        var model = JournalWorkCareer()
        model.workItems = items
        model.meetings = meetings
        model.challenges = challenges
        model.wins = achievements
        model.workIdeas = ideas
        return model
    }
    
    func reset() {
        items = []
        meetings = []
        challenges = ""
        achievements = ""
        ideas = ""
        resetNewWorkItemFields()
        resetNewMeetingFields()
    }
    
    func addWorkItem(title: String, description: String = "", status: String = "To Do", priority: String = "Medium") {
        let item = JournalWorkItem(
            title: title,
            status: status,
            priority: priority,
            description: description
        )
        items.append(item)
        resetNewWorkItemFields()
        showingAddWorkItem = false
    }
    
    func resetNewWorkItemFields() {
        newWorkItemTitle = ""
        newWorkItemDescription = ""
        newWorkItemStatus = "To Do"
        newWorkItemPriority = "Medium"
    }
    
    func addMeeting(title: String, attendees: String = "", notes: String = "", actionItems: String = "") {
        let meeting = JournalMeeting(
            title: title,
            attendees: attendees,
            notes: notes,
            actionItems: actionItems
        )
        meetings.append(meeting)
        resetNewMeetingFields()
        showingAddMeeting = false
    }
    
    func resetNewMeetingFields() {
        newMeetingTitle = ""
        newMeetingAttendees = ""
        newMeetingNotes = ""
        newMeetingActionItems = ""
    }
} 
