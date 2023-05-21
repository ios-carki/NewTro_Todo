//
//  WidgetImagePreviewView.swift
//  NewTro_Todo
//
//  Created by Carki on 2023/05/20.
//

import SwiftUI
import WidgetKit

struct WidgetImagePreviewView: View {
    
    weak var navigation: UINavigationController?
    @StateObject private var viewModel = WidgetImagePreviewViewModel()
    
    var body: some View {
        ZStack {
            Color(UIColor.mainBackGroundColor).ignoresSafeArea()
            
            VStack {
                HStack {
                    Text("위젯 미리보기")
                }
                
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        Color(UIColor.white).opacity(0.2),
                        lineWidth: 4
                    )
                    .foregroundColor(Color.white.opacity(0.2))
                    .overlay(
                        Image(uiImage: viewModel.image ?? UIImage()).resizable()
                            .aspectRatio(1.0, contentMode: .fill)
                            .frame(width: 290, height: 290)
                            .foregroundColor(.gray.opacity(0.2))
                            .cornerRadius((viewModel.isCaptured) ? 12 : 0)
                    )
                    .frame(width: 290, height: 290)
                    .onTapGesture {
                        viewModel.shouldPresentActionScheet = true
                    }
                    .sheet(isPresented: $viewModel.shouldPresentImagePicker) {
                        CustomImagePicker(sourceType: viewModel.shouldPresentCamera ? .camera : .photoLibrary, image: $viewModel.image, isPresented: $viewModel.shouldPresentImagePicker, isCaptured: $viewModel.isCaptured)
                    }.actionSheet(isPresented: $viewModel.shouldPresentActionScheet) { () -> ActionSheet in
                        ActionSheet(title: Text("Choose mode"), message: Text("Please choose your preferred mode to set your profile image"), buttons: [ActionSheet.Button.default(Text("Camera"), action: {
                            viewModel.shouldPresentImagePicker = true
                            viewModel.shouldPresentCamera = true
                        }), ActionSheet.Button.default(Text("Photo Library"), action: {
                            viewModel.shouldPresentImagePicker = true
                            viewModel.shouldPresentCamera = false
                        }), ActionSheet.Button.cancel()])
                    }
                
                //MARK: 로컬라이징
                CustomButton()
                    .setType(type: .normal)
                    .setTitle(title: "적용하기")
                    .onTapGesture {
                        print(viewModel.image!)
                        saveImage(image: viewModel.image ?? UIImage())
                        WidgetCenter.shared.reloadAllTimelines()
                    }
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle("위젯 배경화면 설정")
    }
    
    //MARK: 위젯 이미지 저장
    func saveImage(image: UIImage) {
        let data = image.jpegData(compressionQuality: 0.5)
        let encoded = try! PropertyListEncoder().encode(data)
        UserDefaults.standard.set(encoded, forKey: "KEY")
    }
    
//    func loadImage() -> UIImage? {
//         guard let data = UserDefaults.standard.data(forKey: "KEY") else { return UIImage(systemName: "x.square")}
//         let decoded = try! PropertyListDecoder().decode(Data.self, from: data)
//         let image = UIImage(data: decoded)
//
//        return image
//    }
}

struct WidgetImagePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetImagePreviewView()
    }
}
