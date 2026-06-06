import Foundation
import RealmSwift

final class TodoRepositoryImpl: TodoRepositoryProtocol {

    func fetchTodos(year: Int, month: Int) async throws -> [TodoEntity] {
        try await MainActor.run {
            let realm = try Realm()
            let calendar = Calendar.current
            guard let monthStart = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
                  let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: monthStart)
            else { return [] }
            return realm.objects(Todo.self)
                .filter("targetDate >= %@ AND targetDate < %@", monthStart, nextMonthStart)
                .toArray()
                .map { $0.toDomain() }
        }
    }

    @MainActor func fetchTodos(targetDate: Date) throws -> [TodoEntity] {
        let realm = try Realm()
        // 시간대 변경 후에도 그날 Todo 가 사라지지 않도록 정확매칭(==) 대신 [시작, 끝) 범위 조회.
        let range = targetDate.dayRange
        let entities = realm.objects(Todo.self)
            .filter("targetDate >= %@ AND targetDate < %@", range.start, range.end)
            .toArray()
            .map { $0.toDomain() }
        return entities.sorted { a, b in
            if a.isCompleted != b.isCompleted { return !a.isCompleted }
            if !a.isCompleted { return a.sortOrder < b.sortOrder }
            return (a.completedAt ?? .distantPast) < (b.completedAt ?? .distantPast)
        }
    }

    func addTodo(
        text: String,
        importance: Importance,
        targetDate: Date,
        targetTimeStart: Date?,
        targetTimeEnd: Date?,
        isAllDay: Bool,
        notifyAt: Date?,
        colorName: String
    ) async throws -> TodoEntity {
        try await MainActor.run {
            let realm = try Realm()
            let dayStart = Calendar.current.startOfDay(for: targetDate)
            let dateStr = DateFormatter.dateToString(date: dayStart)
            // 그날 최소 sortOrder 탐색도 시간대 변경 대비 범위 조회.
            let range = dayStart.dayRange
            let minSortOrder: Int = realm.objects(Todo.self)
                .filter("targetDate >= %@ AND targetDate < %@", range.start, range.end)
                .min(ofProperty: "sortOrder") ?? 1
            let todo = Todo(
                todo: text,
                favorite: false,
                importance: importance.rawValue,
                regDate: Date(),
                stringDate: dateStr,
                targetDate: dayStart,
                isFinished: false,
                targetTimeStart: targetTimeStart,
                targetTimeEnd: targetTimeEnd,
                isAllDay: isAllDay,
                notifyAt: notifyAt,
                sortOrder: minSortOrder - 1,
                colorName: colorName
            )
            try realm.write { realm.add(todo) }
            return todo.toDomain()
        }
    }

    func updateTodo(
        id: String,
        text: String,
        importance: Importance,
        targetDate: Date,
        targetTimeStart: Date?,
        targetTimeEnd: Date?,
        isAllDay: Bool,
        notifyAt: Date?,
        colorName: String
    ) async throws {
        try await MainActor.run {
            let realm = try Realm()
            guard let todo = realm.objects(Todo.self)
                .filter("objectID == %@", try ObjectId(string: id)).first
            else { throw RepositoryError.notFound }
            let dayStart = Calendar.current.startOfDay(for: targetDate)
            try realm.write {
                todo.todo = text
                todo.importance = importance.rawValue
                todo.targetDate = dayStart
                todo.stringDate = DateFormatter.dateToString(date: dayStart)
                todo.targetTimeStart = targetTimeStart
                todo.targetTimeEnd = targetTimeEnd
                todo.isAllDay = isAllDay
                todo.notifyAt = notifyAt
                todo.colorName = colorName
            }
        }
    }

    func updateText(id: String, text: String) async throws {
        try await MainActor.run {
            let realm = try Realm()
            guard let todo = realm.objects(Todo.self)
                .filter("objectID == %@", try ObjectId(string: id)).first
            else { throw RepositoryError.notFound }
            try realm.write { todo.todo = text }
        }
    }

    func toggleComplete(id: String) async throws {
        try await MainActor.run {
            let realm = try Realm()
            guard let todo = realm.objects(Todo.self)
                .filter("objectID == %@", try ObjectId(string: id)).first
            else { throw RepositoryError.notFound }
            try realm.write {
                todo.isFinished.toggle()
                todo.completedAt = todo.isFinished ? Date() : nil
            }
        }
    }

    func updateImportance(id: String, importance: Importance) async throws {
        try await MainActor.run {
            let realm = try Realm()
            guard let todo = realm.objects(Todo.self)
                .filter("objectID == %@", try ObjectId(string: id)).first
            else { throw RepositoryError.notFound }
            try realm.write { todo.importance = importance.rawValue }
        }
    }

    func toggleFavorite(id: String) async throws {
        try await MainActor.run {
            let realm = try Realm()
            guard let todo = realm.objects(Todo.self)
                .filter("objectID == %@", try ObjectId(string: id)).first
            else { throw RepositoryError.notFound }
            try realm.write { todo.favorite.toggle() }
        }
    }

    func delete(id: String) async throws {
        try await MainActor.run {
            let realm = try Realm()
            guard let todo = realm.objects(Todo.self)
                .filter("objectID == %@", try ObjectId(string: id)).first
            else { throw RepositoryError.notFound }
            try realm.write { realm.delete(todo) }
        }
    }

    func deleteAll() async throws {
        try await MainActor.run {
            let realm = try Realm()
            try realm.write {
                realm.delete(realm.objects(Todo.self))
            }
        }
    }

    func updateSortOrders(updates: [(id: String, sortOrder: Int)]) async throws {
        try await MainActor.run {
            let realm = try Realm()
            let pairs = try updates.map { (try ObjectId(string: $0.id), $0.sortOrder) }
            try realm.write {
                for (oid, order) in pairs {
                    if let todo = realm.objects(Todo.self).filter("objectID == %@", oid).first {
                        todo.sortOrder = order
                    }
                }
            }
        }
    }

    func fetchTodoCounts() async throws -> (completed: Int, total: Int) {
        try await MainActor.run {
            let realm = try Realm()
            // 오늘까지 등장한 Todo 만 카운트. 미래 routine materialize 분 제외.
            // targetDate < 내일 자정 = targetDate <= 오늘.
            let cal = Calendar.current
            let today = cal.startOfDay(for: Date())
            let tomorrow = cal.date(byAdding: .day, value: 1, to: today) ?? today
            let scope = realm.objects(Todo.self).filter("targetDate < %@", tomorrow)
            return (scope.filter("isFinished == true").count, scope.count)
        }
    }

    func fetchPastIncompleteCount() async throws -> Int {
        try await MainActor.run {
            let realm = try Realm()
            let today = Calendar.current.startOfDay(for: Date())
            // targetDate < today → 오늘 자정 미만 (= 어제까지). 오늘/미래는 제외.
            return realm.objects(Todo.self)
                .filter("targetDate < %@ AND isFinished == false", today)
                .count
        }
    }

    // MARK: - Routine support

    @MainActor func addTodoFromRoutine(
        routineId: String,
        targetDate: Date,
        text: String,
        importance: Importance,
        colorName: String
    ) throws -> TodoEntity? {
        guard let rid = try? ObjectId(string: routineId) else { return nil }
        let realm = try Realm()
        let dayStart = Calendar.current.startOfDay(for: targetDate)
        // 시간대 변경 후에도 같은 로컬일이면 중복 생성하지 않도록 정확매칭 대신 범위 조회.
        let range = dayStart.dayRange

        // (routineId, 그날) 중복이면 skip (idempotent).
        if realm.objects(Todo.self)
            .filter("routineId == %@ AND targetDate >= %@ AND targetDate < %@", rid, range.start, range.end)
            .first != nil {
            return nil
        }

        let minSortOrder: Int = realm.objects(Todo.self)
            .filter("targetDate >= %@ AND targetDate < %@", range.start, range.end)
            .min(ofProperty: "sortOrder") ?? 1
        let dateStr = DateFormatter.dateToString(date: dayStart)
        let todo = Todo(
            todo: text,
            favorite: false,
            importance: importance.rawValue,
            regDate: Date(),
            stringDate: dateStr,
            targetDate: dayStart,
            isFinished: false,
            targetTimeStart: nil,
            targetTimeEnd: nil,
            isAllDay: false,
            notifyAt: nil,
            sortOrder: minSortOrder - 1,
            completedAt: nil,
            colorName: colorName,
            routineId: rid
        )
        try realm.write { realm.add(todo) }
        return todo.toDomain()
    }

    @MainActor func addTodosFromRoutine(
        routineId: String,
        dates: [Date],
        text: String,
        importance: Importance,
        colorName: String
    ) throws -> Int {
        guard let rid = try? ObjectId(string: routineId) else { return 0 }
        guard !dates.isEmpty else { return 0 }
        let cal = Calendar.current
        let realm = try Realm()

        // 1) 입력 날짜 정규화 + 중복 제거 (같은 청크 안에서도 같은 날 두 번 들어오지 않게)
        var seen = Set<Date>()
        let normalized: [Date] = dates.compactMap { d in
            let day = cal.startOfDay(for: d)
            return seen.insert(day).inserted ? day : nil
        }
        guard !normalized.isEmpty else { return 0 }

        // 2) 이번 청크 날짜 범위에서 이미 존재하는 루틴 Todo 를 한 번에 조회 → 일(day) 단위로 버킷.
        //    시간대 변경 후엔 저장된 자정 instant 가 달라져 정확매칭(IN)이 빗나가 중복이 생기므로,
        //    [min, max+1일) 범위로 조회한 뒤 startOfDay 로 버킷해 비교한다(정상 시간대에선 동일 동작).
        guard let rangeStart = normalized.min(),
              let lastDay = normalized.max(),
              let rangeEnd = cal.date(byAdding: .day, value: 1, to: lastDay) else { return 0 }
        let existing = realm.objects(Todo.self)
            .filter("routineId == %@ AND targetDate >= %@ AND targetDate < %@", rid, rangeStart, rangeEnd)
        var existingDays = Set<Date>()
        for t in existing { existingDays.insert(cal.startOfDay(for: t.targetDate)) }

        let toInsert = normalized.filter { !existingDays.contains($0) }
        guard !toInsert.isEmpty else { return 0 }

        // 3) 청크의 모든 insert 를 단일 트랜잭션으로 묶음. 에러 발생 시 Realm 이 자동 롤백.
        try realm.write {
            for dayStart in toInsert {
                // 같은 날짜에 이미 존재하는 Todo 들의 최소 sortOrder 보다 1 작게 두어
                // 루틴 Todo 가 사용자 수동 Todo 보다 위에 노출되는 정책 유지.
                let r = dayStart.dayRange
                let minSortOrder: Int = realm.objects(Todo.self)
                    .filter("targetDate >= %@ AND targetDate < %@", r.start, r.end)
                    .min(ofProperty: "sortOrder") ?? 1
                let dateStr = DateFormatter.dateToString(date: dayStart)
                let todo = Todo(
                    todo: text,
                    favorite: false,
                    importance: importance.rawValue,
                    regDate: Date(),
                    stringDate: dateStr,
                    targetDate: dayStart,
                    isFinished: false,
                    targetTimeStart: nil,
                    targetTimeEnd: nil,
                    isAllDay: false,
                    notifyAt: nil,
                    sortOrder: minSortOrder - 1,
                    completedAt: nil,
                    colorName: colorName,
                    routineId: rid
                )
                realm.add(todo)
            }
        }
        return toInsert.count
    }

    @MainActor func deleteFutureIncompleteTodos(routineId: String, from: Date) throws {
        guard let rid = try? ObjectId(string: routineId) else { return }
        let realm = try Realm()
        let dayStart = Calendar.current.startOfDay(for: from)
        let targets = realm.objects(Todo.self)
            .filter("routineId == %@ AND targetDate >= %@ AND isFinished == false",
                    rid, dayStart)
        guard !targets.isEmpty else { return }
        try realm.write { realm.delete(targets) }
    }

}

private extension Results {
    func toArray() -> [Element] { Array(self) }
}
