//
//  Created by yoko-yan on 2023/11/03
//

import Foundation

public enum GoogleServiceClient {
    static var canUseFirebase: Bool {
        let environment = ProcessInfo.processInfo.environment
        if environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" { return false } // Running previews
        if environment["XCTestConfigurationFilePath"] != nil { return false } // Running tests
        return Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
    }
}
