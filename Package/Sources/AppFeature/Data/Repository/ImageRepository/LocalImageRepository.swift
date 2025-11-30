import Dependencies
import Macros
import UIKit

enum LocalImageRepositoryError: Error {
    case loadImageFailed
    case saveImageFailed
    case failedToLoadImage
    case imageFileNotFound
}

@Mockable
protocol LocalImageRepository: Sendable {
    func saveImage(_ image: UIImage, fileName: String) async throws
    func loadImage(fileName: String?) async throws -> UIImage?
}

// MARK: - DependencyValues

private struct LocalImageRepositoryKey: DependencyKey {
    static let liveValue: any LocalImageRepository = LocalImageRepositoryImpl()
}

extension DependencyValues {
    var localImageRepository: any LocalImageRepository {
        get { self[LocalImageRepositoryKey.self] }
        set { self[LocalImageRepositoryKey.self] = newValue }
    }
}

struct LocalImageRepositoryImpl: LocalImageRepository {
    private func getFileURL(fileName: String) throws -> URL {
        let fileManager = FileManager.default
        // swiftlint:disable:next force_unwrapping
        let dirUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
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
        guard let imageData = image.pngData() else {
            print("if image has no CGImageRef or invalid bitmap format")
            throw LocalImageRepositoryError.saveImageFailed
        }

        do {
            try imageData.write(to: fileUrl)
        } catch {
            print("Failed to save the image: \(error)")
            throw error
        }
    }

    func loadImage(fileName: String?) async throws -> UIImage? {
        guard let fileName else { return nil }
        let filePath = try getFileURL(fileName: fileName).path
        print("load path: \(filePath)")
        if FileManager.default.fileExists(atPath: filePath) {
            if let image = UIImage(contentsOfFile: filePath) {
                return image
            } else {
                print("Failed to load the image.")
                throw LocalImageRepositoryError.failedToLoadImage
            }
        } else {
            print("Image file not found.")
            throw LocalImageRepositoryError.imageFileNotFound
        }
    }
}

#if DEBUG
extension LocalImageRepositoryImpl {
    static var preview: some LocalImageRepository {
        let repository = LocalImageRepositoryMock()
        repository
            .loadImageFileNameClosure = { _ in
                UIImage(resource: .sampleCoordinates)
            }
        return repository
    }
}
#endif
