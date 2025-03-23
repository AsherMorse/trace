import Foundation
import SwiftUI

extension JournalViewModel {
    func updateSectionViewModels() -> (CreativityLearningViewModel, SocialViewModel, WorkCareerViewModel) {
        guard let entry = currentEntry else {
            return (
                CreativityLearningViewModel(journalViewModel: self),
                SocialViewModel(journalViewModel: self),
                WorkCareerViewModel(journalViewModel: self)
            )
        }
        
        return (
            CreativityLearningViewModel(entry: entry.creativityLearning, journalViewModel: self),
            SocialViewModel(entry: entry.social, journalViewModel: self),
            WorkCareerViewModel(entry: entry.workCareer, journalViewModel: self)
        )
    }
    enum ContentMergeStrategy {
        case replace
        case append
        case intelligentMerge
    }
    
    func applyAIGeneratedContent(_ content: String, for date: Date, strategy: ContentMergeStrategy = .intelligentMerge) throws {
        guard !content.isEmpty else { return }
        
        
        switch strategy {
        case .replace:
            try createOrUpdateEntry(content, for: date, append: false)
            
        case .append:
            if currentEntry != nil {
                try createOrUpdateEntry(content, for: date, append: true)
            } else {
                try createOrUpdateEntry(content, for: date, append: false)
            }
            
        case .intelligentMerge:
            if let existingEntry = currentEntry {
                let existingContent = existingEntry.toMarkdown()
                let merged = mergeMarkdownContent(existingContent, content)
                try createOrUpdateEntry(merged, for: date, append: false)
            } else {
                try createOrUpdateEntry(content, for: date, append: false)
            }
        }
        
        isDirty = true
    }
    
    private func createOrUpdateEntry(_ markdown: String, for date: Date, append: Bool) throws {
        if let currentEntry = currentEntry, append {
            let combinedMarkdown = currentEntry.toMarkdown() + "\n\n" + markdown
            editedContent = combinedMarkdown
            if let entry = JournalEntry(fromMarkdown: combinedMarkdown, date: date) {
                self.currentEntry = entry
                self.isDirty = fileContent != editedContent
            }
        } else {
            editedContent = markdown
            if let entry = JournalEntry(fromMarkdown: markdown, date: date) {
                self.currentEntry = entry
                self.isDirty = fileContent != editedContent
            }
        }
    }
    
    private func mergeMarkdownContent(_ original: String, _ new: String) -> String {
        let originalSections = extractMarkdownSections(original)
        let newSections = extractMarkdownSections(new)
        
        var result = "# Journal Entry: \(currentEntry?.formattedDate ?? "")\n\n"
        
        let allSectionTitles = Set(originalSections.keys).union(Set(newSections.keys))
        
        for sectionTitle in allSectionTitles.sorted() {
            if let originalSection = originalSections[sectionTitle], 
               let newSection = newSections[sectionTitle] {
                result += "## \(sectionTitle)\n\n"
                result += mergeSectionContent(originalSection, newSection, sectionTitle)
            } else if let originalSection = originalSections[sectionTitle] {
                result += "## \(sectionTitle)\n\n"
                result += originalSection
            } else if let newSection = newSections[sectionTitle] {
                result += "## \(sectionTitle)\n\n"
                result += newSection
            }
        }
        
        return result
    }
    
    private func extractMarkdownSections(_ markdown: String) -> [String: String] {
        var sections = [String: String]()
        let lines = markdown.components(separatedBy: .newlines)
        
        var currentSection = ""
        var currentContent = [String]()
        
        for line in lines {
            if line.hasPrefix("## ") {
                if !currentSection.isEmpty && !currentContent.isEmpty {
                    sections[currentSection] = currentContent.joined(separator: "\n")
                }
                
                currentSection = line.replacingOccurrences(of: "## ", with: "")
                currentContent = []
            } else if !currentSection.isEmpty {
                currentContent.append(line)
            }
        }
        
        if !currentSection.isEmpty && !currentContent.isEmpty {
            sections[currentSection] = currentContent.joined(separator: "\n")
        }
        
        return sections
    }
    
    private func mergeSectionContent(_ original: String, _ new: String, _ sectionTitle: String) -> String {
        if sectionTitle == "Social" || sectionTitle == "Work & Career" || sectionTitle == "Creativity & Learning" {
            return original
        }
        
        if new.count > 20 && !original.contains(new) {
            return original + "\n\n" + new
        }
        
        return original
    }
    
