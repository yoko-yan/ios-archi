import Crashlytics
import FirebaseCrashlytics

public final class CrashlyticsServiceImpl: CrashlyticsService {
    public init() {}

    public func record(error: any Error) {
        Crashlytics.crashlytics().record(error: error)
    }

    public func log(_ message: String) {
        Crashlytics.crashlytics().log(message)
    }

    public func setUserID(_ userID: String?) {
        Crashlytics.crashlytics().setUserID(userID)
    }

    public func setCustomValue(_ value: Any?, forKey key: String) {
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    }
}
