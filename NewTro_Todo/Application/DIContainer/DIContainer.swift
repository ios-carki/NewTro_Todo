import Foundation

final class DIContainer {

    // MARK: - Repositories
    private(set) lazy var todoRepository: any TodoRepositoryProtocol = TodoRepositoryImpl()
    private(set) lazy var memoRepository: any MemoRepositoryProtocol = MemoRepositoryImpl()
    private(set) lazy var statsRepository: any StatsRepositoryProtocol = StatsRepositoryImpl()
    private(set) lazy var templateRepository: any TemplateRepositoryProtocol = TemplateRepositoryImpl()
    private(set) lazy var walletRepository: any WalletRepositoryProtocol = WalletRepositoryImpl()
    private(set) lazy var localNotificationRepository: any LocalNotificationRepositoryProtocol = LocalNotificationRepositoryImpl()
    private(set) lazy var backupLogRepository: any BackupLogRepositoryProtocol = BackupLogRepositoryImpl()
    private(set) lazy var backupRepository: any BackupRepositoryProtocol = BackupRepositoryImpl(
        statsRepository: statsRepository,
        backupLogRepository: backupLogRepository
    )

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
    func makeUpdateTodoSortOrdersUseCase() -> UpdateTodoSortOrdersUseCase {
        UpdateTodoSortOrdersUseCase(repository: todoRepository)
    }
    func makeFetchMonthOverviewUseCase() -> FetchMonthOverviewUseCase {
        FetchMonthOverviewUseCase(todoRepository: todoRepository, memoRepository: memoRepository)
    }
    func makeFetchTodoCountsUseCase() -> FetchTodoCountsUseCase {
        FetchTodoCountsUseCase(repository: todoRepository)
    }
    func makeFetchIncompleteTodosUseCase() -> FetchIncompleteTodosUseCase {
        FetchIncompleteTodosUseCase(repository: todoRepository)
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
    func makeFetchWeeklyTodoCountsUseCase() -> FetchWeeklyTodoCountsUseCase {
        FetchWeeklyTodoCountsUseCase(repository: todoRepository)
    }
    func makeRecordTodoAddedUseCase() -> RecordTodoAddedUseCase {
        RecordTodoAddedUseCase(repository: statsRepository)
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

    // MARK: - UseCases: Wallet
    func makeEarnCoinsUseCase() -> EarnCoinsUseCase {
        EarnCoinsUseCase(repository: walletRepository)
    }
    func makeFetchWalletUseCase() -> FetchWalletUseCase {
        FetchWalletUseCase(repository: walletRepository)
    }

    // MARK: - UseCases: Settings
    func makeClearAllDataUseCase() -> ClearAllDataUseCase {
        ClearAllDataUseCase(
            todoRepository: todoRepository,
            memoRepository: memoRepository,
            statsRepository: statsRepository
        )
    }

    // MARK: - UseCases: Notification
    func makeCheckNotificationPermissionUseCase() -> CheckNotificationPermissionUseCase {
        CheckNotificationPermissionUseCase(repository: localNotificationRepository)
    }
    func makeRequestNotificationPermissionUseCase() -> RequestNotificationPermissionUseCase {
        RequestNotificationPermissionUseCase(repository: localNotificationRepository)
    }
    func makeApplyDailyNotificationsUseCase() -> ApplyDailyNotificationsUseCase {
        ApplyDailyNotificationsUseCase(repository: localNotificationRepository)
    }

    // MARK: - UseCases: Backup
    func makeCreateBackupUseCase() -> CreateBackupUseCase {
        CreateBackupUseCase(repository: backupRepository)
    }
    func makeRestoreBackupUseCase() -> RestoreBackupUseCase {
        RestoreBackupUseCase(repository: backupRepository)
    }
    func makePeekBackupHeaderUseCase() -> PeekBackupHeaderUseCase {
        PeekBackupHeaderUseCase(repository: backupRepository)
    }
    func makeRecordBackupLogUseCase() -> RecordBackupLogUseCase {
        RecordBackupLogUseCase(repository: backupLogRepository)
    }
    func makeFetchBackupLogsUseCase() -> FetchBackupLogsUseCase {
        FetchBackupLogsUseCase(repository: backupLogRepository)
    }
    func makeClearBackupLogsUseCase() -> ClearBackupLogsUseCase {
        ClearBackupLogsUseCase(repository: backupLogRepository)
    }

    // MARK: - ViewModels
    @MainActor func makeMainViewModel() -> MainViewModel {
        MainViewModel(
            fetchTodosUseCase: makeFetchTodosUseCase(),
            fetchMemosUseCase: makeFetchMemosUseCase(),
            fetchMonthOverviewUseCase: makeFetchMonthOverviewUseCase(),
            addTodoUseCase: makeAddTodoUseCase(),
            updateTodoTextUseCase: makeUpdateTodoTextUseCase(),
            toggleCompleteUseCase: makeToggleTodoCompleteUseCase(),
            updateImportanceUseCase: makeUpdateTodoImportanceUseCase(),
            toggleFavoriteUseCase: makeToggleTodoFavoriteUseCase(),
            deleteTodoUseCase: makeDeleteTodoUseCase(),
            recordCompleteUseCase: makeRecordTodoCompleteUseCase(),
            recordTodoAddedUseCase: makeRecordTodoAddedUseCase(),
            editTodoUseCase: makeEditTodoUseCase(),
            updateTodoSortOrdersUseCase: makeUpdateTodoSortOrdersUseCase(),
            fetchTemplatesUseCase: makeFetchTemplatesUseCase(),
            addTemplateUseCase: makeAddTemplateUseCase(),
            updateTemplateUseCase: makeUpdateTemplateUseCase(),
            deleteTemplateUseCase: makeDeleteTemplateUseCase(),
            earnCoinsUseCase: makeEarnCoinsUseCase(),
            fetchWalletUseCase: makeFetchWalletUseCase()
        )
    }

    @MainActor func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            clearAllDataUseCase: makeClearAllDataUseCase(),
            checkNotificationPermissionUseCase: makeCheckNotificationPermissionUseCase(),
            requestNotificationPermissionUseCase: makeRequestNotificationPermissionUseCase(),
            applyDailyNotificationsUseCase: makeApplyDailyNotificationsUseCase(),
            createBackupUseCase: makeCreateBackupUseCase(),
            restoreBackupUseCase: makeRestoreBackupUseCase(),
            peekBackupHeaderUseCase: makePeekBackupHeaderUseCase(),
            recordBackupLogUseCase: makeRecordBackupLogUseCase()
        )
    }

    @MainActor func makeBackupLogViewModel() -> BackupLogViewModel {
        BackupLogViewModel(
            fetchBackupLogsUseCase: makeFetchBackupLogsUseCase(),
            clearBackupLogsUseCase: makeClearBackupLogsUseCase()
        )
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
            fetchWeeklyUseCase: makeFetchWeeklyTodoCountsUseCase(),
            fetchTodoCountsUseCase: makeFetchTodoCountsUseCase()
        )
    }

    @MainActor func makeIncompleteListViewModel() -> IncompleteListViewModel {
        IncompleteListViewModel(
            fetchUseCase: makeFetchIncompleteTodosUseCase()
        )
    }
}
