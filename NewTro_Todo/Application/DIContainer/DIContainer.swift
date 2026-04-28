import Foundation

final class DIContainer {

    // MARK: - Repositories
    private(set) lazy var todoRepository: any TodoRepositoryProtocol = TodoRepositoryImpl()
    private(set) lazy var memoRepository: any MemoRepositoryProtocol = MemoRepositoryImpl()
    private(set) lazy var statsRepository: any StatsRepositoryProtocol = StatsRepositoryImpl()
    private(set) lazy var templateRepository: any TemplateRepositoryProtocol = TemplateRepositoryImpl()

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
    func makeEditTodoUseCase() -> EditTodoUseCase {
        EditTodoUseCase(repository: todoRepository)
    }
    func makeFetchTodosByMonthUseCase() -> FetchTodosByMonthUseCase {
        FetchTodosByMonthUseCase(repository: todoRepository)
    }

    // MARK: - UseCases: Memo
    func makeFetchMemosUseCase() -> FetchMemosUseCase {
        FetchMemosUseCase(repository: memoRepository)
    }
    func makeAddMemoUseCase() -> AddMemoUseCase {
        AddMemoUseCase(repository: memoRepository)
    }
    func makeUpdateMemoUseCase() -> UpdateMemoUseCase {
        UpdateMemoUseCase(repository: memoRepository)
    }
    func makeDeleteMemoUseCase() -> DeleteMemoUseCase {
        DeleteMemoUseCase(repository: memoRepository)
    }

    // MARK: - UseCases: Stats
    func makeFetchStatsUseCase() -> FetchStatsUseCase {
        FetchStatsUseCase(repository: statsRepository)
    }
    func makeRecordTodoCompleteUseCase() -> RecordTodoCompleteUseCase {
        RecordTodoCompleteUseCase(repository: statsRepository)
    }
    func makeFetchWeeklyCompletionsUseCase() -> FetchWeeklyCompletionsUseCase {
        FetchWeeklyCompletionsUseCase(repository: todoRepository)
    }
    func makeClaimChallengeUseCase() -> ClaimChallengeUseCase {
        ClaimChallengeUseCase(repository: statsRepository)
    }
    func makeRecordTodoAddedUseCase() -> RecordTodoAddedUseCase {
        RecordTodoAddedUseCase(repository: statsRepository)
    }
    func makeRecordPostponeUseCase() -> RecordPostponeUseCase {
        RecordPostponeUseCase(repository: statsRepository)
    }

    // MARK: - UseCases: Template
    func makeFetchTemplatesUseCase() -> FetchTemplatesUseCase {
        FetchTemplatesUseCase(repository: templateRepository)
    }
    func makeAddTemplateUseCase() -> AddTemplateUseCase {
        AddTemplateUseCase(repository: templateRepository)
    }
    func makeUpdateTemplateUseCase() -> UpdateTemplateUseCase {
        UpdateTemplateUseCase(repository: templateRepository)
    }
    func makeDeleteTemplateUseCase() -> DeleteTemplateUseCase {
        DeleteTemplateUseCase(repository: templateRepository)
    }

    // MARK: - UseCases: Settings
    func makeClearAllDataUseCase() -> ClearAllDataUseCase {
        ClearAllDataUseCase(
            todoRepository: todoRepository,
            memoRepository: memoRepository,
            statsRepository: statsRepository
        )
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
            recordCompleteUseCase: makeRecordTodoCompleteUseCase(),
            recordTodoAddedUseCase: makeRecordTodoAddedUseCase(),
            recordPostponeUseCase: makeRecordPostponeUseCase(),
            editTodoUseCase: makeEditTodoUseCase(),
            fetchTemplatesUseCase: makeFetchTemplatesUseCase(),
            addTemplateUseCase: makeAddTemplateUseCase(),
            updateTemplateUseCase: makeUpdateTemplateUseCase(),
            deleteTemplateUseCase: makeDeleteTemplateUseCase()
        )
    }

    @MainActor func makeCalendarViewModel() -> CalendarViewModel {
        CalendarViewModel(fetchByMonthUseCase: makeFetchTodosByMonthUseCase())
    }

    @MainActor func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(clearAllDataUseCase: makeClearAllDataUseCase())
    }

    @MainActor func makeMemoViewModel() -> MemoViewModel {
        MemoViewModel(
            fetchUseCase: makeFetchMemosUseCase(),
            addUseCase: makeAddMemoUseCase(),
            updateUseCase: makeUpdateMemoUseCase(),
            deleteUseCase: makeDeleteMemoUseCase()
        )
    }

    @MainActor func makeStatsViewModel() -> StatsViewModel {
        StatsViewModel(
            fetchStatsUseCase: makeFetchStatsUseCase(),
            fetchWeeklyUseCase: makeFetchWeeklyCompletionsUseCase(),
            claimChallengeUseCase: makeClaimChallengeUseCase()
        )
    }
}
