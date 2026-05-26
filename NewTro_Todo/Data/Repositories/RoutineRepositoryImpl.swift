import Foundation
import RealmSwift

final class RoutineRepositoryImpl: RoutineRepositoryProtocol {

    @MainActor func fetchAll() throws -> [RoutineEntity] {
        let realm = try Realm()
        return realm.objects(RoutineObject.self)
            .sorted(byKeyPath: "createdAt", ascending: false)
            .map { $0.toDomain() }
    }

    @MainActor func fetch(id: String) throws -> RoutineEntity? {
        let realm = try Realm()
        guard let oid = try? ObjectId(string: id) else { return nil }
        return realm.objects(RoutineObject.self)
            .filter("objectID == %@", oid)
            .first?
            .toDomain()
    }

    @MainActor func add(_ entity: RoutineEntity) throws -> RoutineEntity {
        let realm = try Realm()
        let obj = RoutineObject()
        // 신규 생성 — objectID 는 Realm 이 자동 할당
        obj.title = entity.title
        obj.startDate = Calendar.current.startOfDay(for: entity.startDate)
        obj.endDate = Calendar.current.startOfDay(for: entity.endDate)
        obj.repeatKind = entity.repeatKind.rawValue
        obj.weekdays.append(objectsIn: entity.weekdays)
        obj.monthDays.append(objectsIn: entity.monthDays.map { $0.rawValue })
        obj.yearMonth = entity.yearMonth
        obj.yearDay = entity.yearDay?.rawValue ?? 0
        obj.importance = entity.importance.rawValue
        obj.colorName = entity.colorName
        let now = Date()
        obj.createdAt = now
        obj.updatedAt = now
        try realm.write { realm.add(obj) }
        return obj.toDomain()
    }

    @MainActor func update(_ entity: RoutineEntity) throws -> RoutineEntity {
        let realm = try Realm()
        guard let oid = try? ObjectId(string: entity.id),
              let obj = realm.objects(RoutineObject.self)
                .filter("objectID == %@", oid).first
        else { throw RepositoryError.notFound }

        try realm.write {
            obj.title = entity.title
            obj.startDate = Calendar.current.startOfDay(for: entity.startDate)
            obj.endDate = Calendar.current.startOfDay(for: entity.endDate)
            obj.repeatKind = entity.repeatKind.rawValue
            obj.weekdays.removeAll()
            obj.weekdays.append(objectsIn: entity.weekdays)
            obj.monthDays.removeAll()
            obj.monthDays.append(objectsIn: entity.monthDays.map { $0.rawValue })
            obj.yearMonth = entity.yearMonth
            obj.yearDay = entity.yearDay?.rawValue ?? 0
            obj.importance = entity.importance.rawValue
            obj.colorName = entity.colorName
            obj.updatedAt = Date()
        }
        return obj.toDomain()
    }

    @MainActor func delete(id: String) throws {
        let realm = try Realm()
        guard let oid = try? ObjectId(string: id),
              let obj = realm.objects(RoutineObject.self)
                .filter("objectID == %@", oid).first
        else { throw RepositoryError.notFound }
        try realm.write { realm.delete(obj) }
    }
}
