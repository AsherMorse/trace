import Foundation

enum FileError: Error, LocalizedError {
    case accessDenied
    case directoryNotFound
    case readError
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "Access to the directory was denied"
        case .directoryNotFound:
            return "The directory could not be found"
        case .readError:
            return "Failed to read directory contents"
        }
    }
} 
