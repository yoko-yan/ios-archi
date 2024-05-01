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
    @Injected(\.isCloudKitContainerAvailableUseCase) var isCloudKitContainerAvailableUseCase
    @Injected(\.itemsRepository) var itemsRepository

    func execute() async throws -> Bool {
        if !isCloudKitContainerAvailableUseCase.execute() {
            return false
        }

        _ = try await itemsRepository.fetchAll()

        try await withThrowingTaskGroup(of: Bool.self) { group in
            group.addTask {
                let notifications = NotificationCenter.default.notifications(named: NSPersistentCloudKitContainer.eventChangedNotification, object: nil)
                for await notification in notifications {
                    print("CloudKit Notification: \(notification)")

                    let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event

                    if let event {
                        if let error = event.error {
                            print(error)
                            return false // 同期がエラーになった場合、スプラッシュ解除
                        }

                        if event.type == .export, event.succeeded {
                            return false // 正常に同期できた場合、スプラッシュ解除
                        }
                    }
                }
                return false
            }

            group.addTask {
                // 万が一エラーも出なかった場合、タイムアウトさせてスプラッシュ解除
                try await Task.sleep(for: .seconds(10))
                return true
            }
            _ = try await group.next()
            group.cancelAll()
        }
        return false
    }
}
