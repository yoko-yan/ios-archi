//
//  Created by yoko-yan on 2023/10/07
//

import Foundation

struct TimeLineUiState: Equatable {
    var items: [Item] = []
    var spotImages: [String: SpotImage?] = [:]
    var deleteItems: [Item]?
    var deleteAlertMessage: String?
}
