import Foundation

extension Notification.Name {
    static let journalEntryUpdated = Notification.Name("journalEntryUpdated")
}

extension JournalEntry: Equatable {
    static func == (lhs: JournalEntry, rhs: JournalEntry) -> Bool {
        return lhs.date == rhs.date &&
               lhs.dailyCheckIn == rhs.dailyCheckIn &&
               lhs.personalGrowth == rhs.personalGrowth &&
               lhs.wellbeing == rhs.wellbeing &&
               lhs.creativityLearning == rhs.creativityLearning &&
               lhs.social == rhs.social &&
               lhs.workCareer == rhs.workCareer
    }
}

extension JournalEntry {
    mutating func removeMediaItem(at index: Int) {
        guard index >= 0 && index < creativityLearning.booksMedia.count else { return }
        creativityLearning.booksMedia.remove(at: index)
    }
    
    mutating func removeInteraction(at index: Int) {
        guard index >= 0 && index < social.meaningfulInteractions.count else { return }
        social.meaningfulInteractions.remove(at: index)
    }
    
    mutating func removeWorkItem(at index: Int) {
        guard index >= 0 && index < workCareer.workItems.count else { return }
        workCareer.workItems.remove(at: index)
    }
    
    mutating func removeMeeting(at index: Int) {
        guard index >= 0 && index < workCareer.meetings.count else { return }
        workCareer.meetings.remove(at: index)
    }
}

struct JournalEntry {
    let date: Date
    var dailyCheckIn: JournalDailyCheckIn
    var personalGrowth: JournalPersonalGrowth
    var wellbeing: JournalWellbeing
    var creativityLearning: JournalCreativityLearning
    var social: JournalSocial
    var workCareer: JournalWorkCareer
    
    var fileURL: URL?
    
    init(date: Date) {
        self.date = date
        self.dailyCheckIn = JournalDailyCheckIn()
        self.personalGrowth = JournalPersonalGrowth()
        self.wellbeing = JournalWellbeing()
        self.creativityLearning = JournalCreativityLearning()
        self.social = JournalSocial()
        self.workCareer = JournalWorkCareer()
    }
    
    init(from viewModel: JournalViewModel) {
        self.date = viewModel.selectedDate ?? Date()
        
        self.dailyCheckIn = JournalDailyCheckIn()
        self.personalGrowth = JournalPersonalGrowth()
        self.wellbeing = JournalWellbeing()
        self.creativityLearning = JournalCreativityLearning()
        self.social = JournalSocial()
        self.workCareer = JournalWorkCareer()
        
        if let date = viewModel.selectedDate {
            self.fileURL = viewModel.getEntryURL(for: date)
        }
    }
    
    init?(fromMarkdown markdown: String, date: Date) {
        self.date = date
        
        self.dailyCheckIn = JournalDailyCheckIn()
        self.personalGrowth = JournalPersonalGrowth()
        self.wellbeing = JournalWellbeing()
        self.creativityLearning = JournalCreativityLearning()
        self.social = JournalSocial()
        self.workCareer = JournalWorkCareer()
        
        let sections = splitIntoSections(markdown)
        
        for (sectionTitle, sectionContent) in sections {
            switch sectionTitle {
            case "Daily Check-in":
                self.dailyCheckIn = JournalDailyCheckIn.fromMarkdown(sectionContent)
            case "Personal Growth":
                self.personalGrowth = JournalPersonalGrowth.fromMarkdown(sectionContent)
            case "Wellbeing":
                self.wellbeing = JournalWellbeing.fromMarkdown(sectionContent)
            case "Creativity & Learning":
                self.creativityLearning = JournalCreativityLearning.fromMarkdown(sectionContent)
            case "Social":
                self.social = JournalSocial.fromMarkdown(sectionContent)
            case "Work & Career":
                self.workCareer = JournalWorkCareer.fromMarkdown(sectionContent)
            default:
                break
            }
        }
    }
    
