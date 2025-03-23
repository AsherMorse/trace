import SwiftUI

struct GeneratedEntryPreviewView: View {
    @Bindable var viewModel: VoiceAssistantViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMergeOption: JournalViewModel.ContentMergeStrategy = .intelligentMerge
    @State private var existingContent: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Preview Generated Entry")
                .font(.headline)
            
            ScrollView {
                Text(viewModel.generatedContent)
                    .font(.body)
                    .padding()
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
            }
            .frame(maxHeight: 300)
            
            if existingContent {
                Picker("Merge Strategy:", selection: $selectedMergeOption) {
                    Text("Smart Merge").tag(JournalViewModel.ContentMergeStrategy.intelligentMerge)
                    Text("Append").tag(JournalViewModel.ContentMergeStrategy.append)
                    Text("Replace").tag(JournalViewModel.ContentMergeStrategy.replace)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                Text(strategyDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            HStack {
                Button("Reject") {
                    viewModel.rejectGeneratedContent()
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Accept") {
                    viewModel.acceptGeneratedContent(mergeStrategy: selectedMergeOption)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            existingContent = viewModel.journalViewModel.currentEntry != nil
        }
    }
    
    private var strategyDescription: String {
        switch selectedMergeOption {
        case .intelligentMerge:
            return "Intelligently combines new content with existing entry, avoiding duplication"
        case .append:
            return "Adds new content to the end of the existing entry"
        case .replace:
            return "Replaces existing entry with the new content"
        }
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
