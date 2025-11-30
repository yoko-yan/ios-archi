import Analytics
import FirebaseAnalytics

public final class AnalyticsServiceImpl: AnalyticsService {
    public init() {}

    public func logEvent(name: String, params: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: params)
    }

    public func logScreen(name: String, class screenClass: String? = nil, extraParams: [String: Any]? = nil) {
        var params: [String: Any] = [AnalyticsParameterScreenName: name]
        if let screenClass {
            params[AnalyticsParameterScreenClass] = screenClass
        }
        if let extraParams {
            params.merge(extraParams) { _, new in new }
        }
        Analytics.logEvent(AnalyticsEventScreenView, parameters: params)
    }
}
