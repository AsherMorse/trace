import SwiftUI

struct JournalContentView: View {
    @Bindable var viewModel: JournalViewModel
    @FocusState private var isTextFieldFocused: Bool
    @State private var selectedTab: JournalSection = .dailyCheckIn
    
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
                                    DailyCheckInView()
                                    
                                case .personalGrowth:
                                    PersonalGrowthView()
                                    
                                case .wellbeing:
                                    WellbeingView()
                                    
                                case .creativityLearning:
                                    CreativityLearningView()
                                    
                                case .social:
                                    SocialView()
                                    
                                case .workCareer:
                                    WorkCareerView()
                                }
                            }
                            .padding(EdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 8))
                        }
                    }
                }
            } else {
                EmptyStateView {
                    viewModel.openTodaysEntry()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
