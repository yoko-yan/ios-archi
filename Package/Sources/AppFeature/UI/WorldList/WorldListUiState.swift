//
//  Created by yoko-yan on 2023/07/01.
//

import Foundation

struct WorldListUiState: Equatable {
    var worlds: [World] = []
    var deleteWorlds: [World]?
    var deleteAlertMessage: String?
}
