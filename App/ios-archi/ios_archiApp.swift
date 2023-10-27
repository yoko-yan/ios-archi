//
//  Created by yokoda.takayuki on 2022/11/23.
//

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
