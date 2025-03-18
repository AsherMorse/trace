import Foundation

enum OpenAIError: Error, LocalizedError {
    case invalidAPIKey
    case transcriptionFailed
    case contentGenerationFailed
    case networkError(Error)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid or missing OpenAI API key"
        case .transcriptionFailed:
            return "Failed to transcribe audio"
        case .contentGenerationFailed:
            return "Failed to generate journal content"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Received invalid response from OpenAI"
        }
    }
} 