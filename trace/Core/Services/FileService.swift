import Foundation

final class FileService {
    static let shared = FileService()
    
    private let fileManager = FileManager.default
    
    private init() {}
    
    // MARK: - File Reading/Writing
    
    func readFile(at url: URL) async throws -> String {
        // Note: We're not accessing security-scoped resources here because
        // FolderManager already handles that at a higher level
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            print("Error reading file: \(error.localizedDescription)")
            throw FileError.readError
        }
    }
    
    func writeFile(content: String, to url: URL) async throws {
        do {
            let directory = url.deletingLastPathComponent()
            try createDirectoryIfNeeded(at: directory)
            try content.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print("Error writing file: \(error.localizedDescription)")
            throw FileError.readError
        }
    }
    
    // MARK: - Directory Operations
    
    func createDirectoryIfNeeded(at url: URL) throws {
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory)
        
        if !exists {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        } else if !isDirectory.boolValue {
            // Path exists but is not a directory
            throw FileError.directoryNotFound
        }
    }
    
    func fileExists(at url: URL) -> Bool {
        fileManager.fileExists(atPath: url.path)
    }
    
    func isDirectory(at url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
}
