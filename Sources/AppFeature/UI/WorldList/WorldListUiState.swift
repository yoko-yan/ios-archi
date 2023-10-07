//
//  Created by takayuki.yokoda on 2023/07/01.
//

import Foundation

struct WorldListUiState: Equatable {
    var items: [Seed] = []
    var deleteItems: [Seed]?
    var deleteAlertMessage: String?
}
