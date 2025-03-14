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
                                    SectionContainer {
                                        Text("Daily Check-in Content")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    
                                case .personalGrowth:
                                    SectionContainer {
                                        Text("Personal Growth Content")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    
                                case .wellbeing:
                                    SectionContainer {
                                        Text("Well-being Content")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    
                                case .creativityLearning:
                                    SectionContainer {
                                        Text("Creativity & Learning Content")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    
                                case .social:
                                    SectionContainer {
                                        Text("Social Content")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    
                                case .workCareer:
                                    SectionContainer {
                                        Text("Work & Career Content")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
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
