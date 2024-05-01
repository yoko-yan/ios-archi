// Generated using Sourcery 2.1.1 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable line_length
// swiftlint:disable variable_name

import Core

public class AnalyticsServiceMock: AnalyticsService {
    public init() {}

    // MARK: - logEvent

    public var logEventNameParamsCallsCount = 0
    public var logEventNameParamsCalled: Bool {
        logEventNameParamsCallsCount > 0
    }

    public var logEventNameParamsReceivedArguments: (name: String, params: [String: Any]?)?
    public var logEventNameParamsReceivedInvocations: [(name: String, params: [String: Any]?)] = []
    public var logEventNameParamsClosure: ((String, [String: Any]?) -> Void)?

    public func logEvent(name: String, params: [String: Any]?) {
        logEventNameParamsCallsCount += 1
        logEventNameParamsReceivedArguments = (name: name, params: params)
        logEventNameParamsReceivedInvocations.append((name: name, params: params))
        logEventNameParamsClosure?(name, params)
    }

    // MARK: - logScreen

    public var logScreenNameClassExtraParamsCallsCount = 0
    public var logScreenNameClassExtraParamsCalled: Bool {
        logScreenNameClassExtraParamsCallsCount > 0
    }

    public var logScreenNameClassExtraParamsReceivedArguments: (name: String, screenClass: String?, extraParams: [String: Any]?)?
    public var logScreenNameClassExtraParamsReceivedInvocations: [(name: String, screenClass: String?, extraParams: [String: Any]?)] = []
    public var logScreenNameClassExtraParamsClosure: ((String, String?, [String: Any]?) -> Void)?

    public func logScreen(name: String, class screenClass: String?, extraParams: [String: Any]?) {
        logScreenNameClassExtraParamsCallsCount += 1
        logScreenNameClassExtraParamsReceivedArguments = (name: name, screenClass: screenClass, extraParams: extraParams)
        logScreenNameClassExtraParamsReceivedInvocations.append((name: name, screenClass: screenClass, extraParams: extraParams))
        logScreenNameClassExtraParamsClosure?(name, screenClass, extraParams)
    }
}
