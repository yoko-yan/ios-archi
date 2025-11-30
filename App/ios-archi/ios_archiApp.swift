import Analytics
import AnalyticsImpl
import AppFeature
import Core
import Dependencies
import FirebaseCore
import SwiftUI

@main
struct ios_archiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }

    init() {
        // swift-dependencies uses liveValue by default
        // For preview/testing, dependencies are overridden using withDependencies
    }
}

private extension ios_archiApp {
    func setUp() {
        if !BuildHelper.isPreview, !BuildHelper.isTesting, BuildHelper.canUseFirebase {
            FirebaseApp.configure()
        }
    }
}
