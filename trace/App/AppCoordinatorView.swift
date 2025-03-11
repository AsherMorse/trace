import SwiftUI

struct AppCoordinatorView: View {
    @State private var folderViewModel = FolderSelectionViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if !hasCompletedOnboarding || !folderViewModel.isValidFolder {
                WelcomeView(
                    viewModel: folderViewModel,
                    hasCompletedOnboarding: $hasCompletedOnboarding
                )
                .onAppear {
                    setupFolderValidationHandler()
                }
            } else {
                // Temporary until we have a main view
//                LegacyMainView(folderViewModel: folderViewModel)
                ArchivedMainView()
            }
        }
        .onAppear {
            resolveAndValidateFolder()
        }
    }

    private func resolveAndValidateFolder() {
        FolderManager.shared.resolveBookmark { result in
            Task { @MainActor in
                switch result {
                case .success:
                    self.folderViewModel.validateSelectedFolder()

                    if hasCompletedOnboarding &&
                       (!self.folderViewModel.hasSelectedFolder || !self.folderViewModel.isValidFolder) {
                        hasCompletedOnboarding = false
                    }

                case .failure:
                    hasCompletedOnboarding = false
                    self.folderViewModel.validateSelectedFolder()
                }
            }
        }
    }

    private func setupFolderValidationHandler() {
        folderViewModel.onFolderSelected = { _ in
            if self.folderViewModel.isValidFolder && !self.hasCompletedOnboarding {
                hasCompletedOnboarding = true
            }
        }
    }
}
