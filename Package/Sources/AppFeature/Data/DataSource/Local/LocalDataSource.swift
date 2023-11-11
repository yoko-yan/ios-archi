//
//  Created by yoko-yan on 2023/10/11
//

import CoreData
import Foundation

final class LocalDataSource<T: NSManagedObject> {
    private let coreDataManager: CoreDataManager
    private var viewContext: NSManagedObjectContext {
        coreDataManager.viewContext
    }

    init(
        coreDataManager: some CoreDataManager = CoreDataManager.shared
    ) {
        self.coreDataManager = coreDataManager
    }

    func getEntity() -> T {
        T(context: viewContext)
    }

    func fetch(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) async throws -> [T] {
        let request = T.fetchRequest()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return try viewContext.fetch(request) as? [T] ?? []
    }

    func read(id: UUID) async throws -> T? {
        let request = T.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(
            format: "id = %@", id.uuidString
        )
        var entity: T?
        try await viewContext.perform { [viewContext] in
            entity = try viewContext.fetch(request).first as? T
        }
        return entity
    }

    func delete(id: UUID) async throws {
        if let entity = try await read(id: id) {
            viewContext.delete(entity)
            try viewContext.save()
        }
    }

    func saveContext() throws {
        try coreDataManager.saveContext()
    }
}
