import UIKit

// SwiftDataでは画像をItemModel.spotImageDataに直接保存するため、
// このUseCaseは不要になりました。
// ItemsRepository.insert/updateに画像を渡すことで保存されます。

protocol SaveSpotImageUseCase: Sendable {
    func execute(image: UIImage, fileName: String) async throws
}

struct SaveSpotImageUseCaseImpl: SaveSpotImageUseCase {
    func execute(image: UIImage, fileName: String) async throws {
        // SwiftDataでは画像はItemsRepository経由で保存されるため、
        // このメソッドは何もしません（後方互換性のため残しています）
        // 将来的には削除予定
    }
}
