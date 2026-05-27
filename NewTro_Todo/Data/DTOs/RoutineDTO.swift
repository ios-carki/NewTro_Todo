import Foundation
import RealmSwift

extension RoutineObject {
    func toDomain() -> RoutineEntity {
        let kind = RoutineRepeatKind(rawValue: repeatKind) ?? .daily
        let mDays: [RoutineDay] = monthDays.compactMap { RoutineDay(rawValue: $0) }
        let yDay: RoutineDay? = yearDay > 0 ? RoutineDay(rawValue: yearDay) : nil
        let imp = Importance(rawValue: importance) ?? .none

        return RoutineEntity(
            id: objectID.stringValue,
            title: title,
            startDate: startDate,
            endDate: endDate,
            repeatKind: kind,
            weekdays: Array(weekdays),
            monthDays: mDays,
            yearMonth: yearMonth,
            yearDay: yDay,
            importance: imp,
            colorName: colorName,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

extension RoutineEntity {
    func toRealmObject() -> RoutineObject {
        let obj = RoutineObject()
        if let oid = try? ObjectId(string: id) {
            obj.objectID = oid
        }
        obj.title = title
        obj.startDate = Calendar.current.startOfDay(for: startDate)
        obj.endDate = Calendar.current.startOfDay(for: endDate)
        obj.repeatKind = repeatKind.rawValue
        obj.weekdays.append(objectsIn: weekdays)
        obj.monthDays.append(objectsIn: monthDays.map { $0.rawValue })
        obj.yearMonth = yearMonth
        obj.yearDay = yearDay?.rawValue ?? 0
        obj.importance = importance.rawValue
        obj.colorName = colorName
        obj.createdAt = createdAt
        obj.updatedAt = updatedAt
        return obj
    }
}
