//
//  Created by yoko-yan on 2023/10/27
//

import Core
import CoreData
import Foundation

protocol SynchronizeWithCloudUseCase: AutoInjectable, AutoMockable {
    func execute() async throws -> Bool
}

struct SynchronizeWithCloudUseCaseImpl: SynchronizeWithCloudUseCase {
    @Injected(\.itemsRepository) var itemsRepository

    func execute() async throws -> Bool {
        _ = try await itemsRepository.fetchAll()

        let notifications = NotificationCenter.default
            .notifications(named: NSPersistentCloudKitContainer.eventChangedNotification, object: nil)
        for await notification in notifications {
            print("CloudKit Notification: \(notification)")

            let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event

            if let event {
                if let error = event.error {
                    print(error)
                    try await Task.sleep(nanoseconds: 2_500_000_000)
                    return false // 同期がエラーになった場合、スプラッシュ解除
                }

                if event.type == .export, event.succeeded {
                    try await Task.sleep(nanoseconds: 2_500_000_000)
                    return false // 正常に同期できた場合、スプラッシュ解除
                }
            }
        }
        try await Task.sleep(nanoseconds: 10_000_000_000)
        return false // 万が一エラーも出なかった場合、スプラッシュ解除
    }
}
