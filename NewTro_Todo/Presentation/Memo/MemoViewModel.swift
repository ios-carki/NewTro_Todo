import Foundation
import Combine

@MainActor
final class MemoViewModel: ObservableObject {

    // MARK: - State
    @Published var memos: [MemoEntity] = []
    @Published var filterType: MemoFilter = .all
    @Published var sortType: MemoSortType = .newest
    @Published var isFormPresented: Bool = false
    @Published var isCreatePresented: Bool = false
    @Published var editingMemo: MemoEntity? = nil
    @Published var isRangePickerPresented: Bool = false
    @Published var rangeFrom: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @Published var rangeTo: Date = Date()
    @Published var errorMessage: String? = nil

    // MARK: - UseCases
    private let fetchUseCase: any FetchMemosUseCaseProtocol
    private let addUseCase: any AddMemoUseCaseProtocol
    private let updateUseCase: any UpdateMemoUseCaseProtocol
    private let deleteUseCase: any DeleteMemoUseCaseProtocol

    init(
        fetchUseCase: any FetchMemosUseCaseProtocol,
        addUseCase: any AddMemoUseCaseProtocol,
        updateUseCase: any UpdateMemoUseCaseProtocol,
        deleteUseCase: any DeleteMemoUseCaseProtocol
    ) {
        self.fetchUseCase = fetchUseCase
        self.addUseCase = addUseCase
        self.updateUseCase = updateUseCase
        self.deleteUseCase = deleteUseCase
    }

    // MARK: - Computed
    var displayedMemos: [MemoEntity] {
        switch sortType {
        case .newest: return memos.sorted { $0.createdAt > $1.createdAt }
        case .oldest: return memos.sorted { $0.createdAt < $1.createdAt }
        case .color:  return memos.sorted { $0.colorName < $1.colorName }
        }
    }

    var isRangeFilterActive: Bool {
        if case .range = filterType { return true }
        return false
    }

    // MARK: - Actions
    func loadMemos() {
        Task {
            do {
                memos = try await fetchUseCase.execute(filter: filterType)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func selectFilter(_ filter: MemoFilter) {
        if case .range = filter {
            isRangePickerPresented = true
        } else {
            filterType = filter
            loadMemos()
        }
    }

    func applyRangeFilter() {
        filterType = .range(from: rangeFrom, to: rangeTo)
        isRangePickerPresented = false
        loadMemos()
    }

    func presentCreate() {
        isCreatePresented = true
    }

    func createMemo(note: String, colorName: String) {
        Task {
            do {
                let memo = try await addUseCase.execute(colorName: colorName)
                try await updateUseCase.execute(id: memo.id, note: note, colorName: colorName)
                var saved = memo
                saved.note = note
                saved.colorName = colorName
                saved.isWritten = !note.isEmpty
                memos.insert(saved, at: 0)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func addMemo(colorName: String = "yellow") {
        Task {
            do {
                let memo = try await addUseCase.execute(colorName: colorName)
                memos.insert(memo, at: 0)
                editingMemo = memo
                isFormPresented = true
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func openMemo(_ memo: MemoEntity) {
        editingMemo = memo
        isFormPresented = true
    }

    func saveMemo(id: String, note: String, colorName: String) {
        Task {
            do {
                try await updateUseCase.execute(id: id, note: note, colorName: colorName)
                if let idx = memos.firstIndex(where: { $0.id == id }) {
                    memos[idx].note = note
                    memos[idx].colorName = colorName
                    memos[idx].isWritten = !note.isEmpty
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func deleteMemo(id: String) {
        Task {
            do {
                try await deleteUseCase.execute(id: id)
                memos.removeAll { $0.id == id }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Sort Type
enum MemoSortType: String, CaseIterable {
    case newest = "최신순"
    case oldest = "오래된 순"
    case color  = "색상순"
}

// MARK: - Filter label (presentation extension)
extension MemoFilter {
    var label: String {
        switch self {
        case .all:          return "전체"
        case .today:        return "오늘"
        case .days(7):      return "7일"
        case .days(30):     return "30일"
        case .days(let n):  return "\(n)일"
        case .range:        return "기간"
        }
    }
}
