//
//  ImageRepository.swift
//
//
//  Created by takayuki.yokoda on 2023/07/02.
//

import Foundation
import UIKit

final class ImageRepository {
    private func getFileURL(fileName: String) -> URL {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docDir.appendingPathComponent(fileName)
    }

    func save(_ image: UIImage, fileName: String) throws {
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

    func load(fileName: String?) -> UIImage? {
        guard let fileName else { return nil }
        let path = getFileURL(fileName: fileName).path
        print("load path: \(path)")
        if FileManager.default.fileExists(atPath: path) {
            if let image = UIImage(contentsOfFile: path) {
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
