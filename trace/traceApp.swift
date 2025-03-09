import SwiftUI
import AppKit

@main
struct traceApp: App {
    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
                .frame(minWidth: 800, minHeight: 600)
        }
    }
}
