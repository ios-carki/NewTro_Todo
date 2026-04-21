import Foundation

final class DIContainer {

    // MARK: - Repositories (shared singletons within container)
    private(set) lazy var todoRepository: any TodoRepositoryProtocol = TodoRepositoryImpl()
    private(set) lazy var quickNoteRepository: any QuickNoteRepositoryProtocol = QuickNoteRepositoryImpl()

    // MARK: - UseCases: Todo
    func makeFetchTodosUseCase() -> FetchTodosUseCase {
        FetchTodosUseCase(repository: todoRepository)
    }
    func makeAddTodoUseCase() -> AddTodoUseCase {
        AddTodoUseCase(repository: todoRepository)
    }
    func makeUpdateTodoTextUseCase() -> UpdateTodoTextUseCase {
        UpdateTodoTextUseCase(repository: todoRepository)
    }
    func makeToggleTodoCompleteUseCase() -> ToggleTodoCompleteUseCase {
        ToggleTodoCompleteUseCase(repository: todoRepository)
    }
    func makePostponeTodoUseCase() -> PostponeTodoUseCase {
        PostponeTodoUseCase(repository: todoRepository)
    }
    func makeUpdateTodoImportanceUseCase() -> UpdateTodoImportanceUseCase {
        UpdateTodoImportanceUseCase(repository: todoRepository)
    }
    func makeToggleTodoFavoriteUseCase() -> ToggleTodoFavoriteUseCase {
        ToggleTodoFavoriteUseCase(repository: todoRepository)
    }
    func makeDeleteTodoUseCase() -> DeleteTodoUseCase {
        DeleteTodoUseCase(repository: todoRepository)
    }

    // MARK: - UseCases: QuickNote
    func makeFetchOrCreateQuickNoteUseCase() -> FetchOrCreateQuickNoteUseCase {
        FetchOrCreateQuickNoteUseCase(repository: quickNoteRepository)
    }
    func makeUpdateQuickNoteUseCase() -> UpdateQuickNoteUseCase {
        UpdateQuickNoteUseCase(repository: quickNoteRepository)
    }

    // MARK: - ViewModels
    @MainActor func makeMainViewModel() -> MainViewModel {
        MainViewModel(
            fetchTodosUseCase: makeFetchTodosUseCase(),
            addTodoUseCase: makeAddTodoUseCase(),
            updateTodoTextUseCase: makeUpdateTodoTextUseCase(),
            toggleCompleteUseCase: makeToggleTodoCompleteUseCase(),
            postponeTodoUseCase: makePostponeTodoUseCase(),
            updateImportanceUseCase: makeUpdateTodoImportanceUseCase(),
            toggleFavoriteUseCase: makeToggleTodoFavoriteUseCase(),
            deleteTodoUseCase: makeDeleteTodoUseCase(),
            fetchOrCreateNoteUseCase: makeFetchOrCreateQuickNoteUseCase(),
            updateNoteUseCase: makeUpdateQuickNoteUseCase()
        )
    }

    // MARK: - UseCases: Settings
    func makeClearAllDataUseCase() -> ClearAllDataUseCase {
        ClearAllDataUseCase(todoRepository: todoRepository, quickNoteRepository: quickNoteRepository)
    }
}
