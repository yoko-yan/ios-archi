//
//  Created by yoko-yan on 2023/10/12
//

import FirebaseCore
import Foundation

public protocol FirebaseAppProtocol: AnyObject {
    static func configure()
}

extension FirebaseApp: FirebaseAppProtocol {}

public final class FirebaseAppDI: FirebaseAppProtocol {
    static var canUseFirebase: Bool {
        Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
    }

    public static func configure() {
        if !FirebaseAppDI.canUseFirebase { return }
        FirebaseApp.configure()
    }
}
