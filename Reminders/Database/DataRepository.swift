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
                print("Realm Create Succeed: \(data.title), Priority: \(data.priority)")
            }
        } catch {
            print("Realm Error: \(error)")
        }
    }
    
    func fetchAll() -> [ReminderTable] {
        let value = realm.objects(ReminderTable.self).sorted(byKeyPath: "money", ascending: false)
        return Array(value)
    }
    
    func deleteItem(_ reminder: ReminderTable) {
        try? realm.write {
            realm.delete(reminder)
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
        do {
            try realm.write {
                reminder.isCompleted = true
                reminder.isFlagged = false  // 완료된 항목은 깃발 표시 해제
                realm.add(reminder, update: .modified)
            }
        } catch {
            print("Move to Completed Error: \(error)")
        }
    }
    
    func toggleCheckBox(_ reminder: ReminderTable) {
        try? realm.write {
            reminder.isCompleted.toggle()
            if reminder.isCompleted {
                reminder.isFlagged = false
            }
        }
    }
    
    func toggleFlag(_ reminder: ReminderTable) {
        try? realm.write {
            reminder.isFlagged.toggle()
        }
    }
    
    
    // filterType에 따라 reminderList 업데이트
    func fetchData(_ filterType: FilterType) -> Results<ReminderTable> {
        switch filterType {
        case .today:
            let today = Calendar.current.startOfDay(for: Date())
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
            return realm.objects(ReminderTable.self).filter("date >= %@ AND date < %@ AND isCompleted == false", today, tomorrow)
        case .upcoming:
            let today = Calendar.current.startOfDay(for: Date())
            return realm.objects(ReminderTable.self).filter("date > %@ AND isCompleted == false", today)
        case .all:
            return realm.objects(ReminderTable.self).filter("isCompleted == false")
        case .flagged:
            return realm.objects(ReminderTable.self).filter("isFlagged == true")
        case .completed:
            return realm.objects(ReminderTable.self).filter("isCompleted == true")
        }
    }
    
    func updateAllFolderDetail() {
        let filterTypes: [FilterType] = [.all, .completed, .flagged, .today, .upcoming]
        for filterType in filterTypes {
            do {
                let results = try fetchData(filterType)
                try realm.write {
                    let folder = realm.objects(Folder.self).filter("filterType == %@", String(describing: filterType)).first
                    folder?.detail = results.reduce(List<ReminderTable>()) { list, element in
                        list.append(element)
                        return list
                    }
                }
            } catch {
                print("Error updating folder detail for \(filterType): \(error)")
            }
        }
    }
    
    func updateItem(_ reminder: ReminderTable) {
        do {
            try realm.write {
                realm.add(reminder, update: .modified)
                print("Realm Update Succeed: \(reminder.title), Priority: \(reminder.priority)")
            }
        } catch {
            print("Realm Update Error: \(error)")
        }
    }
    
    func updatePriority(for reminder: ReminderTable, with priority: String) throws {
        try realm.write {
            reminder.priority = priority
        }
    }
}