    private func splitIntoSections(_ markdown: String) -> [(String, String)] {
        var sections: [(String, String)] = []
        let lines = markdown.components(separatedBy: .newlines)
        
        var currentSectionTitle: String?
        var currentSectionContent: [String] = []
        
        for line in lines {
            if line.hasPrefix("## ") {
                if let title = currentSectionTitle, !currentSectionContent.isEmpty {
                    sections.append((title, currentSectionContent.joined(separator: "\n")))
                    currentSectionContent = []
                }
                
                currentSectionTitle = line.replacingOccurrences(of: "## ", with: "")
            } else if currentSectionTitle != nil {
                currentSectionContent.append(line)
            }
        }
        
        if let title = currentSectionTitle, !currentSectionContent.isEmpty {
            sections.append((title, currentSectionContent.joined(separator: "\n")))
        }
        
        return sections
    }
    
    func toMarkdown() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        var markdown = "# Journal Entry: \(dateString)\n\n"
        
        markdown += dailyCheckIn.toMarkdown()
        markdown += personalGrowth.toMarkdown()
        markdown += wellbeing.toMarkdown()
        markdown += creativityLearning.toMarkdown()
        markdown += social.toMarkdown()
        markdown += workCareer.toMarkdown()
        
        return markdown
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}

struct JournalDailyCheckIn: Equatable {
    var mood: String = ""
    var todaysHighlight: String = ""
    var dailyOverview: String = ""
    
    func toMarkdown() -> String {
        var markdown = "## Daily Check-in\n\n"
        
        markdown += "### Mood\n"
        markdown += "\(mood)\n\n"
        
        markdown += "### Today's Highlight\n"
        markdown += "\(todaysHighlight)\n\n"
        
        markdown += "### Daily Overview\n"
        markdown += "\(dailyOverview)\n\n"
        
        return markdown
    }
    
    static func fromMarkdown(_ markdown: String) -> JournalDailyCheckIn {
        var dailyCheckIn = JournalDailyCheckIn()
        let subsections = parseSubsections(markdown)
        
        for (title, content) in subsections {
            switch title {
            case "Mood":
                dailyCheckIn.mood = content.trimmingCharacters(in: .whitespacesAndNewlines)
            case "Today's Highlight":
                dailyCheckIn.todaysHighlight = content.trimmingCharacters(in: .whitespacesAndNewlines)
            case "Daily Overview":
                dailyCheckIn.dailyOverview = content.trimmingCharacters(in: .whitespacesAndNewlines)
            default:
                break
            }
        }
        
        return dailyCheckIn
    }
}

struct JournalPersonalGrowth: Equatable {
    var reflections: String = ""
    var achievements: String = ""
    var challenges: String = ""
    var goals: String = ""
    
    func toMarkdown() -> String {
        var markdown = "## Personal Growth\n\n"
        
        markdown += "### Reflections\n"
        markdown += "\(reflections)\n\n"
        
        markdown += "### Achievements\n"
        markdown += "\(achievements)\n\n"
        
        markdown += "### Challenges\n"
        markdown += "\(challenges)\n\n"
        
        markdown += "### Goals\n"
        markdown += "\(goals)\n\n"
        
        return markdown
    }
    
    static func fromMarkdown(_ markdown: String) -> JournalPersonalGrowth {
        var personalGrowth = JournalPersonalGrowth()
        let subsections = parseSubsections(markdown)
        
        for (title, content) in subsections {
            switch title {
            case "Reflections":
                personalGrowth.reflections = content.trimmingCharacters(in: .whitespacesAndNewlines)
            case "Achievements":
                personalGrowth.achievements = content.trimmingCharacters(in: .whitespacesAndNewlines)
            case "Challenges":
                personalGrowth.challenges = content.trimmingCharacters(in: .whitespacesAndNewlines)
            case "Goals":
                personalGrowth.goals = content.trimmingCharacters(in: .whitespacesAndNewlines)
            default:
                break
            }
        }
        
        return personalGrowth
    }
}

struct JournalWellbeing: Equatable {
    var energyLevel: Int = 5
    var physicalActivity: String = ""
    var mentalHealth: String = ""
    
