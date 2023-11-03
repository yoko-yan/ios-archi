//
//  Created by yoko-yan on 2023/10/26
//

#if canImport(FirebaseCore)
import GoogleServiceClient
#endif
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        #if canImport(FirebaseCore)
        FirebaseAppClient.configure()
        #endif
        return true
    }
}
