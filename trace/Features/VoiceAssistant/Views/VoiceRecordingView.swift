import SwiftUI

struct VoiceRecordingView: View {
    @Bindable var viewModel: VoiceAssistantViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Independent timer tracking
    @State private var startTime: Date? = nil
    @State private var displayTime: String = "00:00"
    @State private var timerActive = false
    
    // Timer publisher that updates every 0.1 seconds
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        switch viewModel.state {
        case .requestingPermission:
            PermissionRequestView(viewModel: viewModel)
                .padding()
                .background(Color(NSColor.windowBackgroundColor))
                .frame(width: 400, height: 300)
                .onAppear {
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
                Task {
                    await viewModel.checkMicrophonePermission()
                }
            }
            .onChange(of: viewModel.state) { _, newState in
                if newState == .recording && !timerActive {
                    startTime = Date()
                    timerActive = true
                } else if newState != .recording {
                    timerActive = false
                }
            }
            .onReceive(timer) { _ in
                if timerActive, let start = startTime {
                    let elapsed = Date().timeIntervalSince(start)
                    let minutes = Int(elapsed) / 60
                    let seconds = Int(elapsed) % 60
                    displayTime = String(format: "%02d:%02d", minutes, seconds)
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
            
            Text(displayTime)
                .font(.system(.title, design: .monospaced))
                .foregroundColor(viewModel.state == .recording ? .primary : .secondary)
        }
        .padding()
    }
    
    private var controlsView: some View {
        HStack(spacing: 30) {
            Button {
                // Reset display time when starting recording
                displayTime = "00:00"
                startTime = nil
                timerActive = false
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
            
            
            Button {
                timerActive = false
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
                timerActive = false
                viewModel.cancelRecording()
                dismiss()
            }
            
            Spacer()
        }
        .padding(.horizontal)
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
