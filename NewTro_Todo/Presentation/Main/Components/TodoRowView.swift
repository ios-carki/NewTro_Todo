import SwiftUI

struct TodoRowView: View {
    let todo: TodoEntity
    @ObservedObject var viewModel: MainViewModel
    @State private var editingText: String

    init(todo: TodoEntity, viewModel: MainViewModel) {
        self.todo = todo
        self.viewModel = viewModel
        self._editingText = State(initialValue: todo.text)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .foregroundColor(.textFieldC)
            .overlay(
                HStack(alignment: .center, spacing: 4) {
                    // Complete / Postpone button
                    Image("ClearBtn")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(.horizontal, 8)
                        .contextMenu {
                            Button(todo.isCompleted ? "todoStatus_notDone".localized() : "todoStatus_Done".localized()) {
                                viewModel.toggleComplete(id: todo.id)
                            }
                            Button("다음날로 미루기") {
                                viewModel.postpone(id: todo.id)
                            }
                        }

                    if todo.isCompleted {
                        Text(todo.text)
                            .strikethrough()
                            .foregroundColor(.gray)
                            .font(.galBold16())
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        TextField("CellPlaceHolder".localized(), text: $editingText)
                            .foregroundColor(importanceColor)
                            .font(.galBold16())
                            .onSubmit { viewModel.updateText(id: todo.id, text: editingText) }
                            .onChange(of: editingText) { newValue in
                                guard newValue.count <= 50 else {
                                    editingText = String(newValue.prefix(50))
                                    return
                                }
                                viewModel.updateText(id: todo.id, text: newValue)
                            }
                    }

                    // Action menu button
                    Image(systemName: "ellipsis")
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .onTapGesture { viewModel.actionTarget = todo }
                }
            )
            .frame(height: 50)
    }

    private var importanceColor: Color {
        switch todo.importance {
        case .high:   return .blue
        case .medium: return .yellow
        case .none:   return .white
        }
    }
}