    func toMarkdown() -> String {
        var markdown = "## Wellbeing\n\n"
        
        markdown += "### Energy Level\n"
        markdown += "\(energyLevel)/10\n\n"
        
        markdown += "### Physical Activity\n"
        markdown += "\(physicalActivity)\n\n"
        
        markdown += "### Mental Health\n"
        markdown += "\(mentalHealth)\n\n"
        
        return markdown
    }
    
    static func fromMarkdown(_ markdown: String) -> JournalWellbeing {
        var wellbeing = JournalWellbeing()
        let subsections = parseSubsections(markdown)
        
        for (title, content) in subsections {
            switch title {
            case "Energy Level":
                let numberString = content.replacingOccurrences(of: "/10", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                wellbeing.energyLevel = Int(numberString) ?? 5
            case "Physical Activity":
                wellbeing.physicalActivity = content.trimmingCharacters(in: .whitespacesAndNewlines)
            case "Mental Health":
                wellbeing.mentalHealth = content.trimmingCharacters(in: .whitespacesAndNewlines)
            default:
                break
            }
        }
        
        return wellbeing
    }
}

struct JournalCreativityLearning: Equatable {
    var ideas: String = ""
    var learningLog: String = ""
    var booksMedia: [JournalMediaItem] = []
    var projects: String = ""
    
    func toMarkdown() -> String {
        var markdown = "## Creativity & Learning\n\n"
        
        markdown += "### Ideas\n"
        markdown += "\(ideas)\n\n"
        
        markdown += "### Learning Log\n"
        markdown += "\(learningLog)\n\n"
        
        markdown += "### Books & Media\n"
        for item in booksMedia {
            markdown += item.toMarkdown()
        }
        markdown += "\n"
        
        markdown += "### Projects\n"
        markdown += "\(projects)\n\n"
        
        return markdown
    }
    
    static func fromMarkdown(_ markdown: String) -> JournalCreativityLearning {
        var creativityLearning = JournalCreativityLearning()
        let subsections = parseSubsections(markdown)
        
        for (title, content) in subsections {
            switch title {
            case "Ideas":
                creativityLearning.ideas = content.trimmingCharacters(in: .whitespacesAndNewlines)
            case "Learning Log":
                creativityLearning.learningLog = content.trimmingCharacters(in: .whitespacesAndNewlines)
            case "Books & Media":
                creativityLearning.booksMedia = parseMediaItems(content)
            case "Projects":
                creativityLearning.projects = content.trimmingCharacters(in: .whitespacesAndNewlines)
            default:
                break
            }
        }
        
        return creativityLearning
    }
    
    private static func parseMediaItems(_ content: String) -> [JournalMediaItem] {
        var items: [JournalMediaItem] = []
        let lines = content.components(separatedBy: .newlines)
        
        var currentItem: JournalMediaItem?
        var currentTitle = ""
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.hasPrefix("#### ") {
                if let item = currentItem {
                    items.append(item)
                }
                
                currentItem = JournalMediaItem()
                currentTitle = trimmedLine.replacingOccurrences(of: "#### ", with: "")
                currentItem?.title = currentTitle
            } else if currentItem != nil {
                guard var updatedItem = currentItem else { continue }
                
                if trimmedLine.hasPrefix("Creator: ") {
                    updatedItem.creator = trimmedLine.replacingOccurrences(of: "Creator: ", with: "")
                } else if trimmedLine.hasPrefix("Status: ") {
                    updatedItem.status = trimmedLine.replacingOccurrences(of: "Status: ", with: "")
                } else if trimmedLine.hasPrefix("Notes: ") {
                    updatedItem.notes = trimmedLine.replacingOccurrences(of: "Notes: ", with: "")
                }
                
                currentItem = updatedItem
            }
        }
        
        if let item = currentItem {
            items.append(item)
        }
        
        return items
    }
}

struct JournalMediaItem: Equatable {
    var title: String = ""
    var creator: String = ""
    var status: String = ""
    var notes: String = ""
    
    func toMarkdown() -> String {
        var markdown = "#### \(title)\n"
        markdown += "    Creator: \(creator)\n"
        markdown += "    Status: \(status)\n"
        markdown += "    Notes: \(notes)\n\n"
        return markdown
    }
}

