//
//  File+Extension.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/24.
//

import Foundation
import UIKit

extension UIViewController {
    
//    func documentDirectoryPath() -> URL? {
//            
//            guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
//            
//            return documentDirectory
//        }
//    
//    //나중에 테이블뷰로 zip파일 리스트로 만들어줄때 사용할 것
//    func fetchDocumentZipFile() {
//        
//        do {
//            guard let path = documentDirectoryPath() else { return }
//            
//            let docs = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
//            print("docs: ", docs)
//            
//            let zip = docs.filter { $0.pathExtension == "zip"} //pathExtension = zip
//            print("zip: ", zip)
//            
//            //라스트 패스만 보여줌
//            let result = zip.map { $0.lastPathComponent}
//            //리절트를 테이블 뷰를 보여준다 했을때 반환값으로 리절트만 사용하면 됨
//            
//        } catch {
//            print("ERROR")
//        }
//    }
}
