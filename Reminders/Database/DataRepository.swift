//
//  DataRepository.swift
//  Reminders
//
//  Created by hwanghye on 7/7/24.
//

import UIKit
import RealmSwift

final class DataRepository {
    
    private let realm = try! Realm()
    
    func detectRealmURL() {
        print(realm.configuration.fileURL ?? "")
    }
    
    func fetchFolder() -> [Folder] {
        let value = realm.objects(Folder.self)
        return Array(value)
    }
    
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
    
    func fetchTodayCount() -> Int {
        let today = Date()
        let startOfDay = Calendar.current.startOfDay(for: today)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        return realm.objects(ReminderTable.self).filter("date >= %@ AND date < %@", startOfDay, endOfDay).count
    }
    
    func fetchUpcomingCount() -> Int {
        let today = Date()
        return realm.objects(ReminderTable.self).filter("date > %@", today).count
    }
    
    func fetchAllCount() -> Int {
        return realm.objects(ReminderTable.self).count
    }
    
    func fetchFlaggedCount() -> Int {
        return realm.objects(ReminderTable.self).filter("tag == %@", "flagged").count
    }
    
    func fetchCompletedCount() -> Int {
        return realm.objects(ReminderTable.self).filter("isCompleted == true").count
    }
}


