//
//  Created by yokoda.takayuki on 2022/11/23.
//

import Analytics
import AnalyticsImpl
import AppFeature
import Core
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
        let analyticsService: AnalyticsService = if BuildHelper.isPreview || BuildHelper.isTesting {
            AnalyticsServiceMock()
        } else {
            AnalyticsServiceImpl()
        }
        InjectedValues[\.analyticsService] = analyticsService
    }
}

private extension ios_archiApp {
    func setUp() {
        if BuildHelper.canUseFirebase {
            FirebaseApp.configure()
        }
    }
}
