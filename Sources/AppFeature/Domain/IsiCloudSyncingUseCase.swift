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
                    try await Task.sleep(nanoseconds: 2500000000)
                    return false
                }

                if event.type == .export, event.succeeded {
                    try await Task.sleep(nanoseconds: 2500000000)
                    return false
                }
            }
        }
        try await Task.sleep(nanoseconds: 2500000000)
        return false
    }
}
