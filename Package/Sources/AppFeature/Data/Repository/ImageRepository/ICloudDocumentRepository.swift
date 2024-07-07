import Core
import UIKit

// MARK: - Error

enum ICloudDocumentRepositoryError: Error {
    case loadImageFailed
    case saveImageFailed
}

protocol ICloudDocumentRepository: AutoInjectable, AutoMockable, Sendable {
    func saveImage(_ image: UIImage, fileName: String) async throws
    func loadImage(fileName: String) async throws -> UIImage?
}

struct ICloudDocumentRepositoryImpl: ICloudDocumentRepository {
    private func getFileURL(fileName: String) throws -> URL {
        let fileManager = FileManager.default
        // swiftlint:disable:next force_unwrapping
        let dirUrl = fileManager.url(forUbiquityContainerIdentifier: nil)!
            .appendingPathComponent("Documents")
            .appendingPathComponent("Image")
            .appendingPathComponent("Spot")

        // ディレクトリが存在しない場合
        if !fileManager.fileExists(atPath: dirUrl.path) {
            do {
                // ディレクトリ作成（エラーが出る可能性あり）
                try fileManager.createDirectory(at: dirUrl, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
                throw error
            }
        }
        return dirUrl
            .appendingPathComponent(fileName)
            .appendingPathExtension("png")
    }

    func saveImage(_ image: UIImage, fileName: String) async throws {
        let fileUrl = try getFileURL(fileName: fileName)
        print("save path: \(fileUrl.path)")

        let document = await Document(fileURL: fileUrl)
        Task { @MainActor in
            document.image = image
        }
        await document.save(to: fileUrl, for: .forOverwriting)
        await document.close()
    }

//    func load(fileName: String) async throws -> UIImage? {
//        let fileUrl = getFileURL(fileName: fileName)
//        print("save path: \(fileUrl.path)")
//
//        let document = Document(fileURL: fileUrl)
//        await document.open()
//        let image = document.image
//        await document.close()
//        return image
//    }

    func loadImage(fileName: String) async throws -> UIImage? {
        let fileUrl = try getFileURL(fileName: fileName)
        print("load path: \(fileUrl.path)")

        let document = await Document(fileURL: fileUrl)
        guard try await document.loadImage() else {
            throw ICloudDocumentRepositoryError.loadImageFailed
        }
        return await document.image
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

private extension Document {
    func loadImage() async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            performAsynchronousFileAccess {
                let fileCoordinator = NSFileCoordinator(filePresenter: self)
                fileCoordinator.coordinate(readingItemAt: self.fileURL, options: .withoutChanges, error: nil) { newURL in
                    if let imageData = try? Data(contentsOf: newURL), let image = UIImage(data: imageData) {
                        self.image = image
                        continuation.resume(returning: true)
                    } else {
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    }
}

#if DEBUG
extension ICloudDocumentRepositoryImpl {
    static var preview: some ICloudDocumentRepository {
        let repository = ICloudDocumentRepositoryMock()
        repository
            .loadImageFileNameClosure = { _ in
                UIImage(resource: .sampleCoordinates)
            }
        return repository
    }
}
#endif
