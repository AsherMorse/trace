import SwiftUI
import AppKit

@Observable
final class FolderSelectionViewModel {
    private(set) var selectedFolderURL: URL?
    private(set) var errorMessage: String?
    private(set) var isValidFolder: Bool = false

    var onFolderSelected: ((Bool) -> Void)?

    var hasSelectedFolder: Bool {
        selectedFolderURL != nil
    }

    var hasError: Bool {
        errorMessage != nil
    }

    var displayPath: String {
        selectedFolderURL?.path ?? "No folder selected"
    }

    var statusMessage: String {
        if let error = errorMessage {
            return error
        }
        if hasSelectedFolder {
            return isValidFolder ? "Folder selected successfully" : "Selected folder has issues"
        }
        return "Please select a folder"
    }

    init() {
        selectedFolderURL = FolderManager.shared.selectedFolderURL
        validateSelectedFolder()
    }

    deinit {
        FolderManager.shared.stopAccessingFolder()
    }

    func selectFolder() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.canCreateDirectories = true
        openPanel.prompt = "Select"
        openPanel.message = "Select a folder to store your journal entries"

        openPanel.begin { [weak self] response in
            guard let self = self else { return }

            Task { @MainActor in
                self.handlePanelResponse(response, openPanel: openPanel)
            }
        }
    }

    func openInFinder() {
        guard let url = selectedFolderURL else { return }
        NSWorkspace.shared.open(url)
    }

    func validateSelectedFolder() {
        guard selectedFolderURL != nil else {
            updateFolderState(isValid: false, error: nil)
            return
        }

        let canAccess = FolderManager.shared.canAccessSelectedFolder()
        let error = canAccess ? nil : "Cannot access the selected folder"
        updateFolderState(isValid: canAccess, error: error)
    }

    func changeFolder() {
        selectFolder()
    }

    private func updateFolderState(isValid: Bool, error: String?) {
        isValidFolder = isValid
        errorMessage = error
    }

    private func handlePanelResponse(_ response: NSApplication.ModalResponse, openPanel: NSOpenPanel) {
        guard response == .OK, let url = openPanel.url else {
            onFolderSelected?(false)
            return
        }

        saveSelectedFolder(url)
    }

    private func saveSelectedFolder(_ url: URL) {
        updateFolderState(isValid: false, error: nil)

        FolderManager.shared.saveSelectedFolder(url: url) { [weak self] result in
            guard let self = self else { return }

            Task { @MainActor in
                switch result {
                case .success:
                    self.selectedFolderURL = url
                    self.validateSelectedFolder()
                    self.onFolderSelected?(true)
                case .failure(let error):
                    self.handleError(error)
                    self.onFolderSelected?(false)
                }
            }
        }
    }

    private func handleError(_ error: FolderError) {
        let errorMessage: String

        switch error {
        case .folderNotFound:
            errorMessage = "The selected folder could not be found"
        case .accessDenied:
            errorMessage = "Access to the selected folder was denied"
        case .bookmarkCreationFailed:
            errorMessage = "Failed to create bookmark for the folder"
        case .bookmarkResolutionFailed:
            errorMessage = "Failed to resolve the saved folder"
        }

        updateFolderState(isValid: false, error: errorMessage)
    }
}
