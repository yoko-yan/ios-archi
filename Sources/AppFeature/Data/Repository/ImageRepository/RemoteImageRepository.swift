//
//  Created by apla on 2023/10/22
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

    @MainActor
    private func load(fileName: String?, completion: @escaping @Sendable (UIImage?) -> Void) {
        guard let fileName else { return completion(nil) }
        let fileURL = getFileURL(fileName: fileName)

        metadata = NSMetadataQuery()
        metadata.predicate = NSPredicate(format: "%K like '\(fileName)'", NSMetadataItemFSNameKey)
        metadata.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]

        NotificationCenter.default.addObserver(forName: .NSMetadataQueryDidFinishGathering, object: metadata, queue: nil) { notification in
            guard let query = notification.object as? NSMetadataQuery else { completion(nil); return }

            if query.resultCount == 0 {
                print("ファイルが見つからなかった")
                return
            }

            guard let url = (query.results[0] as AnyObject).value(forAttribute: NSMetadataItemURLKey) as? URL else { completion(nil); return }
            let document = Document(fileURL: url)
            document.open { success in
                if success {
                    print(url.absoluteString)
                    print(fileURL.absoluteString)
//                    print("ファイル読み込み: \(document.image ?? "nil")")
                    completion(document.image)
                } else {
                    print("ファイル読み込み失敗")
                    completion(nil)
                }
            }
        }

        metadata.start()
    }

    @MainActor
    func load(fileName: String?) async throws -> UIImage? {
        try await withCheckedThrowingContinuation { continuation in
            load(fileName: fileName) { image in
                continuation.resume(returning: image)
            }
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
