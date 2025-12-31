import Crashlytics
import Dependencies

// MARK: - DependencyValues

public struct CrashlyticsServiceKey: DependencyKey {
    public static let liveValue: any CrashlyticsService = CrashlyticsServiceImpl()
}

public extension DependencyValues {
    var crashlyticsService: any CrashlyticsService {
        get { self[CrashlyticsServiceKey.self] }
        set { self[CrashlyticsServiceKey.self] = newValue }
    }
}