    private func appendEntries(_ existing: JournalEntry, _ new: JournalEntry) -> JournalEntry {
        var merged = existing
        
        if !new.dailyCheckIn.mood.isEmpty {
            merged.dailyCheckIn.mood += new.dailyCheckIn.mood.isEmpty ? "" : "\n\n" + new.dailyCheckIn.mood
        }
        if !new.dailyCheckIn.todaysHighlight.isEmpty {
            merged.dailyCheckIn.todaysHighlight += new.dailyCheckIn.todaysHighlight.isEmpty ? "" : "\n\n" + new.dailyCheckIn.todaysHighlight
        }
        if !new.dailyCheckIn.dailyOverview.isEmpty {
            merged.dailyCheckIn.dailyOverview += new.dailyCheckIn.dailyOverview.isEmpty ? "" : "\n\n" + new.dailyCheckIn.dailyOverview
        }
        
        if !new.personalGrowth.reflections.isEmpty {
            merged.personalGrowth.reflections += new.personalGrowth.reflections.isEmpty ? "" : "\n\n" + new.personalGrowth.reflections
        }
        if !new.personalGrowth.achievements.isEmpty {
            merged.personalGrowth.achievements += new.personalGrowth.achievements.isEmpty ? "" : "\n\n" + new.personalGrowth.achievements
        }
        if !new.personalGrowth.challenges.isEmpty {
            merged.personalGrowth.challenges += new.personalGrowth.challenges.isEmpty ? "" : "\n\n" + new.personalGrowth.challenges
        }
        if !new.personalGrowth.goals.isEmpty {
            merged.personalGrowth.goals += new.personalGrowth.goals.isEmpty ? "" : "\n\n" + new.personalGrowth.goals
        }
        
        if !new.wellbeing.physicalActivity.isEmpty {
            merged.wellbeing.physicalActivity += new.wellbeing.physicalActivity.isEmpty ? "" : "\n\n" + new.wellbeing.physicalActivity
        }
        if !new.wellbeing.mentalHealth.isEmpty {
            merged.wellbeing.mentalHealth += new.wellbeing.mentalHealth.isEmpty ? "" : "\n\n" + new.wellbeing.mentalHealth
        }
        
        if !new.creativityLearning.ideas.isEmpty {
            merged.creativityLearning.ideas += new.creativityLearning.ideas.isEmpty ? "" : "\n\n" + new.creativityLearning.ideas
        }
        if !new.creativityLearning.learningLog.isEmpty {
            merged.creativityLearning.learningLog += new.creativityLearning.learningLog.isEmpty ? "" : "\n\n" + new.creativityLearning.learningLog
        }
        if !new.creativityLearning.projects.isEmpty {
            merged.creativityLearning.projects += new.creativityLearning.projects.isEmpty ? "" : "\n\n" + new.creativityLearning.projects
        }
        merged.creativityLearning.booksMedia.append(contentsOf: new.creativityLearning.booksMedia)
        
        if !new.social.relationshipUpdates.isEmpty {
            merged.social.relationshipUpdates += new.social.relationshipUpdates.isEmpty ? "" : "\n\n" + new.social.relationshipUpdates
        }
        if !new.social.socialEvents.isEmpty {
            merged.social.socialEvents += new.social.socialEvents.isEmpty ? "" : "\n\n" + new.social.socialEvents
        }
        merged.social.meaningfulInteractions.append(contentsOf: new.social.meaningfulInteractions)
        
        if !new.workCareer.challenges.isEmpty {
            merged.workCareer.challenges += new.workCareer.challenges.isEmpty ? "" : "\n\n" + new.workCareer.challenges
        }
        if !new.workCareer.wins.isEmpty {
            merged.workCareer.wins += new.workCareer.wins.isEmpty ? "" : "\n\n" + new.workCareer.wins
        }
        if !new.workCareer.workIdeas.isEmpty {
            merged.workCareer.workIdeas += new.workCareer.workIdeas.isEmpty ? "" : "\n\n" + new.workCareer.workIdeas
        }
        merged.workCareer.workItems.append(contentsOf: new.workCareer.workItems)
        merged.workCareer.meetings.append(contentsOf: new.workCareer.meetings)
        
        return merged
    }
    
    private func intelligentlyMergeEntries(_ existing: JournalEntry, _ new: JournalEntry) -> JournalEntry {
        var merged = existing
        
        if !existing.dailyCheckIn.mood.isEmpty && !new.dailyCheckIn.mood.isEmpty {
            merged.dailyCheckIn.mood = new.dailyCheckIn.mood
        } else if !new.dailyCheckIn.mood.isEmpty {
            merged.dailyCheckIn.mood = new.dailyCheckIn.mood
        }
        
        if !existing.dailyCheckIn.todaysHighlight.contains(new.dailyCheckIn.todaysHighlight) && !new.dailyCheckIn.todaysHighlight.isEmpty {
            merged.dailyCheckIn.todaysHighlight += new.dailyCheckIn.todaysHighlight.isEmpty ? "" : "\n\n" + new.dailyCheckIn.todaysHighlight
        }
        
        if !existing.dailyCheckIn.dailyOverview.contains(new.dailyCheckIn.dailyOverview) && !new.dailyCheckIn.dailyOverview.isEmpty {
            merged.dailyCheckIn.dailyOverview += new.dailyCheckIn.dailyOverview.isEmpty ? "" : "\n\n" + new.dailyCheckIn.dailyOverview
        }
        
        if !existing.personalGrowth.reflections.contains(new.personalGrowth.reflections) && !new.personalGrowth.reflections.isEmpty {
            merged.personalGrowth.reflections += new.personalGrowth.reflections.isEmpty ? "" : "\n\n" + new.personalGrowth.reflections
        }
        
        if !existing.personalGrowth.achievements.contains(new.personalGrowth.achievements) && !new.personalGrowth.achievements.isEmpty {
            merged.personalGrowth.achievements += new.personalGrowth.achievements.isEmpty ? "" : "\n\n" + new.personalGrowth.achievements
        }
        
        if !existing.personalGrowth.challenges.contains(new.personalGrowth.challenges) && !new.personalGrowth.challenges.isEmpty {
            merged.personalGrowth.challenges += new.personalGrowth.challenges.isEmpty ? "" : "\n\n" + new.personalGrowth.challenges
        }
        
        for newMediaItem in new.creativityLearning.booksMedia {
            if !merged.creativityLearning.booksMedia.contains(where: { $0.title == newMediaItem.title }) {
                merged.creativityLearning.booksMedia.append(newMediaItem)
            }
        }
        
        for newInteraction in new.social.meaningfulInteractions {
            if !merged.social.meaningfulInteractions.contains(where: { $0.person == newInteraction.person }) {
                merged.social.meaningfulInteractions.append(newInteraction)
            }
        }
        
        
        return merged
    }
    
    var canUseAIAssistant: Bool {
        FolderManager.shared.hasSelectedFolder && selectedDate != nil
    }
} 
