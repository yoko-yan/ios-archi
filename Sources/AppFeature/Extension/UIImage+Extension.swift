//
//  Created by yokoda.takayuki on 2023/07/18
//

import Foundation
import UIKit

extension UIImage {
    /// `Re-orientate` the image to `up`.
    ///
    func normalizedImage() -> UIImage? {
        if imageOrientation == .up {
            return self
        } else {
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            defer {
                UIGraphicsEndImageContext()
            }

            draw(in: CGRect(origin: .zero, size: size))

            return UIGraphicsGetImageFromCurrentImageContext()
        }
    }
}
