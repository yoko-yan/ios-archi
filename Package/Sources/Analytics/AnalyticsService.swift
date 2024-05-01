import Core

public protocol AnalyticsService: AutoInjectable, AutoMockable {
    func logEvent(name: String, params: [String: Any]?)
    func logScreen(name: String, class screenClass: String?, extraParams: [String: Any]?)
}

// MARK: - InjectedValues

private struct AnalyticsServiceKey: InjectionKey {
    static var currentValue: AnalyticsService = AnalyticsServiceMock()
}

public extension InjectedValues {
    var analyticsService: AnalyticsService {
        get { Self[AnalyticsServiceKey.self] }
        set { Self[AnalyticsServiceKey.self] = newValue }
    }
}
