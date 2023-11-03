//
//  Created by yoko-yan on 2023/10/31
//

import FirebaseAnalytics
import Foundation

public enum AnalyticsClient {
    public static func logEvent(name: String, class screenClass: String? = nil, extraParameters: [String: Any]? = nil) {
        if !GoogleServiceClient.canUseFirebase { return }
        var params: [String: Any] = [AnalyticsParameterScreenName: name]
        if let screenClass {
            params[AnalyticsParameterScreenClass] = screenClass
        }
        if let extraParams = extraParameters {
            params.merge(extraParams) { _, new in new }
        }
        Analytics.logEvent(name, parameters: params)
    }
}
