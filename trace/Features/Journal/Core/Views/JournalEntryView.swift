import SwiftUI

struct JournalEntryView: View {
    
    @Bindable var viewModel: JournalViewModel
    
    
    @State private var dailyCheckInVM = DailyCheckInViewModel()
    @State private var personalGrowthVM = PersonalGrowthViewModel()
    @State private var wellbeingVM = WellbeingViewModel()
    @State private var creativityLearningVM = CreativityLearningViewModel()
    @State private var socialVM = SocialViewModel()
    @State private var workCareerVM = WorkCareerViewModel()
    
    
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
            DailyCheckInView(viewModel: dailyCheckInVM)
                .onChange(of: dailyCheckInVM.dailyOverview) { _, _ in updateJournalFromDailyCheckIn() }
                .onChange(of: dailyCheckInVM.todaysHighlight) { _, _ in updateJournalFromDailyCheckIn() }
                .onChange(of: dailyCheckInVM.mood) { _, _ in updateJournalFromDailyCheckIn() }
            
        case .personalGrowth:
            PersonalGrowthView(viewModel: personalGrowthVM)
                .onChange(of: personalGrowthVM.reflections) { _, _ in updateJournalFromPersonalGrowth() }
                .onChange(of: personalGrowthVM.achievements) { _, _ in updateJournalFromPersonalGrowth() }
                .onChange(of: personalGrowthVM.challenges) { _, _ in updateJournalFromPersonalGrowth() }
                .onChange(of: personalGrowthVM.goals) { _, _ in updateJournalFromPersonalGrowth() }
            
        case .wellbeing:
            WellbeingView(viewModel: wellbeingVM)
                .onChange(of: wellbeingVM.energyLevel) { _, _ in updateJournalFromWellbeing() }
                .onChange(of: wellbeingVM.physicalActivity) { _, _ in updateJournalFromWellbeing() }
                .onChange(of: wellbeingVM.mentalHealth) { _, _ in updateJournalFromWellbeing() }
            
        case .creativityLearning:
            CreativityLearningView(viewModel: creativityLearningVM)
                .onChange(of: creativityLearningVM.ideas) { _, _ in updateJournalFromCreativityLearning() }
                .onChange(of: creativityLearningVM.learningLog) { _, _ in updateJournalFromCreativityLearning() }
                .onChange(of: creativityLearningVM.projects) { _, _ in updateJournalFromCreativityLearning() }
                .onChange(of: creativityLearningVM.showingAddMedia) { _, _ in updateJournalFromCreativityLearning() }
            
        case .social:
            SocialView(viewModel: socialVM)
                .onChange(of: socialVM.showingAddInteraction) { _, _ in updateJournalFromSocial() }
                .onChange(of: socialVM.relationshipUpdates) { _, _ in updateJournalFromSocial() }
                .onChange(of: socialVM.socialEvents) { _, _ in updateJournalFromSocial() }
            
