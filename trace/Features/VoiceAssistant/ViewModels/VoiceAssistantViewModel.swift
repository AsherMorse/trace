import Foundation
import SwiftUI

enum VoiceAssistantState: Equatable {
    case requestingPermission
    case ready
    case recording
    case processing
    case previewing
    case error(Error)
    
    static func == (lhs: VoiceAssistantState, rhs: VoiceAssistantState) -> Bool {
        switch (lhs, rhs) {
        case (.requestingPermission, .requestingPermission),
             (.ready, .ready),
             (.recording, .recording),
             (.processing, .processing),
             (.previewing, .previewing):
            return true
        case (.error, .error):
            // Note: Error doesn't conform to Equatable, so we can only check the case
            return true
        default:
            return false
        }
    }
}

@Observable
final class VoiceAssistantViewModel {
    let voiceRecordingService: VoiceRecordingServiceProtocol
    private let openAIService: OpenAIServiceProtocol
    private let settingsManager: AppSettingsManagerProtocol
    let journalViewModel: JournalViewModel
    
    var state: VoiceAssistantState = .ready
    var recordingURL: URL?
    var recordingDuration: TimeInterval = 0
    var transcription: String = ""
    var generatedContent: String = ""
    var errorMessage: String = ""
    var permissionStatus: Bool = false
    
    private var timer: Timer?
    
    init(
        voiceRecordingService: VoiceRecordingServiceProtocol,
        openAIService: OpenAIServiceProtocol,
        settingsManager: AppSettingsManagerProtocol,
        journalViewModel: JournalViewModel
    ) {
        self.voiceRecordingService = voiceRecordingService
        self.openAIService = openAIService
        self.settingsManager = settingsManager
        self.journalViewModel = journalViewModel
        
        // Check initial permission status
        if voiceRecordingService.checkPermissionStatus() == .authorized {
            self.permissionStatus = true
        }
    }
    
    func checkMicrophonePermission() async {
        let currentStatus = voiceRecordingService.checkPermissionStatus()
        
        switch currentStatus {
        case .notDetermined:
            state = .requestingPermission
            permissionStatus = await voiceRecordingService.requestPermission()
            state = permissionStatus ? .ready : .error(VoiceRecordingError.microphonePermissionDenied)
        case .denied, .restricted:
            permissionStatus = false
            state = .error(VoiceRecordingError.microphonePermissionDenied)
        case .authorized:
            permissionStatus = true
            state = .ready
        @unknown default:
            permissionStatus = false
            state = .error(VoiceRecordingError.microphonePermissionDenied)
        }
    }
    
    func startRecording() {
        guard state == .ready else { return }
        
        // First check permission
        Task {
            await checkMicrophonePermission()
            
            if permissionStatus {
                do {
                    recordingURL = try voiceRecordingService.startRecording()
                    state = .recording
                    startTimer()
                } catch {
                    handleError(error)
                }
            }
        }
    }
    
    func pauseRecording() {
        guard state == .recording else { return }
        
        do {
            try voiceRecordingService.pauseRecording()
            stopTimer()
        } catch {
            handleError(error)
        }
    }
    
    func resumeRecording() {
        guard voiceRecordingService.recordingState == .paused else { return }
        
        do {
            try voiceRecordingService.resumeRecording()
            state = .recording
            startTimer()
        } catch {
            handleError(error)
        }
    }
    
    func stopRecording() {
        guard state == .recording else { return }
        
        stopTimer()
        
        do {
            recordingURL = try voiceRecordingService.stopRecording()
            state = .processing
            processRecording()
        } catch {
            handleError(error)
        }
    }
    
    func cancelRecording() {
        guard state == .recording || state == .processing else { return }
        
        stopTimer()
        voiceRecordingService.deleteRecording()
        resetState()
    }
    
    func acceptGeneratedContent(mergeStrategy: JournalViewModel.ContentMergeStrategy = .intelligentMerge) {
        guard state == .previewing,
              !generatedContent.isEmpty else { return }
        
        Task {
            do {
                if let date = journalViewModel.selectedDate {
                    try journalViewModel.applyAIGeneratedContent(generatedContent, for: date, strategy: mergeStrategy)
                    try await journalViewModel.saveEdits()
                }
                resetState()
            } catch {
                handleError(error)
            }
        }
    }
    
    func rejectGeneratedContent() {
        guard state == .previewing else { return }
        resetState()
    }
    
    private func processRecording() {
        guard let url = recordingURL,
              let apiKey = settingsManager.getAPIKey() else {
            handleError(OpenAIError.invalidAPIKey)
            return
        }
        
        Task {
            do {
                let service = OpenAIService(apiKey: apiKey)
                
                transcription = try await service.transcribe(audioURL: url)
                
                // Try to load the template from the bundle or from the filesystem
                var formatTemplate: String
                if let templateURL = Bundle.main.url(forResource: "JournalEntryFormat", withExtension: "md") {
                    // If it's in the bundle, load it from there
                    formatTemplate = try String(contentsOf: templateURL, encoding: .utf8)
                } else if let resourceURL = URL(string: "file:///Users/ash/Dev/trace/JournalEntryFormat.md") {
                    // If not in bundle, try loading directly from project directory 
                    if FileManager.default.fileExists(atPath: resourceURL.path) {
                        formatTemplate = try String(contentsOf: resourceURL, encoding: .utf8)
                    } else {
                        throw NSError(
                            domain: "VoiceAssistantViewModel",
                            code: 1001,
                            userInfo: [NSLocalizedDescriptionKey: "Could not find JournalEntryFormat.md"]
                        )
                    }
                } else {
                    throw NSError(
                        domain: "VoiceAssistantViewModel",
                        code: 1001,
                        userInfo: [NSLocalizedDescriptionKey: "Could not find JournalEntryFormat.md"]
                    )
                }
                let currentContent = journalViewModel.currentEntry?.toMarkdown() ?? ""
                
                generatedContent = try await service.generateJournalContent(
                    transcription: transcription,
                    currentEntry: currentContent,
                    formatTemplate: formatTemplate
                )
                
                state = .previewing
            } catch {
                handleError(error)
            }
        }
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        state = .error(error)
    }
    
    func resetState() {
        state = .ready
        recordingURL = nil
        recordingDuration = 0
        transcription = ""
        generatedContent = ""
        errorMessage = ""
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.recordingDuration = self.voiceRecordingService.recordingDuration
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    var isRecordingPaused: Bool {
        voiceRecordingService.recordingState == .paused
    }
    
    var recordingControlIcon: String {
        isRecordingPaused ? "play.circle" : "pause.circle"
    }
    
    var recordingControlLabel: String {
        isRecordingPaused ? "Resume" : "Pause"
    }
} 
