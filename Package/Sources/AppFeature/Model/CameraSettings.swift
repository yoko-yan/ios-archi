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

    /// プレビューアスペクト比
    var aspectRatio: AspectRatio

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

    /// プレビューアスペクト比
    enum AspectRatio: String, Codable, CaseIterable, Sendable {
        /// 1:1（正方形）
        case square
        /// アスペクト比を保持して画面全体を埋める（一部切れる）
        case fill
        /// アスペクト比を保持して全体を表示（黒い帯が出る）
        case fit
        /// アスペクト比を無視して画面全体に表示
        case stretch

        var displayName: String {
            switch self {
            case .square: return "正方形（1:1）"
            case .fill: return "全画面（切り抜き）"
            case .fit: return "全体表示"
            case .stretch: return "引き伸ばし"
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
        aspectRatio: .square,
        exposureMode: .auto,
        focusMode: .auto,
        zoomFactor: 1.0
    )

    // MARK: - Debug Presets

    /// デバッグ用設定例: 高速OCR＋英語認識
    ///
    /// 開発時にこの設定を使用するには、以下のように変更：
    /// ```swift
    /// static let `default` = CameraSettings.debugFastEnglish
    /// ```
    static let debugFastEnglish = CameraSettings(
        ocrRecognitionLevel: .fast,
        ocrLanguages: ["en-US"],
        imageCompressionSizeKB: 500.0,
        shutterButtonPosition: .center,
        flashEnabled: false,
        gridEnabled: false,
        aspectRatio: .fill,
        exposureMode: .auto,
        focusMode: .auto,
        zoomFactor: 1.0
    )

    /// デバッグ用設定例: グリッド表示ON＋右シャッター
    ///
    /// 開発時にこの設定を使用するには、以下のように変更：
    /// ```swift
    /// static let `default` = CameraSettings.debugGridRight
    /// ```
    static let debugGridRight = CameraSettings(
        ocrRecognitionLevel: .accurate,
        ocrLanguages: ["ja-JP"],
        imageCompressionSizeKB: 1000.0,
        shutterButtonPosition: .right,
        flashEnabled: false,
        gridEnabled: true,
        aspectRatio: .fill,
        exposureMode: .auto,
        focusMode: .auto,
        zoomFactor: 1.0
    )

    /// デバッグ用設定例: マニュアルモード＋ズーム2倍
    ///
    /// 開発時にこの設定を使用するには、以下のように変更：
    /// ```swift
    /// static let `default` = CameraSettings.debugManualZoom
    /// ```
    static let debugManualZoom = CameraSettings(
        ocrRecognitionLevel: .accurate,
        ocrLanguages: ["ja-JP"],
        imageCompressionSizeKB: 1000.0,
        shutterButtonPosition: .center,
        flashEnabled: true,
        gridEnabled: true,
        aspectRatio: .fill,
        exposureMode: .manual,
        focusMode: .manual,
        zoomFactor: 2.0
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
