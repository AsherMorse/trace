import Foundation

final class FileService {
    static let shared = FileService()
    
    private init() {}
    
    // MARK: - Directory Reading
    
    func readDirectory(at url: URL, completion: @escaping (Result<[URL], FileError>) -> Void) {
        guard url.startAccessingSecurityScopedResource() else {
            completion(.failure(.accessDenied))
            return
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            completion(.failure(.directoryNotFound))
            return
        }
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: .skipsHiddenFiles
            )
            completion(.success(contents))
        } catch {
            completion(.failure(.readError))
        }
    }
    
    // MARK: - Security-Scoped Resource Handling
    
    func canAccessDirectory(at url: URL) -> Bool {
        guard url.startAccessingSecurityScopedResource() else {
            return false
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        do {
            return try url.checkResourceIsReachable()
        } catch {
            return false
        }
    }
    
    func isExistingDirectory(_ url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    
    // MARK: - File Metadata Extraction
    
    func creationDate(for url: URL) -> Date? {
        do {
            let resourceValues = try url.resourceValues(forKeys: [.creationDateKey])
            return resourceValues.creationDate
        } catch {
            return nil
        }
    }
    
    func modificationDate(for url: URL) -> Date? {
        do {
            let resourceValues = try url.resourceValues(forKeys: [.contentModificationDateKey])
            return resourceValues.contentModificationDate
        } catch {
            return nil
        }
    }
    
    func fileSize(for url: URL) -> Int? {
        do {
            let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
            return resourceValues.fileSize
        } catch {
            return nil
        }
    }
    
    func isDirectory(url: URL) -> Bool {
        do {
            let resourceValues = try url.resourceValues(forKeys: [.isDirectoryKey])
            return resourceValues.isDirectory ?? false
        } catch {
            return false
        }
    }
    
    func metadata(for url: URL) -> FileMetadata {
        return FileMetadata(
            creationDate: creationDate(for: url),
            modificationDate: modificationDate(for: url),
            size: fileSize(for: url),
            isDirectory: isDirectory(url: url)
        )
    }
}
