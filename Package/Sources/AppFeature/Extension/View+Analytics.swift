//
//  Created by yoko-yan on 2024/05/01
//

import AnalyticsImpl
import Core
import SwiftUI

public extension View {
    func analyticsScreen(name: String, class screenClass: String? = nil, extraParams: [String: Any]? = nil) -> some View {
        onAppear {
            InjectedValues[\.analyticsService].logScreen(name: name, class: screenClass, extraParams: extraParams)
        }
    }
}
