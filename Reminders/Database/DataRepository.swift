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
        return realm.objects(ReminderTable.self).filter("date >= %@ AND date < %@ AND isCompleted == false", startOfDay, endOfDay).count
    }
    
    func fetchUpcomingCount() -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        return realm.objects(ReminderTable.self)
            .filter("date > %@ AND isCompleted == false", today)
            .count
    }
    
    func fetchAllCount() -> Int {
        return realm.objects(ReminderTable.self).filter("isCompleted == false").count
    }
    
    func fetchFlaggedCount() -> Int {
        return realm.objects(ReminderTable.self).filter("isFlagged == true").count
    }
    
    func fetchCompletedCount() -> Int {
        return realm.objects(ReminderTable.self).filter("isCompleted == true").count
    }
    
    func moveToCompleted(_ reminder: ReminderTable) {
        // 이미 write 트랜잭션이 내부에 있다??
        reminder.isCompleted = true
        reminder.isFlagged = false  // 완료된 항목은 깃발 표시 해제
    }
    
    // filterType에 따라 reminderList 업데이트
    func fetchData(_ filterType: FilterType) -> Results<ReminderTable> {
        switch filterType {
        case .today:
            let today = Date()
            let startOfDay = Calendar.current.startOfDay(for: today)
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
            let reminderList = realm.objects(ReminderTable.self).filter("date >= %@ AND date < %@ AND isCompleted == false", startOfDay, endOfDay).sorted(byKeyPath: "title", ascending: false)
            updateFolderDetail(.today, reminderList)
            return reminderList

        case .upcoming:
            let today = Calendar.current.startOfDay(for: Date())
            let reminderList = realm.objects(ReminderTable.self)
                .filter("date > %@ AND isCompleted == false", today)
                .sorted(byKeyPath: "date", ascending: true)
            updateFolderDetail(.upcoming, reminderList)
            return reminderList
        case .all:
            let reminderList = realm.objects(ReminderTable.self).filter("isCompleted == false").sorted(byKeyPath: "title", ascending: false)
            updateFolderDetail(.all, reminderList)
            return reminderList
        case .flagged:
            let reminderList = realm.objects(ReminderTable.self).filter("isFlagged == true AND isCompleted == false").sorted(byKeyPath: "title", ascending: false)
            updateFolderDetail(.flagged, reminderList)
            return reminderList
        case .completed:
            let reminderList = realm.objects(ReminderTable.self).filter("isCompleted == true").sorted(byKeyPath: "title", ascending: false)
            updateFolderDetail(.completed, reminderList)
            return reminderList
//        case .none:
//            let reminderList = realm.objects(ReminderTable.self).filter("isCompleted == false").sorted(byKeyPath: "title", ascending: false)
        }
    }
    
    // detail 조회(filter)
    func updateFolderDetail(_ filterType: FilterType, _ results: Results<ReminderTable>) {
        let folder = realm.objects(Folder.self).filter("filterType == %@", String(describing: filterType)).first
        try! realm.write {
            folder?.detail = results.reduce(List<ReminderTable>()) { list, element in
                list.append(element)
                return list
            }
        }
    }
    
    func updateAllFolderDetail() {
        fetchData(.all)
        fetchData(.completed)
        fetchData(.flagged)
        fetchData(.today)
        fetchData(.upcoming)
    }
}


