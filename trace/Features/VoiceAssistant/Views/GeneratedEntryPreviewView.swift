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
        let mirror = Mirror(reflecting: section)
        if let isEmpty = mirror.children.first(where: { $0.label == "isEmpty" })?.value as? Bool {
            return isEmpty
        }
        return false
    }
    
    private func getVisibleSections(_ entry: JournalEntry) -> [(SectionData, Bool)] {
        var sections: [(SectionData, Bool)] = []
        
        if !entry.dailyCheckIn.isEmpty {
            sections.append((
                SectionData(
                    title: "Daily Check-in",
                    content: [
                        entry.dailyCheckIn.mood.isEmpty ? nil : ("Mood", entry.dailyCheckIn.mood),
                        entry.dailyCheckIn.todaysHighlight.isEmpty ? nil : ("Today's Highlight", entry.dailyCheckIn.todaysHighlight),
                        entry.dailyCheckIn.dailyOverview.isEmpty ? nil : ("Daily Overview", entry.dailyCheckIn.dailyOverview)
                    ].compactMap { $0 }
                ),
                false
            ))
        }
        
        if !entry.personalGrowth.isEmpty {
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
                false
            ))
        }
        
        if !entry.wellbeing.isEmpty {
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
                false
            ))
        }
        
        if !entry.creativityLearning.isEmpty {
            sections.append((
                SectionData(
                    title: "Creativity & Learning",
                    content: [
                        entry.creativityLearning.ideas.isEmpty ? nil : ("Ideas", entry.creativityLearning.ideas),
                        entry.creativityLearning.learningLog.isEmpty ? nil : ("Learning Log", entry.creativityLearning.learningLog),
                        entry.creativityLearning.projects.isEmpty ? nil : ("Projects", entry.creativityLearning.projects)
                    ].compactMap { $0 }
                ),
                false
            ))
        }
        
        if !entry.social.isEmpty {
            sections.append((
                SectionData(
                    title: "Social",
                    content: [
                        entry.social.relationshipUpdates.isEmpty ? nil : ("Relationship Updates", entry.social.relationshipUpdates),
                        entry.social.socialEvents.isEmpty ? nil : ("Social Events", entry.social.socialEvents)
                    ].compactMap { $0 }
                ),
                false
            ))
        }
        
        if !entry.workCareer.isEmpty {
            sections.append((
                SectionData(
                    title: "Work & Career",
                    content: [
                        entry.workCareer.challenges.isEmpty ? nil : ("Challenges", entry.workCareer.challenges),
                        entry.workCareer.wins.isEmpty ? nil : ("Wins", entry.workCareer.wins),
                        entry.workCareer.workIdeas.isEmpty ? nil : ("Work Ideas", entry.workCareer.workIdeas)
                    ].compactMap { $0 }
                ),
                false
            ))
        }
        
        return sections
    }
}

struct SectionData: Hashable {
    let title: String
    let content: [(String, String)]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
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

struct SectionView: View {
    let title: String
    let isNew: Bool
    let content: [(String, String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
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
