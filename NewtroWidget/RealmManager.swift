//
//  RealmManager.swift
//  NewTro_Todo
//
//  Created by Carki on 2023/01/13.
//

import Foundation
import RealmSwift

class RealmManager {

    private init() { }

    static let shared: RealmManager = .init()

    // 본 앱과 동일한 schemaVersion + 마이그레이션 블록 사용 → App Group 공유 Realm 파일 충돌 방지
    private var realm: Realm? {
        do {
            return try Realm(configuration: RealmConfiguration.configuration)
        } catch {
            return nil
        }
    }

    func todayTodo(date: Date) -> [Todo] {
        guard let realm else { return [] }
        let dateStr = DateFormatter.dateToString(date: date)
        return Array(
            realm.objects(Todo.self)
                .sorted(byKeyPath: "regDate", ascending: true)
                .filter { $0.stringDate == dateStr }
        )
    }
}
