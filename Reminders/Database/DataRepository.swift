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
    
    //    func createItem(_ data: ReminderTable) {
    //        do {
    //            try realm.write {
    //                realm.add(data)
    //                print("Realm Create Succeed: \(data.title), Priority: \(data.priority)")
    //            }
    //        } catch {
    //            print("Realm Error: \(error)")
    //        }
    //    }
    
    func createItem(_ data: ReminderTable) {
        do {
            try realm.write {
                realm.add(data)
                
                let folders = realm.objects(Folder.self)
                for folder in folders {
                    if shouldBeInFolder(reminder: data, folderType: folder.filterType) {
                        folder.detail.append(data)
                    }
                }
                
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
    
    private func shouldBeInFolder(reminder: ReminderTable, folderType: String) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        switch folderType {
        case "today":
            guard let reminderDate = reminder.date else { return false }
            return Calendar.current.isDate(reminderDate, inSameDayAs: today)
        case "upcoming":
            guard let reminderDate = reminder.date else { return false }
            return reminderDate > today
        case "all":
            return !reminder.isCompleted
        case "flagged":
            return reminder.isFlagged && !reminder.isCompleted
        case "completed":
            return reminder.isCompleted
        default:
            return false
        }
    }
    
    
    // filterType에 따라 reminderList 업데이트
    //    func fetchData(_ filterType: FilterType) -> Results<ReminderTable> {
    //        switch filterType {
    //        case .today:
    //            let today = Calendar.current.startOfDay(for: Date())
    //            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
    //            return realm.objects(ReminderTable.self).filter("date >= %@ AND date < %@ AND isCompleted == false", today, tomorrow)
    //        case .upcoming:
    //            let today = Calendar.current.startOfDay(for: Date())
    //            return realm.objects(ReminderTable.self).filter("date > %@ AND isCompleted == false", today)
    //        case .all:
    //            return realm.objects(ReminderTable.self).filter("isCompleted == false")
    //        case .flagged:
    //            return realm.objects(ReminderTable.self).filter("isFlagged == true")
    //        case .completed:
    //            return realm.objects(ReminderTable.self).filter("isCompleted == true")
    //        }
    //    }
    
    func fetchData(_ filterType: FilterType) -> Results<ReminderTable> {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        switch filterType {
        case .today:
            return realm.objects(ReminderTable.self).filter("date >= %@ AND date < %@ AND isCompleted == false", today, tomorrow)
        case .upcoming:
            return realm.objects(ReminderTable.self).filter("date >= %@ AND isCompleted == false", tomorrow)
        case .all:
            return realm.objects(ReminderTable.self).filter("isCompleted == false")
        case .flagged:
            return realm.objects(ReminderTable.self).filter("isFlagged == true AND isCompleted == false")
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
    
//    func updateItem(_ reminder: ReminderTable) {
//        do {
//            try realm.write {
//                realm.add(reminder, update: .modified)
//                print("Realm Update Succeed: \(reminder.title), Priority: \(reminder.priority)")
//            }
//        } catch {
//            print("Realm Update Error: \(error)")
//        }
//    }
    
    func updateItem(_ reminder: ReminderTable) {
        try? realm.write {
            realm.add(reminder, update: .modified)
        }
    }
    
    func updatePriority(for reminder: ReminderTable, with priority: String) throws {
        try realm.write {
            reminder.priority = priority
        }
    }
    
    func moveExpiredRemindersToUpcoming() {
        let today = Calendar.current.startOfDay(for: Date())
        let expiredReminders = realm.objects(ReminderTable.self).filter("date < %@ AND isCompleted == false", today)
        
        try? realm.write {
            for reminder in expiredReminders {
                if let todayFolder = realm.objects(Folder.self).filter("filterType == 'today'").first,
                   let upcomingFolder = realm.objects(Folder.self).filter("filterType == 'upcoming'").first {
                    if let index = todayFolder.detail.index(of: reminder) {
                        todayFolder.detail.remove(at: index)
                    }
                    upcomingFolder.detail.append(reminder)
                }
            }
        }
    }
    
    func unflagReminder(_ reminder: ReminderTable) {
        try? realm.write {
            reminder.isFlagged = false
            
            let today = Calendar.current.startOfDay(for: Date())
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
            
            if reminder.date ?? Date() >= today && reminder.date ?? Date() < tomorrow {
                if let todayFolder = realm.objects(Folder.self).filter("filterType == 'today'").first {
                    todayFolder.detail.append(reminder)
                }
            } else if reminder.date ?? Date() >= tomorrow {
                if let upcomingFolder = realm.objects(Folder.self).filter("filterType == 'upcoming'").first {
                    upcomingFolder.detail.append(reminder)
                }
            }
        }
    }
}


