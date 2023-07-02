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

    func save(_ image: UIImage, fileName: String) {
        let fileUrl = getFileURL(fileName: fileName)
        print("save path: \(fileUrl.path)")
        guard let imageData = image.pngData() else {
            return
        }

        do {
            try imageData.write(to: fileUrl)
        } catch {
            fatalError("Failed to save the image: \(error)")
        }
    }

    func load(fileName: String) -> UIImage? {
        let path = getFileURL(fileName: fileName).path
        print("load path: \(path)")
        if FileManager.default.fileExists(atPath: path) {
            if let image = UIImage(contentsOfFile: path) {
                return image
            } else {
                fatalError("Failed to load the image.")
            }
        } else {
            print("Image file not found.")
            return nil
        }
    }
}
