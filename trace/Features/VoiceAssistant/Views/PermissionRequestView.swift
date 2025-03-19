import SwiftUI
import AVFoundation

struct PermissionRequestView: View {
    @Bindable var viewModel: VoiceAssistantViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "mic.slash")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            
            Text("Microphone Access Required")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text("To use the voice journal assistant, please allow access to your microphone. Your privacy is important - recordings are only used for transcription and are not stored long-term.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            HStack(spacing: 16) {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.plain)
                
                Button("Request Permission") {
                    Task {
                        await viewModel.checkMicrophonePermission()
                        
                        if !viewModel.permissionStatus {
                            // Show system settings action if still not granted
                            if let settingsURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
                                NSWorkspace.shared.open(settingsURL)
                            }
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top, 8)
        }
        .padding(24)
        .frame(width: 400)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

#Preview {
    PermissionRequestView(
        viewModel: VoiceAssistantViewModel(
            voiceRecordingService: VoiceRecordingService(),
            openAIService: OpenAIService(apiKey: "preview-key"),
            settingsManager: AppSettingsManager(),
            journalViewModel: JournalViewModel()
        )
    )
}