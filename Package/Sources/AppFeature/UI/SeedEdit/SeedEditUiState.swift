import UIKit

struct SeedEditUiState {
    enum Event: Equatable {
        case onChanged
    }

    var seedText: String
    var seed: Seed? { Seed(seedText) }

    var seedImage: UIImage?
    var validationErrors: [SeedValidationError] = []
    var events: [Event] = []

    var valid: Bool {
        validationErrors.isEmpty
    }
}
