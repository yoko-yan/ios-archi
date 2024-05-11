import Foundation

enum AppError {
    case network(errorDescription: String, failureReason: String, recoverySuggestion: String)
    case unknown(localizedDescription: String)

    var isCommonError: Bool {
        if case .network = self {
            return true
        }
        return false
    }

    init(_ error: Error) {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut:
                // Handle session timeout
                self = .network(
                    errorDescription: "ネットワークエラー",
                    failureReason: "ネットワーク接続がタイムアウトしました。",
                    recoverySuggestion: "インターネット接続がオフになっていないかご確認ください。"
                )
            case .notConnectedToInternet:
                // Handle not connected to internet
                self = .network(
                    errorDescription: "ネットワークエラー",
                    failureReason: "ネットワーク接続にエラーが発生しました。",
                    recoverySuggestion: "少し時間をおいてから再度お試しください。"
                )
            default:
                self = .network(
                    errorDescription: "ネットワークエラー",
                    failureReason: "ネットワーク接続にエラーが発生しました。",
                    recoverySuggestion: "少し時間をおいてから再度お試しください。"
                )
            }
        }
        self = .unknown(localizedDescription: error.localizedDescription)
    }
}

extension AppError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .network(errorDescription, _, _): errorDescription
        case let .unknown(localizedDescription): localizedDescription
        }
    }

    var failureReason: String? {
        switch self {
        case let .network(_, failureReason, _): failureReason
        case .unknown: "エラーの発生理由は不明です。"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case let .network(_, _, recoverySuggestion): recoverySuggestion
        case .unknown: "再度、実行してみてください。"
        }
    }
}
