import Foundation
import AVFoundation

protocol OpenAIServiceProtocol {
    func transcribe(audioURL: URL) async throws -> String
    func generateJournalContent(
        transcription: String, 
        currentEntry: String?, 
        formatTemplate: String
    ) async throws -> String
}

final class OpenAIService: OpenAIServiceProtocol {
    private let transcriptionEndpoint = "https://api.openai.com/v1/audio/transcriptions"
    private let completionEndpoint = "https://api.openai.com/v1/chat/completions"
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func transcribe(audioURL: URL) async throws -> String {
        await testNetwork()
        print("Transcription endpoint: \(transcriptionEndpoint)")
        guard !apiKey.isEmpty else {
            throw OpenAIError.invalidAPIKey
        }
        
        guard let transcriptionURL = URL(string: transcriptionEndpoint) else {
            throw OpenAIError.invalidURL
        }
        
        var request = URLRequest(url: transcriptionURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        
        data.append(Data("--\(boundary)\r\n".utf8))
        data.append(Data("Content-Disposition: form-data; name=\"model\"\r\n\r\n".utf8))
        data.append(Data("whisper-1\r\n".utf8))
        
        data.append(Data("--\(boundary)\r\n".utf8))
        let fileName = audioURL.lastPathComponent
        let fileDisposition = "Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n"
        data.append(Data(fileDisposition.utf8))
        data.append(Data("Content-Type: audio/mpeg\r\n\r\n".utf8))
        
        do {
            let audioData = try Data(contentsOf: audioURL)
            data.append(audioData)
            data.append(Data("\r\n".utf8))
            data.append(Data("--\(boundary)--\r\n".utf8))
            
            request.httpBody = data
            
            let (responseData, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, 
                  httpResponse.statusCode == 200 else {
                throw OpenAIError.transcriptionFailed
            }
            
            let decoder = JSONDecoder()
            let result = try decoder.decode(TranscriptionResponse.self, from: responseData)
            return result.text
        } catch let error as OpenAIError {
            throw error
        } catch {
            throw OpenAIError.networkError(error)
        }
    }
    
    func generateJournalContent(
        transcription: String, 
        currentEntry: String?, 
        formatTemplate: String
    ) async throws -> String {
        guard !apiKey.isEmpty else {
            throw OpenAIError.invalidAPIKey
        }
        
        guard let completionURL = URL(string: completionEndpoint) else {
            throw OpenAIError.invalidURL
        }
        
        var request = URLRequest(url: completionURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let currentEntryText = currentEntry ?? "No previous content"
        
        let messages: [[String: String]] = [
            [
                "role": "system", 
                "content": "You are a helpful assistant that converts spoken journal entries into formatted text. " +
                           "Maintain the user's tone and style. Follow the provided format."
            ],
            [
                "role": "user", 
                "content": "Here is the format template for the journal entry:\n\n\(formatTemplate)"
            ],
            [
                "role": "user", 
                "content": "Here is the current journal entry content (if any):\n\n\(currentEntryText)"
            ],
            [
                "role": "user", 
                "content": "Here is my transcribed voice note. " +
                           "Please convert it into a journal entry following the format:" +
                           "\n\n\(transcription)"
            ]
        ]
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": messages,
            "temperature": 0.7
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        request.httpBody = jsonData
        
        do {
            let (responseData, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, 
                  httpResponse.statusCode == 200 else {
                throw OpenAIError.contentGenerationFailed
            }
            
            let decoder = JSONDecoder()
            let result = try decoder.decode(CompletionResponse.self, from: responseData)
            
            guard let message = result.choices.first?.message,
                  message.role == "assistant",
                  !message.content.isEmpty else {
                throw OpenAIError.invalidResponse
            }
            
            return message.content
        } catch let error as OpenAIError {
            throw error
        } catch {
            throw OpenAIError.networkError(error)
        }
    }
    
    func testNetwork() async {
        do {
            let url = URL(string: "https://www.google.com")!
            let (data, response) = try await URLSession.shared.data(from: url)
            print("Test succeeded: \(response)")
        } catch {
            print("Test failed: \(error)")
        }
    }
}

private struct TranscriptionResponse: Decodable {
    let text: String
}

private struct CompletionResponse: Decodable {
    let choices: [Choice]
    
    struct Choice: Decodable {
        let message: Message
    }
    
    struct Message: Decodable {
        let role: String
        let content: String
    }
} 
