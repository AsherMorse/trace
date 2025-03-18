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
    
    func startRecording() throws -> URL
    func pauseRecording() throws
    func resumeRecording() throws
    func stopRecording() throws -> URL
    func deleteRecording()
}

final class VoiceRecordingService: NSObject, VoiceRecordingServiceProtocol {
    private var audioRecorder: AVAudioRecorder?
    private(set) var recordingState: RecordingState = .ready
    private(set) var recordingURL: URL?
    
    var recordingDuration: TimeInterval {
        audioRecorder?.currentTime ?? 0
    }
    
    func startRecording() throws -> URL {
        if recordingState == .recording {
            _ = try stopRecording()
        }
        
        let tempURL = createTempURL()
        recordingURL = tempURL
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: tempURL, settings: settings)
            audioRecorder?.delegate = self
            
            guard let recorder = audioRecorder, recorder.prepareToRecord() else {
                throw VoiceRecordingError.recorderInitFailed
            }
            
            if !recorder.record() {
                throw VoiceRecordingError.recordingFailed
            }
            
            recordingState = .recording
            return tempURL
        } catch {
            throw VoiceRecordingError.recorderInitFailed
        }
    }
    
    func pauseRecording() throws {
        guard recordingState == .recording, let recorder = audioRecorder else {
            return
        }
        
        recorder.pause()
        recordingState = .paused
    }
    
    func resumeRecording() throws {
        guard recordingState == .paused, let recorder = audioRecorder else {
            return
        }
        
        if !recorder.record() {
            throw VoiceRecordingError.recordingFailed
        }
        recordingState = .recording
    }
    
    func stopRecording() throws -> URL {
        guard let recorder = audioRecorder, let url = recordingURL else {
            throw VoiceRecordingError.recordingFailed
        }
        
        recorder.stop()
        recordingState = .stopped
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw VoiceRecordingError.fileAccessError
        }
        
        return url
    }
    
    func deleteRecording() {
        guard let url = recordingURL else { return }
        
        try? FileManager.default.removeItem(at: url)
        recordingURL = nil
        recordingState = .ready
    }
    
    private func createTempURL() -> URL {
        let directory = FileManager.default.temporaryDirectory
        let filename = UUID().uuidString + ".m4a"
        return directory.appendingPathComponent(filename)
    }
}

extension VoiceRecordingService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recordingState = .stopped
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        recordingState = .stopped
    }
}
