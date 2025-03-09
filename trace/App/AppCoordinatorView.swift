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
            } else {
                MainAppView(folderViewModel: folderViewModel)
            }
        }
        .onAppear {
            checkFolderStatus()
        }
    }
    
    private func checkFolderStatus() {
        // If we've already completed onboarding but the folder is no longer valid,
        // we need to show the welcome view again
        if hasCompletedOnboarding {
            folderViewModel.validateSelectedFolder()
            
            if !folderViewModel.hasSelectedFolder || !folderViewModel.isValidFolder {
                // Reset the onboarding flag if the folder is no longer valid
                hasCompletedOnboarding = false
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
