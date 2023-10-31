//
//  Created by apla on 2023/10/31
//

import FirebaseAnalytics
import Foundation
import SwiftUI

public protocol AnalyticsProtocol {
    static func logEvent(_ name: String, parameters: [String: Any]?)
}

public final class AnalyticsDI: AnalyticsProtocol {}

public extension AnalyticsDI {
    static func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        if !FirebaseAppDI.canUseFirebase { return }
        Analytics.logEvent(name, parameters: parameters)
    }

    static func screenEvent(name: String, class screenClass: String? = nil, extraParameters: [String: Any]? = nil) {
        if !FirebaseAppDI.canUseFirebase { return }
        var params: [String: Any] = [AnalyticsParameterScreenName: name]
        if let screenClass {
            params[AnalyticsParameterScreenClass] = screenClass
        }
        if let extraParams = extraParameters {
            params.merge(extraParams) { _, new in new }
        }
        Analytics.logEvent(AnalyticsEventScreenView, parameters: params)
    }
}

public extension View {
    func analyticsScreen(name: String, class screenClass: String? = nil, extraParameters: [String: Any]? = nil) -> some View {
        onAppear {
            AnalyticsDI.screenEvent(name: name, class: screenClass, extraParameters: extraParameters)
        }
    }
}
