import SwiftUI

struct JournalEntryView: View {
    
    @Bindable var viewModel: JournalViewModel
    
    
    @State private var dailyCheckInViewModel = DailyCheckInViewModel()
    @State private var personalGrowthViewModel = PersonalGrowthViewModel()
    @State private var wellbeingViewModel = WellbeingViewModel()
    @State private var creativityLearningViewModel = CreativityLearningViewModel()
    @State private var socialViewModel = SocialViewModel()
    @State private var workCareerViewModel = WorkCareerViewModel()
    
    
    @State private var selectedTab: JournalSection = .dailyCheckIn
    @State private var refreshKey = UUID()
    @FocusState private var isTextFieldFocused: Bool
    
    
    var body: some View {
        VStack(spacing: 0) {
            if let date = viewModel.selectedDate {
                contentView(for: date)
            } else {
                EmptyStateView {
                    viewModel.openTodaysEntry()
                }
            }
        }
        .onChange(of: viewModel.fileContent) { _, _ in refreshFromJournal() }
        .onChange(of: viewModel.isDirty) { _, _ in }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    
    private func contentView(for date: Date) -> some View {
        VStack(spacing: 0) {
            DateHeaderView(date: date)
                .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
            
            VStack(spacing: 0) {
                SectionTabBar(selectedTab: $selectedTab)
                    .padding()
                
                ScrollView {
                    VStack(spacing: 20) {
                        sectionView
                    }
                    .padding(EdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 8))
                    .id("\(date.timeIntervalSince1970)-\(refreshKey)")
                }
                
                statusBar
            }
        }
        .onAppear {
            viewModel.loadContent(for: date)
            refreshFromJournal()
            viewModel.startAutoSaveTimer()
        }
        .onChange(of: date) { _, newValue in
            viewModel.loadContent(for: newValue)
            refreshFromJournal()
        }
    }
    
    
    @ViewBuilder
    private var sectionView: some View {
        switch selectedTab {
        case .dailyCheckIn:
            DailyCheckInView(viewModel: dailyCheckInViewModel)
                .onChange(of: dailyCheckInViewModel.dailyOverview) { _, _ in updateJournalFromDailyCheckIn() }
                .onChange(of: dailyCheckInViewModel.todaysHighlight) { _, _ in updateJournalFromDailyCheckIn() }
                .onChange(of: dailyCheckInViewModel.mood) { _, _ in updateJournalFromDailyCheckIn() }
            
        case .personalGrowth:
            PersonalGrowthView(viewModel: personalGrowthViewModel)
                .onChange(of: personalGrowthViewModel.reflections) { _, _ in updateJournalFromPersonalGrowth() }
                .onChange(of: personalGrowthViewModel.achievements) { _, _ in updateJournalFromPersonalGrowth() }
                .onChange(of: personalGrowthViewModel.challenges) { _, _ in updateJournalFromPersonalGrowth() }
                .onChange(of: personalGrowthViewModel.goals) { _, _ in updateJournalFromPersonalGrowth() }
            
        case .wellbeing:
            WellbeingView(viewModel: wellbeingViewModel)
                .onChange(of: wellbeingViewModel.energyLevel) { _, _ in updateJournalFromWellbeing() }
                .onChange(of: wellbeingViewModel.physicalActivity) { _, _ in updateJournalFromWellbeing() }
                .onChange(of: wellbeingViewModel.mentalHealth) { _, _ in updateJournalFromWellbeing() }
            
        case .creativityLearning:
            CreativityLearningView(viewModel: creativityLearningViewModel)
                .onChange(of: creativityLearningViewModel.ideas) { _, _ in updateJournalFromCreativityLearning() }
                .onChange(of: creativityLearningViewModel.learningLog) { _, _ in updateJournalFromCreativityLearning() }
                .onChange(of: creativityLearningViewModel.projects) { _, _ in updateJournalFromCreativityLearning() }
                .onChange(of: creativityLearningViewModel.showingAddMedia) { _, _ in updateJournalFromCreativityLearning() }
            
        case .social:
            SocialView(viewModel: socialViewModel)
                .onChange(of: socialViewModel.showingAddInteraction) { _, _ in updateJournalFromSocial() }
                .onChange(of: socialViewModel.relationshipUpdates) { _, _ in updateJournalFromSocial() }
                .onChange(of: socialViewModel.socialEvents) { _, _ in updateJournalFromSocial() }
            
        case .workCareer:
            WorkCareerView(viewModel: workCareerViewModel)
                .onChange(of: workCareerViewModel.showingAddWorkItem) { _, _ in updateJournalFromWorkCareer() }
                .onChange(of: workCareerViewModel.showingAddMeeting) { _, _ in updateJournalFromWorkCareer() }
                .onChange(of: workCareerViewModel.challenges) { _, _ in updateJournalFromWorkCareer() }
                .onChange(of: workCareerViewModel.achievements) { _, _ in updateJournalFromWorkCareer() }
                .onChange(of: workCareerViewModel.ideas) { _, _ in updateJournalFromWorkCareer() }
        }
    }
    
    
    private var statusBar: some View {
        HStack {
            Text(viewModel.isDirty ? "Unsaved changes" : "No changes")
                .foregroundStyle(viewModel.isDirty ? .orange : .gray)
                .font(.footnote)
                .padding(.leading)
            
            Spacer()
            
            Button("Save Changes") {
                Task {
                    do {
                        saveCurrentSection()
                        try await viewModel.saveEdits()
                    } catch {
                        
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.isDirty)
            .padding()
        }
    }
    
    
    
    
    private func refreshFromJournal() {
        updateDailyCheckInFromJournal()
        updatePersonalGrowthFromJournal()
        updateWellbeingFromJournal()
        updateCreativityLearningFromJournal()
        updateSocialFromJournal()
        updateWorkCareerFromJournal()
        refreshKey = UUID()
    }
    
    
    private func saveCurrentSection() {
        switch selectedTab {
        case .dailyCheckIn: updateJournalFromDailyCheckIn()
        case .personalGrowth: updateJournalFromPersonalGrowth()
        case .wellbeing: updateJournalFromWellbeing()
        case .creativityLearning: updateJournalFromCreativityLearning()
        case .social: updateJournalFromSocial()
        case .workCareer: updateJournalFromWorkCareer()
        }
    }
    
    
    
    private func updateDailyCheckInFromJournal() {
        guard let entry = viewModel.currentEntry else { return }
        dailyCheckInViewModel.mood = entry.dailyCheckIn.mood.isEmpty ? "Good" : entry.dailyCheckIn.mood
        dailyCheckInViewModel.todaysHighlight = entry.dailyCheckIn.todaysHighlight
        dailyCheckInViewModel.dailyOverview = entry.dailyCheckIn.dailyOverview
    }
    
    private func updateJournalFromDailyCheckIn() {
        guard var entry = viewModel.currentEntry else { return }
        entry.dailyCheckIn.mood = dailyCheckInViewModel.mood
        entry.dailyCheckIn.todaysHighlight = dailyCheckInViewModel.todaysHighlight
        entry.dailyCheckIn.dailyOverview = dailyCheckInViewModel.dailyOverview
        viewModel.updateEntrySection(entry)
    }
    
    
    
    private func updatePersonalGrowthFromJournal() {
        guard let entry = viewModel.currentEntry else { return }
        personalGrowthViewModel.reflections = entry.personalGrowth.reflections
        personalGrowthViewModel.achievements = entry.personalGrowth.achievements
        personalGrowthViewModel.challenges = entry.personalGrowth.challenges
        personalGrowthViewModel.goals = entry.personalGrowth.goals
    }
    
    private func updateJournalFromPersonalGrowth() {
        guard var entry = viewModel.currentEntry else { return }
        entry.personalGrowth.reflections = personalGrowthViewModel.reflections
        entry.personalGrowth.achievements = personalGrowthViewModel.achievements
        entry.personalGrowth.challenges = personalGrowthViewModel.challenges
        entry.personalGrowth.goals = personalGrowthViewModel.goals
        viewModel.updateEntrySection(entry)
    }
    
    
    
    private func updateWellbeingFromJournal() {
        guard let entry = viewModel.currentEntry else { return }
        wellbeingViewModel.energyLevel = entry.wellbeing.energyLevel
        wellbeingViewModel.physicalActivity = entry.wellbeing.physicalActivity
        wellbeingViewModel.mentalHealth = entry.wellbeing.mentalHealth
    }
    
    private func updateJournalFromWellbeing() {
        guard var entry = viewModel.currentEntry else { return }
        entry.wellbeing.energyLevel = wellbeingViewModel.energyLevel
        entry.wellbeing.physicalActivity = wellbeingViewModel.physicalActivity
        entry.wellbeing.mentalHealth = wellbeingViewModel.mentalHealth
        viewModel.updateEntrySection(entry)
    }
    
    
    
    private func updateCreativityLearningFromJournal() {
        guard let entry = viewModel.currentEntry else { return }
        creativityLearningViewModel.projects = entry.creativityLearning.projects
        creativityLearningViewModel.learningLog = entry.creativityLearning.learningLog
        creativityLearningViewModel.ideas = entry.creativityLearning.ideas
    }
    
    private func updateJournalFromCreativityLearning() {
        guard var entry = viewModel.currentEntry else { return }
        entry.creativityLearning.projects = creativityLearningViewModel.projects
        entry.creativityLearning.learningLog = creativityLearningViewModel.learningLog
        entry.creativityLearning.ideas = creativityLearningViewModel.ideas
        viewModel.updateEntrySection(entry)
    }
    
    
    
    private func updateSocialFromJournal() {
        guard let entry = viewModel.currentEntry else { return }
        socialViewModel.meaningfulInteractions = entry.social.meaningfulInteractions
        socialViewModel.relationshipUpdates = entry.social.relationshipUpdates
        socialViewModel.socialEvents = entry.social.socialEvents
    }
    
    private func updateJournalFromSocial() {
        guard var entry = viewModel.currentEntry else { return }
        entry.social.meaningfulInteractions = socialViewModel.meaningfulInteractions
        entry.social.relationshipUpdates = socialViewModel.relationshipUpdates
        entry.social.socialEvents = socialViewModel.socialEvents
        viewModel.updateEntrySection(entry)
    }
    
    
    
    private func updateWorkCareerFromJournal() {
        guard let entry = viewModel.currentEntry else { return }
        workCareerViewModel.achievements = entry.workCareer.wins
        workCareerViewModel.challenges = entry.workCareer.challenges
        workCareerViewModel.ideas = entry.workCareer.workIdeas
        workCareerViewModel.items = entry.workCareer.workItems
        workCareerViewModel.meetings = entry.workCareer.meetings
    }
    
    private func updateJournalFromWorkCareer() {
        guard var entry = viewModel.currentEntry else { return }
        entry.workCareer.wins = workCareerViewModel.achievements
        entry.workCareer.challenges = workCareerViewModel.challenges
        entry.workCareer.workIdeas = workCareerViewModel.ideas
        entry.workCareer.workItems = workCareerViewModel.items
        entry.workCareer.meetings = workCareerViewModel.meetings
        viewModel.updateEntrySection(entry)
    }
}
