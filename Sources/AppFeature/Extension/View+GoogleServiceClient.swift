//
//  Created by yoko-yan on 2023/11/03
//

#if canImport(FirebaseCore)
import GoogleServiceClient
#endif
import SwiftUI

public extension View {
    func analyticsScreen(name: String, class screenClass: String? = nil, extraParameters: [String: Any]? = nil) -> some View {
        onAppear {
            #if canImport(FirebaseCore)
            AnalyticsClient.logEvent(name: name, class: screenClass, extraParameters: extraParameters)
            #endif
        }
    }
}
