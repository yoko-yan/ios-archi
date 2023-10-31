//
//  Created by yoko-yan on 2023/10/12
//

import FirebaseCore
import Foundation

public protocol FirebaseAppProtocol {
    static func configure()
}

extension FirebaseApp: FirebaseAppProtocol {}

public final class FirebaseAppCore: FirebaseAppProtocol {
    static var canUseFirebase: Bool {
        Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
    }

    public static func configure() {
        if !canUseFirebase { return }
        FirebaseApp.configure()
    }
}
