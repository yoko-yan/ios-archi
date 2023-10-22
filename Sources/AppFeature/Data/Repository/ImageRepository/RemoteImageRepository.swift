//
//  Created by yoko-yan on 2023/10/22
//

import Foundation
import UIKit

final class RemoteImageRepository {
    private var metadata: NSMetadataQuery!

    private func getFileURL(fileName: String) -> URL {
        // swiftlint:disable:next force_unwrapping
        FileManager.default.url(forUbiquityContainerIdentifier: nil)!
            .appendingPathComponent("Documents")
            .appendingPathComponent(fileName)
    }

    @MainActor
    func save(_ image: UIImage, fileName: String) throws {
        let fileUrl = getFileURL(fileName: fileName)
        print("save path: \(fileUrl.path)")

        let document = Document(fileURL: fileUrl)
        document.image = image
        document.save(to: fileUrl, for: .forOverwriting) { success in
            print("ファイル保存\(success ? "成功" : "失敗")")
        }
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
