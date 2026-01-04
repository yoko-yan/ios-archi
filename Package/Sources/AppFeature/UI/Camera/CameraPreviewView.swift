import AVFoundation
import SwiftUI
import UIKit

/// AVCaptureVideoPreviewLayerをSwiftUIで使用するためのラッパー
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    let aspectRatio: CameraSettings.AspectRatio

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = videoGravity(for: aspectRatio)
        previewLayer.frame = view.bounds

        view.layer.addSublayer(previewLayer)

        // レイヤーのフレームを自動的に更新
        context.coordinator.previewLayer = previewLayer

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // プレビューレイヤーのフレームをビューのサイズに合わせて更新
        if let previewLayer = context.coordinator.previewLayer {
            DispatchQueue.main.async {
                previewLayer.frame = uiView.bounds
                previewLayer.videoGravity = videoGravity(for: aspectRatio)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    private func videoGravity(for aspectRatio: CameraSettings.AspectRatio) -> AVLayerVideoGravity {
        switch aspectRatio {
        case .square:
            // 正方形の場合もfillを使用し、外側でクリッピングする
            return .resizeAspectFill
        case .widescreen:
            // 16:9の場合もfillを使用し、外側でクリッピングする
            return .resizeAspectFill
        case .fill:
            return .resizeAspectFill
        case .fit:
            return .resizeAspect
        case .stretch:
            return .resize
        }
    }

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}
