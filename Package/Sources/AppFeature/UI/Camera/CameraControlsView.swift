import SwiftUI

/// カメラコントロールUI（シャッター、フラッシュ、グリッド、撮影設定等）
struct CameraControlsView: View {
    let shutterButtonPosition: CameraSettings.ShutterButtonPosition
    let flashEnabled: Bool
    let gridEnabled: Bool
    let aspectRatio: CameraSettings.AspectRatio
    let onCapture: () -> Void
    let onToggleFlash: () -> Void
    let onToggleGrid: () -> Void
    let onToggleAspectRatio: () -> Void
    let onSwitchCamera: () -> Void
    let onClose: () -> Void

    init(
        shutterButtonPosition: CameraSettings.ShutterButtonPosition,
        flashEnabled: Bool,
        gridEnabled: Bool,
        aspectRatio: CameraSettings.AspectRatio,
        onCapture: @escaping () -> Void,
        onToggleFlash: @escaping () -> Void,
        onToggleGrid: @escaping () -> Void,
        onToggleAspectRatio: @escaping () -> Void,
        onSwitchCamera: @escaping () -> Void,
        onClose: @escaping () -> Void
    ) {
        self.shutterButtonPosition = shutterButtonPosition
        self.flashEnabled = flashEnabled
        self.gridEnabled = gridEnabled
        self.aspectRatio = aspectRatio
        self.onCapture = onCapture
        self.onToggleFlash = onToggleFlash
        self.onToggleGrid = onToggleGrid
        self.onToggleAspectRatio = onToggleAspectRatio
        self.onSwitchCamera = onSwitchCamera
        self.onClose = onClose
    }

    var body: some View {
        VStack {
            // 上部コントロール
            HStack {
                Spacer()

                Button(action: onToggleAspectRatio) {
                    Image(systemName: aspectRatio == .square ? "square" : "rectangle")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().fill(Color.black.opacity(0.5)))
                }

                Button(action: onToggleFlash) {
                    Image(systemName: flashEnabled ? "bolt.fill" : "bolt.slash.fill")
                        .font(.title2)
                        .foregroundColor(flashEnabled ? .yellow : .white)
                        .padding()
                        .background(Circle().fill(Color.black.opacity(0.5)))
                }

                Button(action: onToggleGrid) {
                    Image(systemName: "grid")
                        .font(.title2)
                        .foregroundColor(gridEnabled ? .blue : .white)
                        .padding()
                        .background(Circle().fill(Color.black.opacity(0.5)))
                }
            }
            .padding()

            Spacer()

            // 下部コントロール（閉じる、シャッター、カメラ切り替えボタン）
            ZStack {
                // シャッターボタン（位置に応じて配置）
                HStack {
                    if shutterButtonPosition == .left {
                        shutterButton
                        Spacer()
                    } else if shutterButtonPosition == .center {
                        Spacer()
                        shutterButton
                        Spacer()
                    } else if shutterButtonPosition == .right {
                        Spacer()
                        shutterButton
                    }
                }

                // 閉じるボタンとカメラ切り替えボタン（固定位置）
                HStack {
                    // 閉じるボタン（常に左端）
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }

                    Spacer()

                    // カメラ切り替えボタン（常に右端）
                    Button(action: onSwitchCamera) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                }
            }
            .padding()
        }
    }

    private var shutterButton: some View {
        Button(action: onCapture) {
            Circle()
                .fill(Color.white)
                .frame(width: 70, height: 70)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 80, height: 80)
                )
        }
    }
}

#Preview {
    ZStack {
        Color.black
        CameraControlsView(
            shutterButtonPosition: .center,
            flashEnabled: false,
            gridEnabled: true,
            aspectRatio: .widescreen,
            onCapture: {},
            onToggleFlash: {},
            onToggleGrid: {},
            onToggleAspectRatio: {},
            onSwitchCamera: {},
            onClose: {}
        )
    }
}
