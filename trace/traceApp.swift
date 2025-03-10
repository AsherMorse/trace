import SwiftUI
import AppKit

@main
struct TraceApp: App {
    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
                .frame(minWidth: 800, minHeight: 600)
        }
    }
}
