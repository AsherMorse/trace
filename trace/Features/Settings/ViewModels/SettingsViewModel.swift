import Foundation
import SwiftUI

@Observable
final class SettingsViewModel {
    private let settingsManager: AppSettingsManagerProtocol
    
    var apiKey: String = ""
    var isKeyValid: Bool = false
    var showAPIKeyError: Bool = false
    var errorMessage: String = ""
    var hasAPIKey: Bool {
        settingsManager.hasAPIKey
    }
    
    init(settingsManager: AppSettingsManagerProtocol) {
        self.settingsManager = settingsManager
        loadAPIKey()
    }
    
    func loadAPIKey() {
        if let existingKey = settingsManager.getAPIKey() {
            apiKey = existingKey
            isKeyValid = true
        } else {
            apiKey = ""
            isKeyValid = false
        }
    }
    
    func saveAPIKey() {
        if apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showAPIKeyError = true
            errorMessage = "API key cannot be empty"
            isKeyValid = false
            return
        }
        
        do {
            try settingsManager.saveAPIKey(apiKey)
            isKeyValid = true
            showAPIKeyError = false
            errorMessage = ""
        } catch {
            showAPIKeyError = true
            errorMessage = "Failed to save API key: \(error.localizedDescription)"
            isKeyValid = false
        }
    }
    
    func deleteAPIKey() {
        do {
            try settingsManager.deleteAPIKey()
            apiKey = ""
            isKeyValid = false
            showAPIKeyError = false
            errorMessage = ""
        } catch {
            showAPIKeyError = true
            errorMessage = "Failed to delete API key: \(error.localizedDescription)"
        }
    }
    
    func testConnection() {
        if settingsManager.hasAPIKey {
            showAPIKeyError = false
            errorMessage = ""
        } else {
            showAPIKeyError = true
            errorMessage = "No API key found to test"
        }
    }
} 
