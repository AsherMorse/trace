import SwiftUI
import AppKit

@main
struct traceApp: App {
    private let settingsViewModel = SettingsViewModel(settingsManager: AppSettingsManager())
    
    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
                .frame(minHeight: 500)
        }
        
        Settings {
            SettingsView(viewModel: settingsViewModel)
        }
    }
}