struct JournalSocial: Equatable {
    var meaningfulInteractions: [JournalInteraction] = []
    var relationshipUpdates: String = ""
    var socialEvents: String = ""
    
    func toMarkdown() -> String {
        var markdown = "## Social\n\n"
        
        markdown += "### Meaningful Interactions\n"
        for interaction in meaningfulInteractions {
            markdown += interaction.toMarkdown()
        }
        markdown += "\n"
        
        markdown += "### Relationship Updates\n"
        markdown += "\(relationshipUpdates)\n\n"
        
        markdown += "### Social Events\n"
        markdown += "\(socialEvents)\n\n"
        
        return markdown
    }
    
    static func fromMarkdown(_ markdown: String) -> JournalSocial {
        var social = JournalSocial()
        let subsections = parseSubsections(markdown)
        
        for (title, content) in subsections {
            switch title {
            case "Meaningful Interactions":
                social.meaningfulInteractions = parseInteractions(content)
            case "Relationship Updates":
                social.relationshipUpdates = content.trimmingCharacters(in: .whitespacesAndNewlines)
            case "Social Events":
                social.socialEvents = content.trimmingCharacters(in: .whitespacesAndNewlines)
            default:
                break
            }
        }
        
        return social
    }
    
    private static func parseInteractions(_ content: String) -> [JournalInteraction] {
        var interactions: [JournalInteraction] = []
        let lines = content.components(separatedBy: .newlines)
        
        var currentInteraction: JournalInteraction?
        var currentPerson = ""
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.hasPrefix("#### ") {
                if let interaction = currentInteraction {
                    interactions.append(interaction)
                }
                
                currentInteraction = JournalInteraction()
                currentPerson = trimmedLine.replacingOccurrences(of: "#### ", with: "")
                currentInteraction?.person = currentPerson
            } else if currentInteraction != nil {
                guard var updatedInteraction = currentInteraction else { continue }
                
                if trimmedLine.hasPrefix("Notes: ") {
                    updatedInteraction.notes = trimmedLine.replacingOccurrences(of: "Notes: ", with: "")
                }
                
                currentInteraction = updatedInteraction
            }
        }
        
        if let interaction = currentInteraction {
            interactions.append(interaction)
        }
        
        return interactions
    }
}

struct JournalInteraction: Equatable {
    var person: String = ""
    var notes: String = ""
    
    func toMarkdown() -> String {
        var markdown = "#### \(person)\n"
        markdown += "    Notes: \(notes)\n\n"
        return markdown
    }
}

struct JournalWorkCareer: Equatable {
    var workItems: [JournalWorkItem] = []
    var meetings: [JournalMeeting] = []
    var challenges: String = ""
    var wins: String = ""
    var workIdeas: String = ""
    
    func toMarkdown() -> String {
        var markdown = "## Work & Career\n\n"
        
        markdown += "### Work Items\n"
        for item in workItems {
            markdown += item.toMarkdown()
        }
        markdown += "\n"
        
        markdown += "### Meetings\n"
        for meeting in meetings {
            markdown += meeting.toMarkdown()
        }
        markdown += "\n"
        
        markdown += "### Challenges\n"
        markdown += "\(challenges)\n\n"
        
        markdown += "### Wins\n"
        markdown += "\(wins)\n\n"
        
        markdown += "### Work Ideas\n"
        markdown += "\(workIdeas)\n\n"
        
        return markdown
    }
    
    static func fromMarkdown(_ markdown: String) -> JournalWorkCareer {
        var workCareer = JournalWorkCareer()
        let subsections = parseSubsections(markdown)
        
        for (title, content) in subsections {
            switch title {
            case "Work Items":
                workCareer.workItems = parseWorkItems(content)
            case "Meetings":
                workCareer.meetings = parseMeetings(content)
            case "Challenges":
                workCareer.challenges = content.trimmingCharacters(in: .whitespacesAndNewlines)
            case "Wins":
                workCareer.wins = content.trimmingCharacters(in: .whitespacesAndNewlines)
            case "Work Ideas":
                workCareer.workIdeas = content.trimmingCharacters(in: .whitespacesAndNewlines)
            default:
                break
            }
        }
        
        return workCareer
    }
    
