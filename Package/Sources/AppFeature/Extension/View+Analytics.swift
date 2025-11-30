import AnalyticsImpl
import Dependencies
import SwiftUI

public extension View {
    func analyticsScreen(name: String, class screenClass: String? = nil, extraParams: [String: Any]? = nil) -> some View {
        onAppear {
            @Dependency(\.analyticsService) var analyticsService
            analyticsService.logScreen(name: name, class: screenClass, extraParams: extraParams)
        }
    }
}
