//
//  Created by yoko-yan on 2023/10/11
//

import CoreData
import Foundation

final class CoreDataManager {
    static let shared = CoreDataManager()

    private(set) lazy var viewContext = container.viewContext

    lazy var container: NSPersistentContainer = {
        let container: NSPersistentContainer

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

    private init() {}

    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
}