    private static func parseWorkItems(_ content: String) -> [JournalWorkItem] {
        var workItems: [JournalWorkItem] = []
        let lines = content.components(separatedBy: .newlines)
        
        var currentItem: JournalWorkItem?
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.hasPrefix("#### ") {
                if let item = currentItem {
                    workItems.append(item)
                }
                
                currentItem = JournalWorkItem()
                
                let headerContent = trimmedLine.replacingOccurrences(of: "#### ", with: "")
                let components = headerContent.components(separatedBy: " - ")
                
                var newItem = JournalWorkItem()
                if components.count >= 1 {
                    newItem.title = components[0]
                }
                if components.count >= 2 {
                    newItem.status = components[1]
                }
                if components.count >= 3 {
                    newItem.priority = components[2]
                }
                
                currentItem = newItem
            } else if currentItem != nil && !trimmedLine.isEmpty {
                guard var updatedItem = currentItem else { continue }
                updatedItem.description = trimmedLine
                currentItem = updatedItem
            }
        }
        
        if let item = currentItem {
            workItems.append(item)
        }
        
        return workItems
    }
    
    private static func parseMeetings(_ content: String) -> [JournalMeeting] {
        var meetings: [JournalMeeting] = []
        let lines = content.components(separatedBy: .newlines)
        
        var currentMeeting: JournalMeeting?
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.hasPrefix("#### ") {
                if let meeting = currentMeeting {
                    meetings.append(meeting)
                }
                
                currentMeeting = JournalMeeting()
                currentMeeting?.title = trimmedLine.replacingOccurrences(of: "#### ", with: "")
            } else if currentMeeting != nil {
                guard var updatedMeeting = currentMeeting else { continue }
                
                if trimmedLine.hasPrefix("Attendees: ") {
                    updatedMeeting.attendees = trimmedLine.replacingOccurrences(of: "Attendees: ", with: "")
                } else if trimmedLine.hasPrefix("Notes: ") {
                    updatedMeeting.notes = trimmedLine.replacingOccurrences(of: "Notes: ", with: "")
                } else if trimmedLine.hasPrefix("Action Items: ") {
                    updatedMeeting.actionItems = trimmedLine.replacingOccurrences(of: "Action Items: ", with: "")
                }
                
                currentMeeting = updatedMeeting
            }
        }
        
        if let meeting = currentMeeting {
            meetings.append(meeting)
        }
        
        return meetings
    }
}

struct JournalWorkItem: Equatable {
    var title: String = ""
    var status: String = ""
    var priority: String = ""
    var description: String = ""
    
    func toMarkdown() -> String {
        var markdown = "#### \(title) - \(status) - \(priority)\n"
        markdown += "    \(description)\n\n"
        return markdown
    }
}

struct JournalMeeting: Equatable {
    var title: String = ""
    var attendees: String = ""
    var notes: String = ""
    var actionItems: String = ""
    
    func toMarkdown() -> String {
        var markdown = "#### \(title)\n"
        markdown += "    Attendees: \(attendees)\n"
        markdown += "    Notes: \(notes)\n"
        markdown += "    Action Items: \(actionItems)\n\n"
        return markdown
    }
}

private func parseSubsections(_ markdown: String) -> [(String, String)] {
    var subsections: [(String, String)] = []
    let lines = markdown.components(separatedBy: .newlines)
    
    var currentSubsectionTitle: String?
    var currentSubsectionContent: [String] = []
    
    for line in lines {
        if line.hasPrefix("### ") {
            if let title = currentSubsectionTitle, !currentSubsectionContent.isEmpty {
                subsections.append((title, currentSubsectionContent.joined(separator: "\n")))
                currentSubsectionContent = []
            }
            
            currentSubsectionTitle = line.replacingOccurrences(of: "### ", with: "")
        } else if currentSubsectionTitle != nil {
            currentSubsectionContent.append(line)
        }
    }
    
    if let title = currentSubsectionTitle, !currentSubsectionContent.isEmpty {
        subsections.append((title, currentSubsectionContent.joined(separator: "\n")))
    }
    
    return subsections
}
