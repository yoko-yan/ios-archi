//
//  Created by yoko-yan on 2023/10/22
//

import Foundation
import UIKit

@MainActor
final class RemoteImageRepository {
    private func getFileURL(fileName: String) -> URL {
        // swiftlint:disable:next force_unwrapping
        FileManager.default.url(forUbiquityContainerIdentifier: nil)!
            .appendingPathComponent("Documents")
            .appendingPathComponent(fileName)
            .appendingPathExtension(".png")
    }

    func save(_ image: UIImage, fileName: String) async throws {
        let fileUrl = getFileURL(fileName: fileName)
        print("save path: \(fileUrl.path)")

        let document = Document(fileURL: fileUrl)
        document.image = image
        await document.save(to: fileUrl, for: .forOverwriting)
        await document.close()
    }

    func load(fileName: String) async throws -> UIImage? {
        let fileUrl = getFileURL(fileName: fileName)
        print("save path: \(fileUrl.path)")

        let document = Document(fileURL: fileUrl)
        await document.open()
        let image = document.image
        await document.close()
        return image
    }
}

private class Document: UIDocument {
    var image: UIImage?

    override func contents(forType typeName: String) throws -> Any {
        image?.pngData() ?? Data()
    }

    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let contents = contents as? Data else { return }
        image = UIImage(data: contents)
    }
}
