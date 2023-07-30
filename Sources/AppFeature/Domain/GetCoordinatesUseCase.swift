//
//  Created by yokoda.takayuki on 2023/07/27
//

import Combine
import Foundation
import UIKit

struct GetCoordinatesUseCaseImpl {
    func execute(image: UIImage) -> AnyPublisher<Seed?, RecognizeTextError> {
        Fail(error: RecognizeTextError.getCgImage)
            .eraseToAnyPublisher()
    }
}
