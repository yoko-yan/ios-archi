//
//  Created by takayuki.yokoda on 2023/07/01.
//

import Foundation

struct WorldListUiState: Equatable {
    var seeds: [Seed] = []
    var deleteItems: [Seed]?
    var deleteAlertMessage: String?
}
