import SwiftUI

struct IncompleteListView: View {
    @ObservedObject var viewModel: IncompleteListViewModel

    var body: some View {
        VStack(spacing: 0) {
            sortChips
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 4)

            if viewModel.displayedTodos.isEmpty {
                emptyState
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.displayedTodos) { todo in
                            NavigationLink(value: StatsRoute.incompleteDetail(todo)) {
                                IncompleteRow(todo: todo)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
        }
        .background(
            BackgroundSceneryView()
                .ignoresSafeArea()
        )
        .navigationTitle("미완료")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.load() }
    }

    private var sortChips: some View {
        HStack(spacing: 6) {
            ForEach(IncompleteListViewModel.SortType.allCases) { type in
                sortChip(type)
            }
            Spacer()
            Text("\(viewModel.displayedTodos.count)")
                .font(.pressStart9())
                .foregroundColor(.ink)
        }
    }

    private func sortChip(_ type: IncompleteListViewModel.SortType) -> some View {
        let isActive = viewModel.sortType == type
        return Button {
            viewModel.sortType = type
        } label: {
            Text(type.displayName)
                .font(.galBold10())
                .foregroundColor(isActive ? .cream : .ink)
                .padding(.horizontal, 10)
                .frame(height: 28)
                .background(isActive ? Color.ink : Color.cream)
                .overlay(Rectangle().stroke(Color.ink, lineWidth: 1.5))
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Text("미완료 Todo 가 없어요")
                .font(.galBold14())
                .foregroundColor(.ink)
            Text("모두 완료했어요!")
                .font(.galBold11())
                .foregroundColor(.shade)
        }
        .padding(24)
    }
}

private struct IncompleteRow: View {
    let todo: TodoEntity

    var body: some View {
        HStack(spacing: 10) {
            ImportancePip(importance: todo.importance)

            VStack(alignment: .leading, spacing: 4) {
                Text(todo.text)
                    .font(.galBold14())
                    .foregroundColor(.ink)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(dateLabel)
                    .font(.pressStart8())
                    .foregroundColor(.shade)
            }

            Spacer(minLength: 0)

            Text("▶")
                .font(.pressStart8())
                .foregroundColor(.shade)
        }
        .padding(12)
        .background(Color.panel)
        .overlay(Rectangle().stroke(Color.ink, lineWidth: 2))
        .background(Rectangle().fill(Color.ink).offset(x: 2, y: 2))
    }

    private var dateLabel: String {
        let cal = Calendar.current
        let y = cal.component(.year, from: todo.targetDate)
        let m = cal.component(.month, from: todo.targetDate)
        let d = cal.component(.day, from: todo.targetDate)
        return String(format: "%04d.%02d.%02d", y, m, d)
    }
}

struct ImportancePip: View {
    let importance: Importance

    private var color: Color {
        switch importance {
        case .none:   return .shade.opacity(0.5)
        case .medium: return .sun
        case .high:   return .pixelRed
        }
    }

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 10, height: 10)
            .overlay(Rectangle().stroke(Color.ink, lineWidth: 1))
    }
}
