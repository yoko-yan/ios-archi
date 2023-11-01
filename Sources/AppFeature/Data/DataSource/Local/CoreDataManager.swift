//
//  Created by yoko-yan on 2023/10/11
//

import CoreData
import Foundation

// MARK: - Error

enum CoreDataManagerError: Error {
    case updateFailed
    case deleteFailed
}

public final class CoreDataManager {
    public static let shared = CoreDataManager()

    private(set) lazy var viewContext = container.viewContext

    lazy var container: NSPersistentCloudKitContainer = {
        let container: NSPersistentCloudKitContainer

        // swiftlint:disable:next force_unwrapping
        let modelURL = Bundle.module.url(forResource: "Model", withExtension: "momd")!
        // swiftlint:disable:next force_unwrapping
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        container = NSPersistentCloudKitContainer(name: "Model", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        // データが重複しないよう外部変更はメモリ内を置き換える
        container.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        // クラウドからの変更を自動取得して適用する
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    private init() {
        #if DEBUG
        Self.checkLightWeightMigration()
        #endif
    }

    func saveContext() throws {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                throw error
            }
        }
    }
}

// MARK: - Migration

extension CoreDataManager {
    static func checkLightWeightMigration() {
        let subdirectory = "Model.momd"
        // swiftlint:disable:next force_unwrapping
        let sourceModel = NSManagedObjectModel(contentsOf: Bundle.module.url(forResource: "Model", withExtension: "mom", subdirectory: subdirectory)!)!
        // swiftlint:disable:next force_unwrapping
        let destinationModel = NSManagedObjectModel(contentsOf: Bundle.module.url(forResource: "Model 2", withExtension: "mom", subdirectory: subdirectory)!)!
        do {
            try NSMappingModel.inferredMappingModel(forSourceModel: sourceModel, destinationModel: destinationModel)
            print("migrationCheck: OK")
        } catch {
            fatalError("migrationCheck: NG,  error \(error)")
        }
    }
}
