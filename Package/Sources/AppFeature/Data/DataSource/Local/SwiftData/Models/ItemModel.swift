import Foundation
import SwiftData

@Model
final class ItemModel {
    // CloudKitは@Attribute(.unique)をサポートしないため削除
    // アプリケーション側で重複チェックを行う
    var id: String
    var coordinatesX: String?
    var coordinatesY: String?
    var coordinatesZ: String?
    var worldID: String?
    var name: String?
    var comment: String?

    // 画像をExternalStorageに保存
    @Attribute(.externalStorage) var spotImageData: Data?

    var createdAt: Date
    var updatedAt: Date

    init(
        id: String,
        coordinatesX: String? = nil,
        coordinatesY: String? = nil,
        coordinatesZ: String? = nil,
        worldID: String? = nil,
        name: String? = nil,
        comment: String? = nil,
        spotImageData: Data? = nil,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.coordinatesX = coordinatesX
        self.coordinatesY = coordinatesY
        self.coordinatesZ = coordinatesZ
        self.worldID = worldID
        self.name = name
        self.comment = comment
        self.spotImageData = spotImageData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
