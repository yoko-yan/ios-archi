//
//  Created by takayuki.yokoda on 2023/10/11
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
            if error != nil {
                fatalError("Cannot Load Core Data Model")
            }
        }

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
