import Foundation

protocol UpdateRoutineUseCaseProtocol {
    @MainActor func execute(_ entity: RoutineEntity) throws -> RoutineEntity
}

// 미래 미완료 루틴 Todo 를 일괄 제거한 뒤 루틴 자체를 갱신한다.
// 이후 호출자가 MaterializeRoutinesUseCase 를 통해 새 조건으로 재생성한다.
final class UpdateRoutineUseCase: UpdateRoutineUseCaseProtocol {
    private let routineRepo: RoutineRepositoryProtocol
    private let todoRepo: TodoRepositoryProtocol

    init(
        routineRepo: RoutineRepositoryProtocol,
        todoRepo: TodoRepositoryProtocol
    ) {
        self.routineRepo = routineRepo
        self.todoRepo = todoRepo
    }

    @MainActor
    func execute(_ entity: RoutineEntity) throws -> RoutineEntity {
        let today = Calendar.current.startOfDay(for: Date())
        try todoRepo.deleteFutureIncompleteTodos(routineId: entity.id, from: today)
        return try routineRepo.update(entity)
    }
}
