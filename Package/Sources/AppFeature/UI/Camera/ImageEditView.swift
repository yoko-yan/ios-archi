import SwiftUI

/// 撮影後の画像編集画面（システムのImagePicker allowsEditing相当）
struct ImageEditView: View {
    @Environment(\.dismiss) private var dismiss
    let image: UIImage
    let initialAspectRatio: CameraSettings.AspectRatio
    let onSave: (UIImage) -> Void
    let onCancel: () -> Void

    @State private var aspectRatio: CameraSettings.AspectRatio
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var viewWidth: CGFloat = UIScreen.main.bounds.width
    @State private var viewHeight: CGFloat = UIScreen.main.bounds.height

    init(
        image: UIImage,
        aspectRatio: CameraSettings.AspectRatio,
        onSave: @escaping (UIImage) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.image = image
        self.initialAspectRatio = aspectRatio
        self.onSave = onSave
        self.onCancel = onCancel
        self._aspectRatio = State(initialValue: aspectRatio)
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack {
                // 上部コントロール（アスペクト比切り替え）
                HStack {
                    Spacer()

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            aspectRatio = aspectRatio == .square ? .widescreen : .square
                        }
                    } label: {
                        Image(systemName: aspectRatio == .square ? "square" : "rectangle")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                }
                .padding()

                // 画像プレビュー領域（切り取り枠付き）
                GeometryReader { geometry in
                    let cropFrameWidth = geometry.size.width
                    let cropFrameHeight = cropHeight(for: aspectRatio, width: cropFrameWidth)

                    ZStack {
                        // 画像
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: cropFrameWidth, height: cropFrameHeight)
                            .scaleEffect(scale)
                            .offset(offset)
                            .clipped()
                            .gesture(
                                SimultaneousGesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            scale = lastScale * value
                                        }
                                        .onEnded { _ in
                                            lastScale = scale
                                        },
                                    DragGesture()
                                        .onChanged { value in
                                            offset = CGSize(
                                                width: lastOffset.width + value.translation.width,
                                                height: lastOffset.height + value.translation.height
                                            )
                                        }
                                        .onEnded { _ in
                                            lastOffset = offset
                                        }
                                )
                            )

