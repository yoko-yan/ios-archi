//
//  Created by yoko-yan on 2023/10/12
//

import FirebaseCore
import Foundation

public protocol FirebaseAppProtocol: AnyObject {
    static func configure()
}

extension FirebaseApp: FirebaseAppProtocol {}

public class FirebaseAppDI: FirebaseAppProtocol {
    private static var canUseFirebase: Bool {
        Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
    }

    public static func configure() {
        if canUseFirebase {
            FirebaseApp.configure()
        }
    }
}
