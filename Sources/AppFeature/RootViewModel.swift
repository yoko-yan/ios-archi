//
//  Created by yoko-yan on 2023/10/25
//

import Combine
import CoreData
import Foundation

// MARK: - View model

@MainActor
final class RootViewModel: ObservableObject {
    @Published private(set) var uiState = RootUiState()

    init() {
        Task.detached {
            _ = try await ItemsRepository().load()

            let notifications = NotificationCenter.default
                .notifications(named: NSPersistentCloudKitContainer.eventChangedNotification, object: nil)
            for await notification in notifications {
                print("CloudKit Notification: \(notification)")

                let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event

                if let event {
                    if let error = event.error {
                        print(error)
                        return
                    }

                    if event.type == .export, event.succeeded {
                        await MainActor.run {
                            self.uiState.isLaunching = false
                        }
                    }
                }
            }
        }
    }
}