                        // 切り取り枠オーバーレイ
                        CropOverlay(cropSize: CGSize(width: cropFrameWidth, height: cropFrameHeight))
                            .allowsHitTesting(false)
                    }
                    .frame(width: cropFrameWidth, height: cropFrameHeight)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        viewWidth = geometry.size.width
                        viewHeight = geometry.size.height
                    }
                    .onChange(of: geometry.size) { _, newSize in
                        viewWidth = newSize.width
                        viewHeight = newSize.height
                    }
                }

                // 操作ボタン
                HStack(spacing: 40) {
                    Button {
                        onCancel()
                        dismiss()
                    } label: {
                        Text("再撮影", bundle: .module)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                    }

                    Button {
                        // 編集された画像を保存
                        let editedImage = renderCroppedImage()
                        onSave(editedImage)
                        dismiss()
                    } label: {
                        Text("使用する", bundle: .module)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .transaction { transaction in
            transaction.animation = nil
        }
    }

    /// 切り取り枠内の画像をクロッピング
    private func renderCroppedImage() -> UIImage {
        // UIGraphicsImageRendererを使用してクロッピング
        let cropRect = calculateCropRect()
        let croppedImage = cropImage(image, toRect: cropRect)
        return croppedImage ?? image
    }

    /// アスペクト比に応じた切り取り枠の高さを計算
    private func cropHeight(for aspectRatio: CameraSettings.AspectRatio, width: CGFloat) -> CGFloat {
        switch aspectRatio {
        case .square:
            return width
        case .widescreen:
            return width * 9 / 16
        case .fill, .fit, .stretch:
            // フルスクリーンの場合はビューの高さを使用
            return viewHeight
        }
    }

    /// クロッピング領域の計算
    private func calculateCropRect() -> CGRect {
        let imageSize = image.size
        let cropFrameWidth = viewWidth
        let cropFrameHeight = cropHeight(for: aspectRatio, width: cropFrameWidth)

        // scaledToFillの実際のスケールを計算
        // scaledToFillは max(cropFrameWidth/width, cropFrameHeight/height) でスケーリングされる
        // 表示座標から画像座標への変換倍率は、そのスケールの逆数
        let scaleX = imageSize.width / cropFrameWidth
        let scaleY = imageSize.height / cropFrameHeight
        let coordinateScale = min(scaleX, scaleY)

        // 切り取り枠のサイズ（画像座標系）
        let cropWidthInImage = cropFrameWidth * coordinateScale / scale
        let cropHeightInImage = cropFrameHeight * coordinateScale / scale

        // 切り取り枠の中心位置（画像座標系）
        // 画像の中心から切り取り枠の中心までの距離 = -offset / scale * coordinateScale
        let centerXInImage = imageSize.width / 2 - offset.width / scale * coordinateScale
        let centerYInImage = imageSize.height / 2 - offset.height / scale * coordinateScale

        // 切り取り枠の左上位置
        let cropX = centerXInImage - cropWidthInImage / 2
        let cropY = centerYInImage - cropHeightInImage / 2

        return CGRect(x: cropX, y: cropY, width: cropWidthInImage, height: cropHeightInImage)
    }

    /// 画像をクロッピング
    private func cropImage(_ image: UIImage, toRect rect: CGRect) -> UIImage? {
        // クロッピング領域を画像の範囲内に制限
        let imageRect = CGRect(origin: .zero, size: image.size)
        guard imageRect.intersects(rect) else { return nil }

        let clampedRect = rect.intersection(imageRect)

        // UIGraphicsImageRendererを使用して、画像の向きを考慮してクロップ
        let renderer = UIGraphicsImageRenderer(size: clampedRect.size)
        return renderer.image { _ in
            // クロップ領域を原点に移動して描画
            let drawRect = CGRect(
                x: -clampedRect.origin.x,
                y: -clampedRect.origin.y,
                width: image.size.width,
                height: image.size.height
            )
            image.draw(in: drawRect)
        }
    }
}

/// 切り取り枠オーバーレイ
private struct CropOverlay: View {
    let cropSize: CGSize

    var body: some View {
        ZStack {
            // 外側の暗いマスク
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .mask(
                    Rectangle()
                        .overlay(
                            Rectangle()
                                .frame(width: cropSize.width, height: cropSize.height)
                                .blendMode(.destinationOut)
                        )
                )

            // 切り取り枠
            Rectangle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: cropSize.width, height: cropSize.height)

            // グリッド線（三分割法）
            Path { path in
                let verticalSpacing = cropSize.width / 3
                let horizontalSpacing = cropSize.height / 3

                // 縦線
                path.move(to: CGPoint(x: verticalSpacing, y: 0))
                path.addLine(to: CGPoint(x: verticalSpacing, y: cropSize.height))
                path.move(to: CGPoint(x: verticalSpacing * 2, y: 0))
                path.addLine(to: CGPoint(x: verticalSpacing * 2, y: cropSize.height))

                // 横線
                path.move(to: CGPoint(x: 0, y: horizontalSpacing))
                path.addLine(to: CGPoint(x: cropSize.width, y: horizontalSpacing))
                path.move(to: CGPoint(x: 0, y: horizontalSpacing * 2))
                path.addLine(to: CGPoint(x: cropSize.width, y: horizontalSpacing * 2))
            }
            .stroke(Color.white.opacity(0.5), lineWidth: 1)
            .frame(width: cropSize.width, height: cropSize.height)
        }
    }
}

#Preview {
    let placeholderImage = UIImage(systemName: "photo") ?? UIImage()
    return ImageEditView(
        image: placeholderImage,
        aspectRatio: .widescreen,
        onSave: { _ in },
        onCancel: {}
    )
}
