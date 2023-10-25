//
//  Created by yokoda.takayuki on 2022/11/23.
//

// swiftlint:disable explicit_top_level_acl
// swiftlint:disable explicit_acl

import AppFeature
import SwiftUI

@main
struct ios_archiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

// swiftlint:enable explicit_acl
// swiftlint:enable explicit_top_level_acl
