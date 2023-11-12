//
//  Created by yokoda.takayuki on 2023/07/18
//

import Foundation
import UIKit

extension UIImage {
    func normalizedImage(isOpaque: Bool = true) -> UIImage? {
        if imageOrientation == .up {
            return self
        } else {
            let format = imageRendererFormat
            format.opaque = isOpaque
            return UIGraphicsImageRenderer(size: size, format: format).image { _ in
                draw(in: CGRect(origin: .zero, size: size))
            }
        }
    }

    func resized(toMaxSizeKB maxSizeKB: CGFloat, isOpaque: Bool = true) -> UIImage? {
        guard let pingData = pngData() else { fatalError("UIImage: No ping data") }

        var percentage = 1.0
        // 画像のデータサイズをKBで表示。
        var sizeKB = Double(pingData.count) / 1000.0
        while maxSizeKB <= sizeKB {
            percentage -= 0.1
            guard let image = resized(withPercentage: percentage, isOpaque: isOpaque) else {
                fatalError("UIImage: No ping data")
            }
            guard let imageData = image.pngData() else { fatalError("UIImage: No ping data") }
            sizeKB = Double(imageData.count) / 1000.0
            print("ファイルサイズ: " + "\(sizeKB)")
        }
        guard let returnImage = resized(withPercentage: percentage, isOpaque: isOpaque) else {
            fatalError("UIImage: No ping data")
        }
        return returnImage
    }

    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: canvas))
        }
    }

    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width / size.width * size.height)))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
