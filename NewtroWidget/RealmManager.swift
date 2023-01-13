//
//  RealmManager.swift
//  NewTro_Todo
//
//  Created by Carki on 2023/01/13.
//

import UIKit
import RealmSwift

class RealmManager {
    
    private init() { }
    
    static let shared: RealmManager = .init()
    
    private var realm: Realm {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.carki.NewTro_Todo")
        let realmURL = container?.appendingPathComponent("default.realm")
        let config = Realm.Configuration(fileURL: realmURL, schemaVersion: 1)
        return try! Realm(configuration: config)
    }
    
    func todayTodo(date: Date) -> [Todo] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        let converDate = dateFormatter.string(from: Date())
        print("convertDate = \(converDate)")

        let dateStr = DateFormatter.dateToString(date: date)
        return Array(realm.objects(Todo.self).sorted(byKeyPath: "regDate", ascending: true).filter {
            $0.stringDate == dateStr
        })

    }
}
