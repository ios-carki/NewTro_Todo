import Foundation

protocol DeleteRoutineUseCaseProtocol {
    @MainActor func execute(id: String) throws
}

// 1) 해당 루틴이 만든 미래 미완료 Todo 일괄 제거
// 2) 루틴 자체 제거
// 과거/완료된 Todo 는 기록으로 그대로 유지된다.
final class DeleteRoutineUseCase: DeleteRoutineUseCaseProtocol {
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
    func execute(id: String) throws {
        let today = Calendar.current.startOfDay(for: Date())
        try todoRepo.deleteFutureIncompleteTodos(routineId: id, from: today)
        try routineRepo.delete(id: id)
    }
}
