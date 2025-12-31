import Macros

@Mockable
public protocol CrashlyticsService: Sendable {
    func record(error: any Error)
    func log(_ message: String)
    func setUserID(_ userID: String?)
    func setCustomValue(_ value: Any?, forKey key: String)
}
