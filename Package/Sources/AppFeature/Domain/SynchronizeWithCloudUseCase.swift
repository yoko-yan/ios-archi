import Core
import CoreData

protocol SynchronizeWithCloudUseCase: AutoInjectable, AutoMockable {
    func execute() async throws
}

struct SynchronizeWithCloudUseCaseImpl: SynchronizeWithCloudUseCase {
    @Injected(\.isCloudKitContainerAvailableUseCase) private var isCloudKitContainerAvailableUseCase
    @Injected(\.itemsRepository) private var itemsRepository

    func execute() async throws {
//        guard isCloudKitContainerAvailableUseCase.execute() else { return }

        _ = try await itemsRepository.fetchAll()

        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                let notifications = NotificationCenter.default.notifications(named: NSPersistentCloudKitContainer.eventChangedNotification, object: nil)
                for await notification in notifications {
                    print("CloudKit Notification: \(notification)")

                    let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event
                    print("event: \(String(describing: event))")

                    if let event {
                        if let error = event.error {
                            print(error)
//                                return // 同期がエラーになった場合、スプラッシュ解除
                            throw CancellationError()
                        }

                        if event.type == .export, event.succeeded {
                            return // 正常に同期できた場合、スプラッシュ解除
                        }
                    }
                }
            }

            group.addTask {
                // 万が一エラーも出なかった場合、タイムアウトさせてスプラッシュ解除
                try await Task.sleep(for: .seconds(10))
            }

            // swiftlint:disable:next force_unwrapping
            try await group.next()!
            group.cancelAll()
        }
    }
}
