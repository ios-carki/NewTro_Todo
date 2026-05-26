import Foundation
import Combine
import WidgetKit

@MainActor
final class RoutineViewModel: ObservableObject {

    // MARK: - State
    @Published var routines: [RoutineEntity] = []
    @Published var isCreatePresented: Bool = false
    @Published var isFormPresented: Bool = false
    @Published var editingRoutine: RoutineEntity? = nil
    @Published var errorMessage: String? = nil

    // MARK: - UseCases
    private let fetchUseCase: any FetchRoutinesUseCaseProtocol
    private let addUseCase: any AddRoutineUseCaseProtocol
    private let updateUseCase: any UpdateRoutineUseCaseProtocol
    private let deleteUseCase: any DeleteRoutineUseCaseProtocol
    private let materializeUseCase: any MaterializeRoutinesUseCaseProtocol

    init(
        fetchUseCase: any FetchRoutinesUseCaseProtocol,
        addUseCase: any AddRoutineUseCaseProtocol,
        updateUseCase: any UpdateRoutineUseCaseProtocol,
        deleteUseCase: any DeleteRoutineUseCaseProtocol,
        materializeUseCase: any MaterializeRoutinesUseCaseProtocol
    ) {
        self.fetchUseCase = fetchUseCase
        self.addUseCase = addUseCase
        self.updateUseCase = updateUseCase
        self.deleteUseCase = deleteUseCase
        self.materializeUseCase = materializeUseCase
    }

    // MARK: - Actions

    func loadRoutines() {
        do {
            routines = try fetchUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func presentCreate() {
        editingRoutine = nil
        isCreatePresented = true
    }

    func openRoutine(_ routine: RoutineEntity) {
        editingRoutine = routine
        isFormPresented = true
    }

    func dismissForm() {
        isCreatePresented = false
        isFormPresented = false
        editingRoutine = nil
    }

    func saveCreated(_ entity: RoutineEntity) {
        do {
            _ = try addUseCase.execute(entity)
            try materializeUseCase.execute()
            loadRoutines()
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            errorMessage = error.localizedDescription
        }
        dismissForm()
    }

    func saveEdited(_ entity: RoutineEntity) {
        do {
            _ = try updateUseCase.execute(entity)
            try materializeUseCase.execute()
            loadRoutines()
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            errorMessage = error.localizedDescription
        }
        dismissForm()
    }

    func delete(id: String) {
        do {
            try deleteUseCase.execute(id: id)
            loadRoutines()
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            errorMessage = error.localizedDescription
        }
        dismissForm()
    }
}
