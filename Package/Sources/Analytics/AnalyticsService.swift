import Spyable

@Spyable
public protocol AnalyticsService: Sendable {
    func logEvent(name: String, params: [String: Any]?)
    func logScreen(name: String, class screenClass: String?, extraParams: [String: Any]?)
}
