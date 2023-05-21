//
//  WidgetImagePreviewViewModel.swift
//  NewTro_Todo
//
//  Created by Carki on 2023/05/20.
//

import SwiftUI

final class WidgetImagePreviewViewModel: ObservableObject {
    
    //Button variable
    @Published var buttonDisabled: Bool = true
    
    //ImagePicker Variable
    @Published var image: UIImage?
    @Published var shouldPresentImagePicker = false {didSet{checkButtonEnabled()}}
    @Published var shouldPresentActionScheet = false
    @Published var shouldPresentCamera = false
    @Published var isCaptured = false
    
    func checkButtonEnabled() {
        buttonDisabled = !isCaptured
    }
}
