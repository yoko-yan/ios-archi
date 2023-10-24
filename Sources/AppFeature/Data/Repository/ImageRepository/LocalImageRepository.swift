//
//  Created by yoko-yan on 2023/07/02.
//

import Foundation
import UIKit

final class LocalImageRepository {
    private func getFileURL(fileName: String) -> URL {
        // swiftlint:disable:next force_unwrapping
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Documents")
            .appendingPathComponent(fileName)
            .appendingPathExtension("png")
    }

    func save(_ image: UIImage, fileName: String) async throws {
        let fileUrl = getFileURL(fileName: fileName)
        print("save path: \(fileUrl.path)")
        guard let imageData = image.pngData() else {
            print("if image has no CGImageRef or invalid bitmap format")
            throw NSError(domain: "save image error", code: -1, userInfo: nil)
        }

        do {
            try imageData.write(to: fileUrl)
        } catch {
            print("Failed to save the image: \(error)")
            throw error
        }
    }

    func load(fileName: String?) async -> UIImage? {
        guard let fileName else { return nil }
        let filePath = getFileURL(fileName: fileName).path
        if FileManager.default.fileExists(atPath: filePath) {
            if let image = UIImage(contentsOfFile: filePath) {
                return image
            } else {
                print("Failed to load the image.")
                return nil
            }
        } else {
            print("Image file not found.")
            return nil
        }
    }
}
