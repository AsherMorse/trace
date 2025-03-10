import Foundation

enum FolderError: Error, LocalizedError {
    case bookmarkCreationFailed
    case bookmarkResolutionFailed
    case accessDenied
    case folderNotFound

    var errorDescription: String? {
        switch self {
        case .folderNotFound:
            return "The selected folder could not be found"
        case .accessDenied:
            return "Access to the selected folder was denied"
        case .bookmarkCreationFailed:
            return "Failed to create bookmark for the folder"
        case .bookmarkResolutionFailed:
            return "Failed to resolve the saved folder"
        }
    }
}
