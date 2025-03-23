import SwiftUI

struct GeneratedEntryPreviewView: View {
    @Bindable var viewModel: VoiceAssistantViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var generatedEntry: JournalEntry?
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Preview Generated Content")
                .font(.title3)
                .fontWeight(.semibold)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if let entry = generatedEntry {
                        let sectionsToShow = getVisibleSections(entry)
                        ForEach(sectionsToShow.indices, id: \.self) { index in
                            let (section, isNew) = sectionsToShow[index]
                            SectionView(
                                title: section.title,
                                isNew: isNew,
                                content: section.content
                            )
                        }
                        
                        if sectionsToShow.isEmpty {
                            VStack(alignment: .center, spacing: 12) {
                                Image(systemName: "checkmark.circle")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary)
                                
                                Text("No Content Generated")
                                    .font(.headline)
                                
                                Text("The voice recording didn't produce any journal content.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                    }
                }
                .padding()
            }
            .background(Color(NSColor.textBackgroundColor))
            .cornerRadius(8)
            .frame(maxHeight: 300)
            
            HStack {
                Button("Reject") {
                    viewModel.rejectGeneratedContent()
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Accept") {
                    viewModel.acceptGeneratedContent(mergeStrategy: .replace)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            parseGeneratedContent()
        }
    }
    
    private func parseGeneratedContent() {
        if let date = viewModel.journalViewModel.selectedDate ?? viewModel.journalViewModel.currentEntry?.date {
            generatedEntry = JournalEntry(fromMarkdown: viewModel.generatedContent, date: date)
        }
    }
    
    private func isEmptySection(_ section: Any) -> Bool {
        // Use mirror to check if the section has an isEmpty property
        let mirror = Mirror(reflecting: section)
        if let isEmpty = mirror.children.first(where: { $0.label == "isEmpty" })?.value as? Bool {
            return isEmpty
        }
        return false
    }
    
    private func getVisibleSections(_ entry: JournalEntry) -> [(SectionData, Bool)] {
        var sections: [(SectionData, Bool)] = []
        let currentEntry = viewModel.journalViewModel.currentEntry
        
        // Daily Check-in
        if !isEmptySection(entry.dailyCheckIn) {
            sections.append((
                SectionData(
                    title: "Daily Check-in",
                    content: [
                        entry.dailyCheckIn.mood.isEmpty ? nil : ("Mood", entry.dailyCheckIn.mood),
                        entry.dailyCheckIn.todaysHighlight.isEmpty ? nil : ("Today's Highlight", entry.dailyCheckIn.todaysHighlight),
                        entry.dailyCheckIn.dailyOverview.isEmpty ? nil : ("Daily Overview", entry.dailyCheckIn.dailyOverview)
                    ].compactMap { $0 }
                ),
                currentEntry?.dailyCheckIn.isEmpty ?? true
            ))
        }
        
        // Personal Growth
        if !isEmptySection(entry.personalGrowth) {
            sections.append((
                SectionData(
                    title: "Personal Growth",
                    content: [
                        entry.personalGrowth.reflections.isEmpty ? nil : ("Reflections", entry.personalGrowth.reflections),
                        entry.personalGrowth.achievements.isEmpty ? nil : ("Achievements", entry.personalGrowth.achievements),
                        entry.personalGrowth.challenges.isEmpty ? nil : ("Challenges", entry.personalGrowth.challenges),
                        entry.personalGrowth.goals.isEmpty ? nil : ("Goals", entry.personalGrowth.goals)
                    ].compactMap { $0 }
                ),
                currentEntry?.personalGrowth.isEmpty ?? true
            ))
        }
        
        // Wellbeing
        if !isEmptySection(entry.wellbeing) {
            sections.append((
                SectionData(
                    title: "Wellbeing",
                    content: [
                        ("Energy Level", "\(entry.wellbeing.energyLevel)/10"),
                        entry.wellbeing.physicalActivity.isEmpty ? nil : ("Physical Activity", entry.wellbeing.physicalActivity),
                        entry.wellbeing.mentalHealth.isEmpty ? nil : ("Mental Health", entry.wellbeing.mentalHealth),
                        entry.wellbeing.sleepQuality.isEmpty ? nil : ("Sleep Quality", entry.wellbeing.sleepQuality),
                        entry.wellbeing.nutrition.isEmpty ? nil : ("Nutrition", entry.wellbeing.nutrition)
                    ].compactMap { $0 }
                ),
                currentEntry?.wellbeing.isEmpty ?? true
            ))
        }
        
        // Creativity & Learning
        if !isEmptySection(entry.creativityLearning) {
            sections.append((
                SectionData(
                    title: "Creativity & Learning",
                    content: [
                        entry.creativityLearning.ideas.isEmpty ? nil : ("Ideas", entry.creativityLearning.ideas),
                        entry.creativityLearning.learningLog.isEmpty ? nil : ("Learning Log", entry.creativityLearning.learningLog),
                        entry.creativityLearning.projects.isEmpty ? nil : ("Projects", entry.creativityLearning.projects)
                    ].compactMap { $0 }
                ),
                currentEntry?.creativityLearning.isEmpty ?? true
            ))
        }
        
        // Social
        if !isEmptySection(entry.social) {
            sections.append((
                SectionData(
                    title: "Social",
                    content: [
                        entry.social.relationshipUpdates.isEmpty ? nil : ("Relationship Updates", entry.social.relationshipUpdates),
                        entry.social.socialEvents.isEmpty ? nil : ("Social Events", entry.social.socialEvents)
                    ].compactMap { $0 }
                ),
                currentEntry?.social.isEmpty ?? true
            ))
        }
        
        // Work & Career
        if !isEmptySection(entry.workCareer) {
            sections.append((
                SectionData(
                    title: "Work & Career",
                    content: [
                        entry.workCareer.challenges.isEmpty ? nil : ("Challenges", entry.workCareer.challenges),
                        entry.workCareer.wins.isEmpty ? nil : ("Wins", entry.workCareer.wins),
                        entry.workCareer.workIdeas.isEmpty ? nil : ("Work Ideas", entry.workCareer.workIdeas)
                    ].compactMap { $0 }
                ),
                currentEntry?.workCareer.isEmpty ?? true
            ))
        }
        
        return sections
    }
}

// Data structure for section content
struct SectionData: Hashable {
    let title: String
    let content: [(String, String)] // (label, value)
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        // We need to hash the content too since it defines uniqueness
        for (label, value) in content {
            hasher.combine(label)
            hasher.combine(value)
        }
    }
    
    static func == (lhs: SectionData, rhs: SectionData) -> Bool {
        if lhs.title != rhs.title || lhs.content.count != rhs.content.count {
            return false
        }
        
        for i in 0..<lhs.content.count {
            if lhs.content[i].0 != rhs.content[i].0 || lhs.content[i].1 != rhs.content[i].1 {
                return false
            }
        }
        
        return true
    }
}

// Section view component
struct SectionView: View {
    let title: String
    let isNew: Bool
    let content: [(String, String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                
                if isNew {
                    Text("New")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                } else {
                    Text("Updated")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
            }
            
            Divider()
            
            ForEach(content, id: \.0) { label, value in
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(value)
                        .font(.body)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

#Preview {
    GeneratedEntryPreviewView(
        viewModel: VoiceAssistantViewModel(
            voiceRecordingService: VoiceRecordingService(),
            openAIService: OpenAIService(apiKey: "preview-key"),
            settingsManager: AppSettingsManager(),
            journalViewModel: JournalViewModel()
        )
    )
}
