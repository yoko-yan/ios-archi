import Analytics
import Dependencies

// MARK: - DependencyValues

public struct AnalyticsServiceKey: DependencyKey {
    public static let liveValue: any AnalyticsService = AnalyticsServiceImpl()
}

public extension DependencyValues {
    var analyticsService: any AnalyticsService {
        get { self[AnalyticsServiceKey.self] }
        set { self[AnalyticsServiceKey.self] = newValue }
    }
}
