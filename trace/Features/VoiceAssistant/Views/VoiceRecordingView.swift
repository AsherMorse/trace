import SwiftUI

struct VoiceRecordingView: View {
    @Bindable var viewModel: VoiceAssistantViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        switch viewModel.state {
        case .requestingPermission:
            PermissionRequestView(viewModel: viewModel)
                .padding()
                .background(Color(NSColor.windowBackgroundColor))
                .frame(width: 400, height: 300)
                .onAppear {
                    // Check permission when view appears
                    Task {
                        await viewModel.checkMicrophonePermission()
                    }
                }
        case .ready, .recording:
            VStack(spacing: 20) {
                Spacer().frame(height: 20)
                titleView
                recordingStatusView
                controlsView
                actionButtonsView
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            .frame(width: 400, height: 300)
            .onAppear {
                // Check permission when view appears
                Task {
                    await viewModel.checkMicrophonePermission()
                }
            }
        case .processing:
            ProcessingView()
                .padding()
                .background(Color(NSColor.windowBackgroundColor))
                .frame(width: 400, height: 300)
        case .previewing:
            GeneratedEntryPreviewView(viewModel: viewModel)
                .padding()
                .background(Color(NSColor.windowBackgroundColor))
                .frame(width: 500, height: 500)
                .onDisappear {
                    // Check if we need to reset if it wasn't done explicitly
                    if viewModel.state == .previewing {
                        viewModel.resetState()
                    }
                }
        case .error(let error):
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
                
                Text("Error")
                    .font(.headline)
                
                Text(error.localizedDescription)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                
                Button("Dismiss") {
                    viewModel.resetState()
                    dismiss()
                }
                .padding(.top, 8)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            .frame(width: 400, height: 300)
        }
    }
    
    private var titleView: some View {
        Text("Voice Journal Assistant")
            .font(.headline)
            .padding(.top)
    }
    
    private var recordingStatusView: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Circle()
                    .fill(Color.red)
                    .frame(width: 60, height: 60)
                    .opacity(viewModel.state == .recording ? 1.0 : 0.3)
                    .scaleEffect(viewModel.state == .recording ? 1.0 : 0.8)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), 
                               value: viewModel.state == .recording)
                
                if viewModel.state == .processing {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            
            Text(formattedDuration)
                .font(.system(.title, design: .monospaced))
                .foregroundColor(viewModel.state == .recording ? .primary : .secondary)
        }
        .padding()
    }
    
    private var controlsView: some View {
        HStack(spacing: 30) {
            Button {
                viewModel.startRecording()
            } label: {
                VStack {
                    Image(systemName: "record.circle")
                        .font(.system(size: 32))
                    Text("Record")
                        .font(.caption)
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(.red)
            .disabled(viewModel.state != .ready)
            
            // Button {
            //     if viewModel.state == .recording {
            //         viewModel.pauseRecording()
            //     } else if viewModel.isRecordingPaused {
            //         viewModel.resumeRecording()
            //     }
            // } label: {
            //     VStack {
            //         Image(systemName: viewModel.recordingControlIcon)
            //             .font(.system(size: 32))
            //         Text(viewModel.recordingControlLabel)
            //             .font(.caption)
            //     }
            // }
            // .buttonStyle(.plain)
            // .foregroundColor(.primary)
            // .disabled(viewModel.state != .recording && !viewModel.isRecordingPaused)
            
            Button {
                viewModel.stopRecording()
            } label: {
                VStack {
                    Image(systemName: "stop.circle")
                        .font(.system(size: 32))
                    Text("Stop")
                        .font(.caption)
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(.primary)
            .disabled(viewModel.state != .recording && !viewModel.isRecordingPaused)
        }
        .padding()
    }
    
    private var actionButtonsView: some View {
        HStack {
            Button("Cancel") {
                viewModel.cancelRecording()
                dismiss()
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var formattedDuration: String {
        let duration = Int(viewModel.recordingDuration)
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    let previewViewModel = VoiceAssistantViewModel(
        voiceRecordingService: VoiceRecordingService(),
        openAIService: OpenAIService(apiKey: "preview-key"),
        settingsManager: AppSettingsManager(),
        journalViewModel: JournalViewModel()
    )
    
    return VoiceRecordingView(viewModel: previewViewModel)
} 
