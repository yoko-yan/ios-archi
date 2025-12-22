import Foundation
import Vision

/// カメラ設定モデル
struct CameraSettings: Codable, Equatable, Sendable {
    // MARK: - OCR設定

    /// OCR認識精度レベル
    var ocrRecognitionLevel: OCRRecognitionLevel

    /// OCR認識言語（言語コード配列、例: ["ja-JP", "en-US"]）
    var ocrLanguages: [String]

    /// 画像圧縮サイズ（KB単位）
    var imageCompressionSizeKB: Double

    // MARK: - カメラUI設定

    /// シャッターボタンの位置
    var shutterButtonPosition: ShutterButtonPosition

    /// フラッシュ有効/無効
    var flashEnabled: Bool

    /// グリッド表示有効/無効
    var gridEnabled: Bool

    // MARK: - 撮影設定

    /// 露出モード
    var exposureMode: ExposureMode

    /// フォーカスモード
    var focusMode: FocusMode

    /// ズーム倍率（1.0〜5.0）
    var zoomFactor: Double

    // MARK: - Nested Types

    /// OCR認識精度レベル
    enum OCRRecognitionLevel: String, Codable, CaseIterable, Sendable {
        case accurate
        case fast

        var vnLevel: VNRequestTextRecognitionLevel {
            switch self {
            case .accurate: return .accurate
            case .fast: return .fast
            }
        }

        var displayName: String {
            switch self {
            case .accurate: return "高精度"
            case .fast: return "高速"
            }
        }
    }

    /// シャッターボタン位置
    enum ShutterButtonPosition: String, Codable, CaseIterable, Sendable {
        case center
        case right
        case left

        var displayName: String {
            switch self {
            case .center: return "中央"
            case .right: return "右"
            case .left: return "左"
            }
        }
    }

    /// 露出モード
    enum ExposureMode: String, Codable, CaseIterable, Sendable {
        case auto
        case manual

        var displayName: String {
            switch self {
            case .auto: return "自動"
            case .manual: return "マニュアル"
            }
        }
    }

    /// フォーカスモード
    enum FocusMode: String, Codable, CaseIterable, Sendable {
        case auto
        case manual

        var displayName: String {
            switch self {
            case .auto: return "自動"
            case .manual: return "マニュアル"
            }
        }
    }

    // MARK: - Factory

    /// デフォルト設定
    static let `default` = CameraSettings(
        ocrRecognitionLevel: .accurate,
        ocrLanguages: ["ja-JP"],
        imageCompressionSizeKB: 1000.0,
        shutterButtonPosition: .center,
        flashEnabled: false,
        gridEnabled: false,
        exposureMode: .auto,
        focusMode: .auto,
        zoomFactor: 1.0
    )

    // MARK: - Validation

    /// 設定値が有効かをバリデーション
    func validate() -> ValidationResult {
        var errors: [ValidationError] = []

        // OCR言語が空でないこと
        if ocrLanguages.isEmpty {
            errors.append(.emptyLanguages)
        }

        // 画像圧縮サイズが正の値であること
        if imageCompressionSizeKB <= 0 {
            errors.append(.invalidCompressionSize)
        }

        // ズーム倍率が範囲内であること
        if zoomFactor < 1.0 || zoomFactor > 5.0 {
            errors.append(.invalidZoomFactor)
        }

        return errors.isEmpty ? .valid : .invalid(errors)
    }

    enum ValidationError: Error {
        case emptyLanguages
        case invalidCompressionSize
        case invalidZoomFactor
    }

    enum ValidationResult {
        case valid
        case invalid([ValidationError])
    }
}
