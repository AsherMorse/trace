import SwiftUI

struct JournalContentView: View {
    @Bindable var viewModel: JournalViewModel
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
                                    DailyCheckInView(viewModel: viewModel)
                                    
                                case .personalGrowth:
                                    PersonalGrowthView(viewModel: viewModel)
                                    
                                case .wellbeing:
                                    WellbeingView(viewModel: viewModel)
                                    
                                case .creativityLearning:
                                    CreativityLearningView(viewModel: viewModel)
                                    
                                case .social:
                                    SocialView(viewModel: viewModel)
                                    
                                case .workCareer:
                                    WorkCareerView(viewModel: viewModel)
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
                    print("📝 JournalContentView appeared - refreshing content")
                    viewModel.loadContent(for: date)
                    refreshKey = UUID()
                }
                .onChange(of: date) { oldValue, newValue in
                    print("📅 Date changed in JournalContentView: \(oldValue) -> \(newValue)")
                    print("🔄 Explicitly reloading content and forcing view refresh")
                    viewModel.loadContent(for: newValue)
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
            refreshKey = UUID()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
