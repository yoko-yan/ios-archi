//
//  Created by apla on 2023/10/27
//

import CoreData
import Foundation

protocol IsiCloudSyncingUseCase {
    func execute() async throws -> Bool
}

struct IsiCloudSyncingUseCaseImpl: IsiCloudSyncingUseCase {
    func execute() async throws -> Bool {
        _ = try await ItemsRepository().getAll()

        let notifications = NotificationCenter.default
            .notifications(named: NSPersistentCloudKitContainer.eventChangedNotification, object: nil)
        for await notification in notifications {
            print("CloudKit Notification: \(notification)")

            let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event

            if let event {
                if let error = event.error {
                    print(error)
                    try await Task.sleep(nanoseconds: 2500 * 1000 * 1000)
                    return false // 同期がエラーになった場合、スプラッシュ解除
                }

                if event.type == .export, event.succeeded {
                    try await Task.sleep(nanoseconds: 2500 * 1000 * 1000)
                    return false // 正常に同期できた場合、スプラッシュ解除
                }
            }
        }
        try await Task.sleep(nanoseconds: 10 * 1000 * 1000 * 1000)
        return false // 万が一エラーも出なかった場合、スプラッシュ解除
    }
}
