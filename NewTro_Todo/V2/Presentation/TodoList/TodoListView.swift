//
//  TodoListView.swift
//  NewTro_Todo
//
//  Created by OWEN on 10/15/24.
//

import SwiftUI

struct TodoListView: View {
    weak var navigation: UINavigationController?
    @StateObject private var viewModel = TodoListViewModel()
    
    @State private var offsetY: CGFloat = CGFloat()
    @State private var headerHeight: CGFloat = CGFloat()
    @State private var initOffsetY: CGFloat? = nil
    
    var body: some View {
        GeometryReader { screenGeometry in
            ZStack {
                NewtroColor.mainBackgroundColor.ignoresSafeArea()
                
                VStack {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0.0) {
                            Color.clear
                                .frame(height: headerHeight)
                                .overlay(
                                    VStack(spacing: 0) {
                                        CustomCalendarView(selectedDate: $viewModel.selectedDate, allTodoDateData: $viewModel.allTodoDateData, pageCurrent: $viewModel.currentMonth) {
                                            //viewModel.getAllTodoData()
                                        }
                                        .background( GeometryReader { proxy in Color.clear.onAppear { headerHeight = proxy.size.height } } )
                                        .offset(y: headerHeight + screenGeometry.safeAreaInsets.top - offsetY)
                                        .frame(height: UIScreen.main.bounds.height / 2)
                                        .onAppear {
                                            print("캘린더 등장")
                                            DispatchQueue.main.async {
                                                NotificationCenter.default.post(name: NSNotification.Name("ReloadCalendar"), object: nil)
                                            }
                                        }
                                    }
                                )
                            
                            ZStack {
                                NewtroColor.mainBackgroundColor.cornerRadius(35).shadow(color: .black.opacity(0.2), radius: 15, x: 0.0, y: 0.0)
                                    .padding(.bottom, -50).ignoresSafeArea()
                                
                                VStack {
                                    //Handle
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: 48, height: 4)
                                        .background(Color(red: 0.52, green: 0.52, blue: 0.52))
                                        .cornerRadius(30)
                                    
                                    HStack {
                                        Text("\("view_selected_date_text".localized())\(viewModel.selectedDate.calendarSelectedDateFormat())")
                                            .font(.galCondensed15())
                                            .foregroundColor(.black)
                                        Spacer()
                                        Button(action: {
                                            print("view_go_today_button_text".localized())
                                            viewModel.currentMonth = Date()
                                            viewModel.selectedDate = Date()
                                            DispatchQueue.main.async {
                                                NotificationCenter.default.post(name: NSNotification.Name("goToToday"), object: nil)
                                            }
                                        }, label: {
                                            Text("view_go_today_button_text".localized())
                                                .font(.galCondensed15())
                                                .foregroundColor(.black)
                                        })
                                        .buttonStyle(BounceButton())
                                    }
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.horizontal, 16)
                                    
                                    Divider()
                                    
                                    VStack {
                                        ForEach(viewModel.todoData, id: \.id) { todo in
                                            TodoListCell(data: todo) {
                                                self.navigation?.pushViewController(UIHostingController(rootView: TodoDetailView(navigation: navigation, viewModel: TodoDetailViewModel(todo: todo))), animated: true)
                                            }
                                            .padding(.horizontal, 16)
                                        }
                                        
                                        Color.clear
                                            .frame(height: 90)
                                            .frame(maxWidth: .infinity)
                                        
                                        Spacer()
                                        
                                        Image("CalendarViewBackGround")
                                            .resizable()
                                            .frame(height: 90)
                                            .frame(maxWidth: .infinity)
                                            .padding(.horizontal, 0)
                                            .padding(.bottom, -40)
                                    }
                                }
                                .frame(maxWidth: .infinity, minHeight: screenGeometry.size.height, alignment: .bottom)
                                .padding(.top)
                            }
                            .overlay(
                                GeometryReader { proxy in
                                    Color.clear
                                        .onChange(of: proxy.frame(in: .global).minY) { newValue in
                                            offsetY = newValue
                                            self.initOffsetY = newValue
                                        }
                                }
                            )
                        }
                        
                    }
                }
            }
        }
        .onAppear {
            self.offsetY = self.initOffsetY ?? 0.0
            
            viewModel.getPickedDateTodoData()
            viewModel.reloadDateData()
        }
        .onDisappear {
            print("캘린더 Deinit 실행")
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ReloadCalendar"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("goToToday"), object: nil)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                navigationToolBar()
            }
        }
        .navigationBarItems(
            trailing: navigationTrailingItem()
        )
    }
    
    @ViewBuilder
    private func navigationTrailingItem() -> some View {
        HStack(spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "calendar.badge.clock")
//                    .resizable()
//                    .frame(width: 20, height: 20, alignment: .trailing)
                    .foregroundColor(.black)
            }
            .onTapGesture {
                let vc = UIHostingController(
                    rootView: SelectCalendarMonthView(navigation: navigation, selectedDate: viewModel.selectedDate, returnDate: { date in
                        self.navigation?.dismiss(animated: true)
                        viewModel.currentMonth = date
                    }, emptyViewClickAction: {
                        self.navigation?.dismiss(animated: true)
                    })
                )
                
                vc.view.backgroundColor = UIColor.clear
                vc.modalPresentationStyle = .overCurrentContext
                self.navigation?.present(vc, animated: true)
            }
        }
        .padding(.vertical, 10)
        .frame(height: 40, alignment: .center)
    }
    
    @ViewBuilder
    private func navigationToolBar() -> some View {
        HStack(alignment: .center, spacing: 8) {
            VStack {
                Image(systemName: "arrowtriangle.left.fill")
                    .foregroundColor(.black)
            }
            .padding(.all, 4)
            .background(Color.clear)
            .frame(width: 25, height: 25)
            .onTapGesture {
                viewModel.currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: viewModel.currentMonth)!
                print("이전날짜 ")
            }
            
            Button {
                //
            } label: {
                Text("\(viewModel.currentMonth.calendarTodayDateFormat())")
                    .font(.galCondensed18())
                    .foregroundColor(NewtroColor.white)
                    .padding(.horizontal, 4)
            }
            .disabled(true)
            
            VStack {
                Image(systemName: "arrowtriangle.right.fill")
                    .foregroundColor(.black)
            }
            .padding(.all, 4)
            .background(Color.clear)
            .frame(width: 25, height: 25)
            .onTapGesture {
                print("다음날짜 ")
                viewModel.currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: viewModel.currentMonth)!
            }
        }
        .padding(.vertical, 10)
        .frame(height: 40, alignment: .center)
    }
}

#Preview {
    TodoListView()
}
