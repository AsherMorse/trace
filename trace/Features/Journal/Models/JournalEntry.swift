import Foundation

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

// MARK: - Section Models

struct JournalDailyCheckIn {
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
}

struct JournalPersonalGrowth {
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
}

struct JournalWellbeing {
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
}

struct JournalCreativityLearning {
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
}

struct JournalMediaItem {
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

struct JournalSocial {
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
}

struct JournalInteraction {
    var person: String = ""
    var notes: String = ""
    
    func toMarkdown() -> String {
        var markdown = "#### \(person)\n"
        markdown += "    Notes: \(notes)\n\n"
        return markdown
    }
}

struct JournalWorkCareer {
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
}

struct JournalWorkItem {
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

struct JournalMeeting {
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