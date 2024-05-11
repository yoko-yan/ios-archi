import UIKit

struct ItemDetailUiState: Equatable {
    var item: Item
    var spotImage: UIImage?

    var coordinatesText: String {
        item.coordinates?.textWitWhitespaces ?? String(localized: "Unregistered", bundle: .module)
    }
}
