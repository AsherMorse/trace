import SwiftUI
import AppKit

@main
struct traceApp: App {
    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
                .frame(minHeight: 500)
        }
    }
}
