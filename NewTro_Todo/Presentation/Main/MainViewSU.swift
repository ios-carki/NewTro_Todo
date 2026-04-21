import SwiftUI

struct MainView: View {
    @StateObject var viewModel: MainViewModel
    var onCalendarTapped: (() -> Void)?
    var onSettingsTapped: (() -> Void)?

    var body: some View {
        ZStack {
            Color(UIColor.mainBackGroundColor).ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: Top Bar
                HStack(spacing: 4) {
                    Image("Coin")
                        .resizable()
                        .frame(width: 50, height: 50)

                    Text(viewModel.formattedDate.prefix(4) + "")
                        .foregroundColor(Color(UIColor.coinCountLabelColor))
                        .font(.galBold20())

                    Spacer()

                    HStack(spacing: -20) {
                        ForEach(0..<3, id: \.self) { _ in
                            Image("Heart")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)

                // MARK: Card Area
                VStack(spacing: 0) {
                    // Date navigation
                    HStack(alignment: .center, spacing: 14) {
                        Button { viewModel.goYesterday() } label: {
                            Image("YesterDayBtn")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }

                        Text(viewModel.formattedDate)
                            .foregroundColor(.white)
                            .font(.galBold17())
                            .frame(maxWidth: .infinity)

                        Button { viewModel.goTomorrow() } label: {
                            Image("TomorrowBtn")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 12)

                    // Divider
                    Color.white
                        .frame(height: 1)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)

                    // Action buttons
                    HStack(alignment: .center, spacing: 8) {
                        Button { viewModel.addTodo() } label: {
                            Image("TodoBtn")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }

                        Button { viewModel.openQuickNote() } label: {
                            Image("NoteBtn")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                    }

                    // Todo list
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(viewModel.todos, id: \.id) { todo in
                                TodoRowView(todo: todo, viewModel: viewModel)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // Bottom image
                Image("MainBackGround")
                    .resizable()
                    .frame(height: 90)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, -40)
            }
        }
        // Navigation
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { onCalendarTapped?() } label: {
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { onSettingsTapped?() } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        // Sheets
        .sheet(isPresented: $viewModel.isQuickNotePresented) {
            QuickNoteSheetView(viewModel: viewModel)
        }
        .sheet(item: $viewModel.actionTarget) { todo in
            TodoActionMenuView(todo: todo, viewModel: viewModel)
        }
        // Error alert
        .alert("오류", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("확인") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear { viewModel.loadTodos() }
    }
}
