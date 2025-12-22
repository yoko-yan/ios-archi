import Foundation
import SwiftData

@Model
final class WorldModel {
    // CloudKitは@Attribute(.unique)をサポートしないため削除
    // アプリケーション側で重複チェックを行う
    // CloudKit統合のため、デフォルト値を設定
    var id: String = UUID().uuidString
    var name: String?
    var seed: String? // Seed.rawValueを文字列保存
    var comment: String?

    // CloudKit統合のため、デフォルト値を設定
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    init(
        id: String = UUID().uuidString,
        name: String? = nil,
        seed: String? = nil,
        comment: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.seed = seed
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
