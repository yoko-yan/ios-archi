import UIKit

struct SpotImage: Equatable {
    let imageName: SpotImageName?
    let image: UIImage?
    let isLoading: Bool

    init(imageName: SpotImageName?, image: UIImage?, isLoading: Bool = false) {
        self.imageName = imageName
        self.image = image
        self.isLoading = isLoading
    }
}
