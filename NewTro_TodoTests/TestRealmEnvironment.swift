import Foundation
import RealmSwift
import XCTest
@testable import NewTro_Todo

/// 테스트 케이스마다 격리된 in-memory Realm 을 깐다.
/// - default Realm.Configuration 을 in-memory 로 덮어써, Repository 구현이 `try Realm()` 만으로도
///   이 격리된 인스턴스를 잡는다 (별도 코드 분기 불필요).
/// - inMemoryIdentifier 는 UUID 라 케이스 간 데이터 공유 없음 → 병렬/순차 테스트 모두 안전.
class RealmTestCase: XCTestCase {
    /// 테스트 안에서 직접 Realm 조회가 필요할 때 사용.
    @MainActor var realm: Realm!

    override func setUp() async throws {
        try await super.setUp()
        await MainActor.run {
            let id = UUID().uuidString
            Realm.Configuration.defaultConfiguration = Realm.Configuration(
                inMemoryIdentifier: id,
                deleteRealmIfMigrationNeeded: true
            )
            // swiftlint:disable:next force_try
            self.realm = try! Realm()
        }
    }

    override func tearDown() async throws {
        await MainActor.run {
            // in-memory 는 마지막 참조가 사라지면 자동 폐기. 명시적으로 dump.
            try? realm.write { realm.deleteAll() }
            realm = nil
        }
        try await super.tearDown()
    }
}

// MARK: - Fixture factories

enum RoutineFixture {
    /// 단순 daily 루틴. start/end 둘 다 startOfDay 로 들어옴 (Impl 이 정규화).
    static func daily(
        title: String = "Daily routine",
        start: Date,
        end: Date,
        importance: Importance = .none,
        colorName: String = "yellow"
    ) -> RoutineEntity {
        RoutineEntity(
            id: "",
            title: title,
            startDate: start,
            endDate: end,
            repeatKind: .daily,
            weekdays: [],
            monthDays: [],
            yearMonth: 0,
            yearDay: nil,
            importance: importance,
            colorName: colorName,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    static func weekly(
        weekdays: [Int],
        start: Date,
        end: Date,
        title: String = "Weekly routine"
    ) -> RoutineEntity {
        RoutineEntity(
            id: "",
            title: title,
            startDate: start,
            endDate: end,
            repeatKind: .weekly,
            weekdays: weekdays,
            monthDays: [],
            yearMonth: 0,
            yearDay: nil,
            importance: .none,
            colorName: "yellow",
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    static func biweekly(
        weekdays: [Int],
        start: Date,
        end: Date,
        title: String = "Biweekly routine"
    ) -> RoutineEntity {
        RoutineEntity(
            id: "",
            title: title,
            startDate: start,
            endDate: end,
            repeatKind: .biweekly,
            weekdays: weekdays,
            monthDays: [],
            yearMonth: 0,
            yearDay: nil,
            importance: .none,
            colorName: "yellow",
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    static func monthly(
        monthDays: [RoutineDay],
        start: Date,
        end: Date,
        title: String = "Monthly routine"
    ) -> RoutineEntity {
        RoutineEntity(
            id: "",
            title: title,
            startDate: start,
            endDate: end,
            repeatKind: .monthly,
            weekdays: [],
            monthDays: monthDays,
            yearMonth: 0,
            yearDay: nil,
            importance: .none,
            colorName: "yellow",
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    static func yearly(
        month: Int,
        day: RoutineDay,
        start: Date,
        end: Date,
        title: String = "Yearly routine"
    ) -> RoutineEntity {
        RoutineEntity(
            id: "",
            title: title,
            startDate: start,
            endDate: end,
            repeatKind: .yearly,
            weekdays: [],
            monthDays: [],
            yearMonth: month,
            yearDay: day,
            importance: .none,
            colorName: "yellow",
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

// MARK: - Date helpers

enum TestDate {
    static let cal = Calendar.current

    static func ymd(_ y: Int, _ m: Int, _ d: Int) -> Date {
        // swiftlint:disable:next force_unwrapping
        cal.date(from: DateComponents(year: y, month: m, day: d))!
    }

    /// `Calendar.weekday`: 1=일 … 7=토.
    static func weekday(_ date: Date) -> Int {
        cal.component(.weekday, from: date)
    }

    static func plus(days: Int, to date: Date) -> Date {
        // swiftlint:disable:next force_unwrapping
        cal.date(byAdding: .day, value: days, to: date)!
    }
}
