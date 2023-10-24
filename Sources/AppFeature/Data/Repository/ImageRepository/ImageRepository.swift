//
//  Created by yoko-yan on 2023/10/25
//

import Foundation
import UIKit

final class ImageRepository {
    private var isiCloudEnabled: Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }

    func save(_ image: UIImage, fileName: String) async throws {
        if isiCloudEnabled {
            try await RemoteImageRepository().save(image, fileName: fileName)
        }
        try await LocalImageRepository().save(image, fileName: fileName)
    }

    func load(fileName: String?) async throws -> UIImage? {
        guard let fileName else { return nil }
        if isiCloudEnabled {
            let image = try await RemoteImageRepository().load(fileName: fileName)
            if let image {
                try await LocalImageRepository().save(image, fileName: fileName)
            }
            return image
        } else {
            return try await LocalImageRepository().load(fileName: fileName)
        }
    }
}
