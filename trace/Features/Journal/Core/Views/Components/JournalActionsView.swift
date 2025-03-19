import SwiftUI

struct JournalActionsView: View {
    var viewModel: JournalViewModel
    @State private var showingVoiceRecording = false
    @State private var hasAPIKey = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerView
            
            quickActionsButtons
            
            Spacer()
        }
        .padding()
        .background(Theme.backgroundSecondary)
        .onAppear {
            checkAPIKeyAvailability()
        }
        .sheet(isPresented: $showingVoiceRecording) {
            if let _ = viewModel.selectedDate {
                VoiceRecordingView(viewModel: makeVoiceAssistantViewModel())
            }
        }
    }
    
    private var headerView: some View {
        Text("Quick Actions")
            .font(.headline)
            .fontWeight(.bold)
            .padding(.bottom, 4)
    }
    
    private var quickActionsButtons: some View {
        VStack(spacing: 10) {
            todaysEntryButton
            if hasAPIKey {
                voiceAssistantButton
            }
            recentEntriesButton
            searchButton
            resetFolderButton
        }
    }
    
    private var voiceAssistantButton: some View {
        Button(action: {
            showingVoiceRecording = true
        }) {
            Label("Voice Assistant", systemImage: "mic.fill")
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.bordered)
        .tint(.orange)
        .help("Record a voice note and convert it to journal text")
    }
    
    private var todaysEntryButton: some View {
        
        Button(action: {
            viewModel.openTodaysEntry()
        }) {
            Label("Today's Entry", systemImage: "calendar.badge.clock")
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.bordered)
        .tint(.green)
        .help("View or create an entry for today")
    }
    
    private var recentEntriesButton: some View {
        
        Button(action: {
            
            print("Recent entries button tapped")
        }) {
            Label("Recent Entries", systemImage: "clock")
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.bordered)
        .tint(.indigo)
        .disabled(true) 
        .help("View recently created journal entries")
    }
    
    private var searchButton: some View {
        
        Button(action: {
            
            print("Search button tapped")
        }) {
            Label("Search Journal", systemImage: "magnifyingglass")
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.bordered)
        .tint(.purple)
        .disabled(true) 
        .help("Search for content in your journal entries")
    }
    
    private var resetFolderButton: some View {
        
        Button(action: {
            viewModel.resetFolderSelection()
        }) {
            Label("Reset Folder Selection", systemImage: "folder.badge.minus")
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.bordered)
        .tint(.red)
        .help("Clear the current journal folder selection")
    }
    
    private func checkAPIKeyAvailability() {
        let settingsManager = AppSettingsManager()
        hasAPIKey = settingsManager.hasAPIKey
    }
    
    private func makeVoiceAssistantViewModel() -> VoiceAssistantViewModel {
        let settingsManager = AppSettingsManager()
        guard let apiKey = settingsManager.getAPIKey() else {
            fatalError("API key should be available")
        }
        
        return VoiceAssistantViewModel(
            voiceRecordingService: VoiceRecordingService(),
            openAIService: OpenAIService(apiKey: apiKey),
            settingsManager: settingsManager,
            journalViewModel: viewModel
        )
    }
} 
