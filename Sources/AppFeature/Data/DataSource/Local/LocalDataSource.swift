////
////  Created by yoko-yan on 2023/10/11
////
//
// import CoreData
// import Foundation
//
// enum LocalDataSourceImpl<T: NSManagedObject> {
//    static var context: NSManagedObjectContext {
//        CoreDataManager.shared.viewContext
//    }
//
//    static func read(id: UUID) async throws -> T? {
//        let request = T.fetchRequest()
//        request.fetchLimit = 1
//        request.predicate = NSPredicate(
//            format: "id = %@", id.uuidString
//        )
//        var entity: T?
//        try await context.perform { [context] in
//            entity = try context.fetch(request).first as? T
//        }
//        return entity
//    }
//
//    static func delete(id: UUID) async throws {
//        guard let entity = try? await Self<T>.read(id: id)
//        else { fatalError() }
//        context.delete(entity)
//        try context.save()
//    }
// }
