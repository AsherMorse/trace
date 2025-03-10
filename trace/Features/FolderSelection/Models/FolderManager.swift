import Foundation

final class FolderManager {
    static let shared = FolderManager()
    
    private(set) var selectedFolderURL: URL?
    private var bookmarkData: Data?
    
    var hasSelectedFolder: Bool {
        return selectedFolderURL != nil
    }
    
    private enum UserDefaultsKeys {
        static let selectedFolderBookmark = "com.trace.selectedFolderBookmark"
    }
    
    private init() {
        loadSavedFolder()
    }
    
    // MARK: - File System Access
    
    func canAccessSelectedFolder() -> Bool {
        guard let url = selectedFolderURL else { return false }
        
        do {
            return try url.checkResourceIsReachable()
        } catch {
            return false
        }
    }
    
    func stopAccessingFolder() {
        selectedFolderURL?.stopAccessingSecurityScopedResource()
    }
    
    func resetFolderSelection() {
        stopAccessingFolder()
        invalidateBookmark()
    }
    
    // MARK: - Folder Selection
    
    func saveSelectedFolder(url: URL, completion: ((Result<Void, FolderError>) -> Void)? = nil) {
        stopAccessingFolder()
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            completion?(.failure(.folderNotFound))
            return
        }
        
        do {
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope, 
                                                  includingResourceValuesForKeys: nil, 
                                                  relativeTo: nil)
            
            if !url.startAccessingSecurityScopedResource() {
                completion?(.failure(.accessDenied))
                return
            }
            
            UserDefaults.standard.set(bookmarkData, forKey: UserDefaultsKeys.selectedFolderBookmark)
            
            self.selectedFolderURL = url
            self.bookmarkData = bookmarkData
            
            completion?(.success(()))
        } catch {
            completion?(.failure(.bookmarkCreationFailed))
        }
    }
    
    // MARK: - Private Methods
    
    private func loadSavedFolder() {
        let savedBookmarkData = UserDefaults.standard.data(forKey: UserDefaultsKeys.selectedFolderBookmark)
        
        guard let bookmarkData = savedBookmarkData else {
            return
        }
        
        self.bookmarkData = bookmarkData
        resolveBookmark()
    }
    
    func resolveBookmark(completion: ((Result<Void, FolderError>) -> Void)? = nil) {
        guard let bookmarkData = self.bookmarkData else { 
            completion?(.success(()))
            return 
        }
        
        let resolvedURL: URL
        var isStale = false
        
        do {
            resolvedURL = try URL(resolvingBookmarkData: bookmarkData, 
                                 options: .withSecurityScope, 
                                 relativeTo: nil, 
                                 bookmarkDataIsStale: &isStale)
        } catch {
            invalidateBookmark()
            completion?(.failure(.bookmarkResolutionFailed))
            return
        }
        
        guard resolvedURL.startAccessingSecurityScopedResource() else {
            invalidateBookmark()
            completion?(.failure(.accessDenied))
            return
        }
        
        self.selectedFolderURL = resolvedURL
        
        if isStale {
            refreshStaleBookmark(for: resolvedURL)
        }
        
        completion?(.success(()))
    }
    
    private func refreshStaleBookmark(for url: URL) {
        saveSelectedFolder(url: url) { [weak self] result in
            guard let self = self else { return }
            
            if case .failure = result {
                self.invalidateBookmark()
            }
        }
    }
    
    private func invalidateBookmark() {
        selectedFolderURL = nil
        bookmarkData = nil
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.selectedFolderBookmark)
    }
}
