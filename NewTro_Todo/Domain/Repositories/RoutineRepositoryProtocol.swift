import Foundation

protocol RoutineRepositoryProtocol {
    @MainActor func fetchAll() throws -> [RoutineEntity]
    @MainActor func fetch(id: String) throws -> RoutineEntity?
    @MainActor func add(_ entity: RoutineEntity) throws -> RoutineEntity
    @MainActor func update(_ entity: RoutineEntity) throws -> RoutineEntity
    @MainActor func delete(id: String) throws
}
