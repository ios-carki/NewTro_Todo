import Foundation
import RealmSwift

final class RoutineObject: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var objectID: ObjectId
    @Persisted var title: String = ""

    // startDate / endDate 는 startOfDay 정규화 저장
    @Persisted var startDate: Date = Date()
    @Persisted var endDate: Date = Date()

    // "daily" | "weekly" | "biweekly" | "monthly" | "yearly"
    @Persisted var repeatKind: String = "daily"

    // weekly / biweekly: 1=일 … 7=토 (Calendar.weekday 기준)
    @Persisted var weekdays: List<Int>

    // monthly: 1~31, 32 = 마지막날
    @Persisted var monthDays: List<Int>

    // yearly: month 1~12 (0 = 미설정), day 1~31, 32 = 마지막날
    @Persisted var yearMonth: Int = 0
    @Persisted var yearDay: Int = 0

    // materialize 시 각 Todo 에 그대로 복사될 값
    @Persisted var importance: Int = 0
    @Persisted var colorName: String = "yellow"

    @Persisted var createdAt: Date = Date()
    @Persisted var updatedAt: Date = Date()
}
