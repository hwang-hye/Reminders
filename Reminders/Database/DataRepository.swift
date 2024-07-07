//
//  DataRepository.swift
//  Reminders
//
//  Created by hwanghye on 7/7/24.
//

import UIKit
import RealmSwift

import UIKit
import RealmSwift

final class DataRepository {
    
    private let realm = try! Realm()
    
    func createItem(_ data: ReminderTable) {
        do {
            try realm.write {
                realm.add(data)
                print("Realm Create Succeed")
            }
        } catch {
            print("Realm Error")
            
        }
    }
    
    func fetchAll() -> [ReminderTable] {
        let value = realm.objects(ReminderTable.self).sorted(byKeyPath: "money", ascending: false)
        return Array(value)
    }
    
    func deleteItem(_ data: ReminderTable) {
        
        try! realm.write {
            realm.delete(data)
            print("Realm Delete Succeed")
        }
    }
}


