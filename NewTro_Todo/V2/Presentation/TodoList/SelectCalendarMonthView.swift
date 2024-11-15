//
//  SelectCalendarMonthView.swift
//  NewTro_Todo
//
//  Created by OWEN on 11/14/24.
//

import SwiftUI

struct SelectCalendarMonthView: View {
    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]
    
    weak var navigation: UINavigationController?
    @StateObject private var viewModel = SelectCalendarMonthViewModel()
    
    @State var selectedDate: Date
    
    var returnDate: (Date) -> ()
    var emptyViewClickAction: () -> ()
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
                .onTapGesture {
                    emptyViewClickAction()
                }
            
            VStack(spacing: 12) {
                Spacer()
                
                HStack {
                    Image(systemName: "xmark")
                        .foregroundColor(NewtroColor.myBlack)
                        .scaledToFit()
                        .padding(.all, 6)
                        .frame(width: 30, height: 30)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 10)
                .onTapGesture {
                    emptyViewClickAction()
                }
                
                
                RoundedRectangle(cornerRadius: 24)
                    .ignoresSafeArea()
                    .frame(height: 250)
                    .foregroundColor(NewtroColor.mainBackgroundColor)
                    .overlay(
                        VStack(spacing: 24) {
                            HStack {
                                VStack {
                                    Image(systemName: "chevron.left")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(NewtroColor.myWhite)
                                }
                                .padding(.all, 4)
                                .frame(width: 25, height: 25)
                                .onTapGesture {
                                    self.selectedDate = viewModel.limitPastYear(self.selectedDate)
                                }
                                
                                Text(selectedDate.remainOnlyYearString())
                                    .font(.galCondensed18())
                                    .foregroundColor(NewtroColor.white)
                                
                                VStack {
                                    Image(systemName: "chevron.right")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(NewtroColor.myWhite)
                                }
                                .padding(.all, 4)
                                .frame(width: 25, height: 25)
                                .onTapGesture {
                                    self.selectedDate = viewModel.limitFutureYear(self.selectedDate)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(viewModel.monthData, id: \.self) { month in
                                    Button(action: {
                                        returnDate(viewModel.selectYearWithMonth(month: month, self.selectedDate))
                                    }, label: {
                                        Text(month)
                                            .font(.galCondensed18())
                                            .foregroundColor(NewtroColor.white)
                                            .frame(width: 60, height: 33)
                                    })
                                    .buttonStyle(BounceButton(labelColor: NewtroColor.myBlack, backgroundColor: NewtroColor.mainBackgroundColor))
                                }
                            }
                        }
                    )
            }
        }
    }
}

#Preview {
    SelectCalendarMonthView(selectedDate: Date()) { selectedDate in
        
    } emptyViewClickAction: {
        
    }

}
