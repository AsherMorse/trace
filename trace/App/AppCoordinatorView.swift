import SwiftUI

struct AppCoordinatorView: View {
    @StateObject private var folderViewModel = FolderSelectionViewModel()
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
                MainAppView(folderViewModel: folderViewModel)
            }
        }
        .onAppear {
            resolveAndValidateFolder()
        }
    }
    
    private func resolveAndValidateFolder() {
        FolderManager.shared.resolveBookmark { result in
            
            DispatchQueue.main.async {
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
        folderViewModel.onFolderSelected = { success in
            
            if self.folderViewModel.isValidFolder && !self.hasCompletedOnboarding {
                hasCompletedOnboarding = true
            }
        }
    }
}

// Temporary placeholder for the main app view
struct MainAppView: View {
    @ObservedObject var folderViewModel: FolderSelectionViewModel
    @State private var showFolderSettings = false
    
    var body: some View {
        VStack {
            Text("Trace Journal")
                .font(.largeTitle)
                .padding()
            
            Text("Journal folder: \(folderViewModel.displayPath)")
                .font(.callout)
                .padding()
            
            Button("Change Journal Folder") {
                showFolderSettings = true
            }
            .padding()
            
            Button("Reset Folder Selection") {
                FolderManager.shared.resetFolderSelection()
                folderViewModel.validateSelectedFolder()
            }
            .foregroundColor(.red)
            .padding()
        }
        .sheet(isPresented: $showFolderSettings) {
            FolderSelectionView(viewModel: folderViewModel)
        }
    }
}

struct AppCoordinatorView_Previews: PreviewProvider {
    static var previews: some View {
        AppCoordinatorView()
    }
} 
