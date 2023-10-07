//
//  Created by takayuki.yokoda on 2023/10/07
//

import Foundation

struct PhotosUiState: Equatable {
    var items: [Item] = []
    var deleteItems: [Item]?
    var deleteAlertMessage: String?
}
