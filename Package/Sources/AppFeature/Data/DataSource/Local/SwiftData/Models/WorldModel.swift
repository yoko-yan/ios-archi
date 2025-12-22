import Foundation
import SwiftData

@Model
final class WorldModel {
    // CloudKitは@Attribute(.unique)をサポートしないため削除
    // アプリケーション側で重複チェックを行う
    var id: String
    var name: String?
    var seed: String? // Seed.rawValueを文字列保存
    var comment: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String,
        name: String? = nil,
        seed: String? = nil,
        comment: String? = nil,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.name = name
        self.seed = seed
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
