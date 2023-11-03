//
//  Created by yoko-yan on 2023/10/12
//

import FirebaseCore
import Foundation

public enum FirebaseAppClient {
    public static func configure() {
        if !GoogleServiceClient.canUseFirebase { return }
        FirebaseApp.configure()
    }
}
