import Foundation
import AVFoundation

enum RecordingState {
    case ready
    case recording
    case paused
    case stopped
}

protocol VoiceRecordingServiceProtocol {
    var recordingState: RecordingState { get }
    var recordingURL: URL? { get }
    var recordingDuration: TimeInterval { get }
    
    func requestPermission() async -> Bool
    func checkPermissionStatus() -> AVAuthorizationStatus
    func startRecording() throws -> URL
    func pauseRecording() throws
    func resumeRecording() throws
    func stopRecording() throws -> URL
    func deleteRecording()
}

final class VoiceRecordingService: NSObject, VoiceRecordingServiceProtocol {
    private let engine = AVAudioEngine()
    private var audioFile: AVAudioFile?
    private(set) var recordingState: RecordingState = .ready
    private(set) var recordingURL: URL?
    private var startTime: Date?
    private var isPaused = false
    
    var recordingDuration: TimeInterval {
        guard let startTime = startTime, recordingState == .recording || recordingState == .paused else { return 0 }
        return isPaused ? pausedTime : Date().timeIntervalSince(startTime)
    }
    
    private var pausedTime: TimeInterval = 0
    
    func checkPermissionStatus() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .audio)
    }
    
    func requestPermission() async -> Bool {
        return await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
    func startRecording() throws -> URL {
        // Check permissions
        let permissionStatus = checkPermissionStatus()
        if permissionStatus != .authorized {
            throw VoiceRecordingError.microphonePermissionDenied
        }
        
        // Stop any existing recording
        if recordingState == .recording {
            try stopRecording()
        }
        
        // Configure AVAudioSession for macOS
        #if os(macOS)
        // On macOS, AVAudioSession is not used, but we need to make sure
        // the audio engine is properly reset
        engine.stop()
        engine.reset()
        #endif
        
        // Create output file
        let tempURL = createTempURL()
        recordingURL = tempURL
        
        let format = engine.inputNode.outputFormat(forBus: 0)
        
        // Create audio file
        audioFile = try AVAudioFile(
            forWriting: tempURL,
            settings: [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: format.sampleRate,
                AVNumberOfChannelsKey: format.channelCount,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                AVEncoderBitRateKey: 128000
            ]
        )
        
        // Set up tap on input node
        engine.inputNode.installTap(onBus: 0, bufferSize: 4096, format: format) { [weak self] buffer, time in
            guard let self = self, let audioFile = self.audioFile, self.recordingState == .recording else { return }
            
            do {
                try audioFile.write(from: buffer)
            } catch {
                print("Error writing audio buffer: \(error.localizedDescription)")
            }
        }
        
        // Prepare and start engine
        engine.prepare()
        try engine.start()
        
        recordingState = .recording
        startTime = Date()
        isPaused = false
        pausedTime = 0
        
        return tempURL
    }
    
    func pauseRecording() throws {
        guard recordingState == .recording else { return }
        
        engine.pause()
        recordingState = .paused
        isPaused = true
        pausedTime = Date().timeIntervalSince(startTime!)
    }
    
    func resumeRecording() throws {
        guard recordingState == .paused else { return }
        
        try engine.start()
        recordingState = .recording
        isPaused = false
    }
    
    func stopRecording() throws -> URL {
        guard let url = recordingURL else {
            throw VoiceRecordingError.recordingFailed
        }
        
        if engine.isRunning {
            engine.inputNode.removeTap(onBus: 0)
            engine.stop()
        }
        
        recordingState = .stopped
        audioFile = nil
        startTime = nil
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw VoiceRecordingError.fileAccessError
        }
        
        return url
    }
    
    func deleteRecording() {
        guard let url = recordingURL else { return }
        
        if engine.isRunning {
            engine.inputNode.removeTap(onBus: 0)
            engine.stop()
        }
        
        try? FileManager.default.removeItem(at: url)
        recordingURL = nil
        recordingState = .ready
        audioFile = nil
        startTime = nil
        isPaused = false
        pausedTime = 0
    }
    
    private func createTempURL() -> URL {
        let directory = FileManager.default.temporaryDirectory
        let filename = UUID().uuidString + ".m4a"
        return directory.appendingPathComponent(filename)
    }
}