        case .workCareer:
            WorkCareerView(viewModel: workCareerVM)
                .onChange(of: workCareerVM.showingAddWorkItem) { _, _ in updateJournalFromWorkCareer() }
                .onChange(of: workCareerVM.showingAddMeeting) { _, _ in updateJournalFromWorkCareer() }
                .onChange(of: workCareerVM.challenges) { _, _ in updateJournalFromWorkCareer() }
                .onChange(of: workCareerVM.achievements) { _, _ in updateJournalFromWorkCareer() }
                .onChange(of: workCareerVM.ideas) { _, _ in updateJournalFromWorkCareer() }
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
        dailyCheckInVM.mood = entry.dailyCheckIn.mood.isEmpty ? "Good" : entry.dailyCheckIn.mood
        dailyCheckInVM.todaysHighlight = entry.dailyCheckIn.todaysHighlight
        dailyCheckInVM.dailyOverview = entry.dailyCheckIn.dailyOverview
    }
    
    private func updateJournalFromDailyCheckIn() {
        guard var entry = viewModel.currentEntry else { return }
        entry.dailyCheckIn.mood = dailyCheckInVM.mood
        entry.dailyCheckIn.todaysHighlight = dailyCheckInVM.todaysHighlight
        entry.dailyCheckIn.dailyOverview = dailyCheckInVM.dailyOverview
        viewModel.updateEntrySection(entry)
    }
    
    
    
    private func updatePersonalGrowthFromJournal() {
        guard let entry = viewModel.currentEntry else { return }
        personalGrowthVM.reflections = entry.personalGrowth.reflections
        personalGrowthVM.achievements = entry.personalGrowth.achievements
        personalGrowthVM.challenges = entry.personalGrowth.challenges
        personalGrowthVM.goals = entry.personalGrowth.goals
    }
    
    private func updateJournalFromPersonalGrowth() {
        guard var entry = viewModel.currentEntry else { return }
        entry.personalGrowth.reflections = personalGrowthVM.reflections
        entry.personalGrowth.achievements = personalGrowthVM.achievements
        entry.personalGrowth.challenges = personalGrowthVM.challenges
        entry.personalGrowth.goals = personalGrowthVM.goals
        viewModel.updateEntrySection(entry)
    }
    
    
    
    private func updateWellbeingFromJournal() {
        guard let entry = viewModel.currentEntry else { return }
        wellbeingVM.energyLevel = entry.wellbeing.energyLevel
        wellbeingVM.physicalActivity = entry.wellbeing.physicalActivity
        wellbeingVM.mentalHealth = entry.wellbeing.mentalHealth
    }
    
    private func updateJournalFromWellbeing() {
        guard var entry = viewModel.currentEntry else { return }
        entry.wellbeing.energyLevel = wellbeingVM.energyLevel
        entry.wellbeing.physicalActivity = wellbeingVM.physicalActivity
        entry.wellbeing.mentalHealth = wellbeingVM.mentalHealth
        viewModel.updateEntrySection(entry)
    }
    
    
    
    private func updateCreativityLearningFromJournal() {
        guard let entry = viewModel.currentEntry else { return }
        creativityLearningVM.projects = entry.creativityLearning.projects
        creativityLearningVM.learningLog = entry.creativityLearning.learningLog
        creativityLearningVM.ideas = entry.creativityLearning.ideas
    }
    
    private func updateJournalFromCreativityLearning() {
        guard var entry = viewModel.currentEntry else { return }
        entry.creativityLearning.projects = creativityLearningVM.projects
        entry.creativityLearning.learningLog = creativityLearningVM.learningLog
        entry.creativityLearning.ideas = creativityLearningVM.ideas
        viewModel.updateEntrySection(entry)
    }
    
    
    
    private func updateSocialFromJournal() {
        guard let entry = viewModel.currentEntry else { return }
        socialVM.meaningfulInteractions = entry.social.meaningfulInteractions
        socialVM.relationshipUpdates = entry.social.relationshipUpdates
        socialVM.socialEvents = entry.social.socialEvents
    }
    
    private func updateJournalFromSocial() {
        guard var entry = viewModel.currentEntry else { return }
        entry.social.meaningfulInteractions = socialVM.meaningfulInteractions
        entry.social.relationshipUpdates = socialVM.relationshipUpdates
        entry.social.socialEvents = socialVM.socialEvents
        viewModel.updateEntrySection(entry)
    }
    
    
    
    private func updateWorkCareerFromJournal() {
        guard let entry = viewModel.currentEntry else { return }
        workCareerVM.achievements = entry.workCareer.wins
        workCareerVM.challenges = entry.workCareer.challenges
        workCareerVM.ideas = entry.workCareer.workIdeas
        workCareerVM.items = entry.workCareer.workItems
        workCareerVM.meetings = entry.workCareer.meetings
    }
    
    private func updateJournalFromWorkCareer() {
        guard var entry = viewModel.currentEntry else { return }
        entry.workCareer.wins = workCareerVM.achievements
        entry.workCareer.challenges = workCareerVM.challenges
        entry.workCareer.workIdeas = workCareerVM.ideas
        entry.workCareer.workItems = workCareerVM.items
        entry.workCareer.meetings = workCareerVM.meetings
        viewModel.updateEntrySection(entry)
    }
}