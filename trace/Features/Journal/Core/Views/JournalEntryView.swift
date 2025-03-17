import SwiftUI

struct JournalEntryView: View {
    @Bindable var viewModel: JournalViewModel
    @State private var dailyCheckInVM = DailyCheckInViewModel()
    @State private var personalGrowthVM = PersonalGrowthViewModel()
    @State private var wellbeingVM = WellbeingViewModel()
    @State private var creativityLearningVM = CreativityLearningViewModel()
    @State private var socialVM = SocialViewModel()
    @State private var workCareerVM = WorkCareerViewModel()
    @FocusState private var isTextFieldFocused: Bool
    @State private var selectedTab: JournalSection = .dailyCheckIn
    @State private var refreshKey = UUID()
    
    var body: some View {
        VStack(spacing: 0) {
            if let date = viewModel.selectedDate {
                VStack(spacing: 0) {
                    DateHeaderView(date: date)
                        .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
                    
                    VStack(spacing: 0) {
                        SectionTabBar(selectedTab: $selectedTab)
                            .padding()
                        
                        ScrollView {
                            VStack(spacing: 20) {
                                switch selectedTab {
                                case .dailyCheckIn:
                                    DailyCheckInView(viewModel: dailyCheckInVM)
                                    
                                case .personalGrowth:
                                    PersonalGrowthView(viewModel: personalGrowthVM)
                                    
                                case .wellbeing:
                                    WellbeingView(viewModel: wellbeingVM)
                                    
                                case .creativityLearning:
                                    CreativityLearningView(viewModel: creativityLearningVM)
                                    
                                case .social:
                                    SocialView(viewModel: socialVM)
                                    
                                case .workCareer:
                                    WorkCareerView(viewModel: workCareerVM)
                                }
                            }
                            .padding(EdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 8))
                            .id("\(date.timeIntervalSince1970)-\(refreshKey)")
                        }
                        
                        HStack {
                            Spacer()
                            Button("Save Changes") {
                                Task {
                                    do {
                                        if selectedTab == .dailyCheckIn {
                                            updateJournalFromDailyCheckIn()
                                        } else if selectedTab == .personalGrowth {
                                            updateJournalFromPersonalGrowth()
                                        } else if selectedTab == .wellbeing {
                                            updateJournalFromWellbeing()
                                        } else if selectedTab == .creativityLearning {
                                            updateJournalFromCreativityLearning()
                                        } else if selectedTab == .social {
                                            updateJournalFromSocial()
                                        } else if selectedTab == .workCareer {
                                            updateJournalFromWorkCareer()
                                        }
                                        try await viewModel.saveEdits()
                                    } catch {
                                        print("Error saving: \(error)")
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(!viewModel.isDirty)
                            .padding()
                        }
                    }
                }
                .onAppear {
                    print("📝 JournalEntryView appeared - refreshing content")
                    viewModel.loadContent(for: date)
                    updateDailyCheckInFromJournal()
                    updatePersonalGrowthFromJournal()
                    updateWellbeingFromJournal()
                    updateCreativityLearningFromJournal()
                    updateSocialFromJournal()
                    updateWorkCareerFromJournal()
                    refreshKey = UUID()
                }
                .onChange(of: date) { oldValue, newValue in
                    print("📅 Date changed in JournalEntryView: \(oldValue) -> \(newValue)")
                    print("🔄 Explicitly reloading content and forcing view refresh")
                    viewModel.loadContent(for: newValue)
                    updateDailyCheckInFromJournal()
                    updatePersonalGrowthFromJournal()
                    updateWellbeingFromJournal()
                    updateCreativityLearningFromJournal()
                    updateSocialFromJournal()
                    updateWorkCareerFromJournal()
                    refreshKey = UUID()
                }
            } else {
                EmptyStateView {
                    viewModel.openTodaysEntry()
                }
            }
        }
        .onChange(of: viewModel.fileContent) { oldValue, newValue in
            print("📄 File content changed in ViewModel - triggering UI refresh")
            updateDailyCheckInFromJournal()
            updatePersonalGrowthFromJournal()
            updateWellbeingFromJournal()
            updateCreativityLearningFromJournal()
            updateSocialFromJournal()
            updateWorkCareerFromJournal()
            refreshKey = UUID()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private func updateDailyCheckInFromJournal() {
        if let entry = viewModel.currentEntry {
            dailyCheckInVM.mood = entry.dailyCheckIn.mood.isEmpty ? "Good" : entry.dailyCheckIn.mood
            dailyCheckInVM.todaysHighlight = entry.dailyCheckIn.todaysHighlight
            dailyCheckInVM.dailyOverview = entry.dailyCheckIn.dailyOverview
        }
    }
    
    private func updateJournalFromDailyCheckIn() {
        if var entry = viewModel.currentEntry {
            entry.dailyCheckIn.mood = dailyCheckInVM.mood
            entry.dailyCheckIn.todaysHighlight = dailyCheckInVM.todaysHighlight
            entry.dailyCheckIn.dailyOverview = dailyCheckInVM.dailyOverview
            viewModel.updateEntrySection(entry)
        }
    }
    
    private func updatePersonalGrowthFromJournal() {
        if let entry = viewModel.currentEntry {
            personalGrowthVM.reflections = entry.personalGrowth.reflections
            personalGrowthVM.achievements = entry.personalGrowth.achievements
            personalGrowthVM.challenges = entry.personalGrowth.challenges
            personalGrowthVM.goals = entry.personalGrowth.goals
        }
    }
    
    private func updateJournalFromPersonalGrowth() {
        if var entry = viewModel.currentEntry {
            entry.personalGrowth.reflections = personalGrowthVM.reflections
            entry.personalGrowth.achievements = personalGrowthVM.achievements
            entry.personalGrowth.challenges = personalGrowthVM.challenges
            entry.personalGrowth.goals = personalGrowthVM.goals
            viewModel.updateEntrySection(entry)
        }
    }
    
    private func updateWellbeingFromJournal() {
        if let entry = viewModel.currentEntry {
            wellbeingVM.energyLevel = entry.wellbeing.energyLevel
            wellbeingVM.physicalActivity = entry.wellbeing.physicalActivity
            wellbeingVM.mentalHealth = entry.wellbeing.mentalHealth
        }
    }
    
    private func updateJournalFromWellbeing() {
        if var entry = viewModel.currentEntry {
            entry.wellbeing.energyLevel = wellbeingVM.energyLevel
            entry.wellbeing.physicalActivity = wellbeingVM.physicalActivity
            entry.wellbeing.mentalHealth = wellbeingVM.mentalHealth
            viewModel.updateEntrySection(entry)
        }
    }
    
    private func updateCreativityLearningFromJournal() {
        if let entry = viewModel.currentEntry {
            creativityLearningVM.projects = entry.creativityLearning.projects
            creativityLearningVM.learningLog = entry.creativityLearning.learningLog
            creativityLearningVM.ideas = entry.creativityLearning.ideas
        }
    }
    
    private func updateJournalFromCreativityLearning() {
        if var entry = viewModel.currentEntry {
            entry.creativityLearning.projects = creativityLearningVM.projects
            entry.creativityLearning.learningLog = creativityLearningVM.learningLog
            entry.creativityLearning.ideas = creativityLearningVM.ideas
            viewModel.updateEntrySection(entry)
        }
    }
    
    private func updateSocialFromJournal() {
        if let entry = viewModel.currentEntry {
            socialVM.meaningfulInteractions = entry.social.meaningfulInteractions
            socialVM.relationshipUpdates = entry.social.relationshipUpdates
            socialVM.socialEvents = entry.social.socialEvents
        }
    }
    
    private func updateJournalFromSocial() {
        if var entry = viewModel.currentEntry {
            entry.social.meaningfulInteractions = socialVM.meaningfulInteractions
            entry.social.relationshipUpdates = socialVM.relationshipUpdates
            entry.social.socialEvents = socialVM.socialEvents
            viewModel.updateEntrySection(entry)
        }
    }
    
    private func updateWorkCareerFromJournal() {
        if let entry = viewModel.currentEntry {
            workCareerVM.achievements = entry.workCareer.wins
            workCareerVM.challenges = entry.workCareer.challenges
            workCareerVM.ideas = entry.workCareer.workIdeas
            workCareerVM.items = entry.workCareer.workItems
            workCareerVM.meetings = entry.workCareer.meetings
        }
    }
    
    private func updateJournalFromWorkCareer() {
        if var entry = viewModel.currentEntry {
            entry.workCareer.wins = workCareerVM.achievements
            entry.workCareer.challenges = workCareerVM.challenges
            entry.workCareer.workIdeas = workCareerVM.ideas
            entry.workCareer.workItems = workCareerVM.items
            entry.workCareer.meetings = workCareerVM.meetings
            viewModel.updateEntrySection(entry)
        }
    }
} 