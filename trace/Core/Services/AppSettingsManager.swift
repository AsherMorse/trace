import Foundation
import Security

protocol AppSettingsManagerProtocol {
    func saveAPIKey(_ apiKey: String) throws
    func getAPIKey() -> String?
    func deleteAPIKey() throws
    var hasAPIKey: Bool { get }
}

final class AppSettingsManager: AppSettingsManagerProtocol {
    
    private enum KeychainKeys {
        static let openAIAPIKey = "com.trace.openai.apikey"
    }
    
    func saveAPIKey(_ apiKey: String) throws {
        guard let apiKeyData = apiKey.data(using: .utf8) else {
            throw NSError(domain: "AppSettingsManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode API key"])
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: KeychainKeys.openAIAPIKey,
            kSecValueData as String: apiKeyData
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailure(status: status)
        }
    }
    
    func getAPIKey() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: KeychainKeys.openAIAPIKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess,
              let retrievedData = dataTypeRef as? Data,
              let apiKey = String(data: retrievedData, encoding: .utf8) else {
            return nil
        }
        
        return apiKey
    }
    
    func deleteAPIKey() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: KeychainKeys.openAIAPIKey
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailure(status: status)
        }
    }
    
    var hasAPIKey: Bool {
        getAPIKey() != nil
    }
}

enum KeychainError: Error, LocalizedError {
    case saveFailure(status: OSStatus)
    case readFailure(status: OSStatus)
    case deleteFailure(status: OSStatus)
    
    var errorDescription: String? {
        switch self {
        case .saveFailure(let status):
            return "Failed to save to Keychain: \(status)"
        case .readFailure(let status):
            return "Failed to read from Keychain: \(status)"
        case .deleteFailure(let status):
            return "Failed to delete from Keychain: \(status)"
        }
    }
} 
