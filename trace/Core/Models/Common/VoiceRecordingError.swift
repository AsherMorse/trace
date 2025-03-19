import Foundation

enum VoiceRecordingError: Error, LocalizedError {
    case microphonePermissionDenied
    case recorderInitFailed
    case recordingFailed
    case fileAccessError
    
    var errorDescription: String? {
        switch self {
        case .microphonePermissionDenied:
            return "Microphone permission denied"
        case .recorderInitFailed:
            return "Failed to initialize audio recorder"
        case .recordingFailed:
            return "Failed to record audio"
        case .fileAccessError:
            return "Failed to access audio file"
        }
    }
} 
