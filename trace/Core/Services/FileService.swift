import Foundation

final class FileService {
    static let shared = FileService()
    
    private let fileManager = FileManager.default
    
    private init() {}
    
    func readFile(at url: URL) async throws -> String {
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
    
    func createDirectoryIfNeeded(at url: URL) throws {
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory)
        
        if !exists {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        } else if !isDirectory.boolValue {
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
