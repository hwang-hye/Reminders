//
//  AppDelegate.swift
//  Reminders
//
//  Created by hwanghye on 7/2/24.
//

import UIKit
import RealmSwift
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupDailyNotification()
        UNUserNotificationCenter.current().delegate = self
        
        // Realm 데이터베이스 마이그레이션 설정
        let config = Realm.Configuration(
            schemaVersion: 8,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 8 {
                    // 마이그레이션 코드
                    if oldSchemaVersion < 1 {
                        migration.enumerateObjects(ofType: ReminderTable.className()) { oldObject, newObject in
                            if let dateString = oldObject?["date"] as? String {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy.MM.dd (E)"
                                if let date = dateFormatter.date(from: dateString) {
                                    newObject?["date"] = date
                                } else {
                                    newObject?["date"] = nil
                                }
                            }
                        }
                    }
                    if oldSchemaVersion < 2 {
                        migration.enumerateObjects(ofType: ReminderTable.className()) { oldObject, newObject in
                            newObject?["isFlagged"] = false
                            newObject?["isCompleted"] = false
                        }
                    }
                    if oldSchemaVersion < 3 {
                        migration.enumerateObjects(ofType: Folder.className()) { oldObject, newObject in
                            newObject?["icon"] = "folder.circle"
                        }
                    }
                    // 4-7까지의 마이그레이션 로직은 필요한 경우 여기에 추가
                }
            }
        )
        
        // Realm 구성 설정 및 초기화
        do {
            Realm.Configuration.defaultConfiguration = config
            let _ = try Realm()
            createInitialFolders()
        } catch {
            print("Error opening Realm: \(error)")
            // 여기서 적절한 오류 처리를 수행합니다.
        }
        
        return true
    }
    
    func createInitialFolders() {
        let realm = try! Realm()
        let count = realm.objects(Folder.self).count
        
        if count == 0 {
            let icons = ["pencil.circle.fill", "calendar.circle.fill", "tray.circle.fill", "flag.circle.fill", "checkmark.circle.fill"]
            let folderTitles = ["오늘", "예정", "전체", "깃발 표시", "완료됨"]
            let folderTypes = ["today", "upcoming", "all", "flagged", "completed"]
            
            try? realm.write {
                for i in 0...4 {
                    let folder = Folder()
                    folder.icon = icons[i]
                    folder.name = folderTitles[i]
                    folder.filterType = folderTypes[i]
                    realm.add(folder)
                }
            }
        }
    }
    
    func setupDailyNotification() {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.sound = .none

        var dateComponents = DateComponents()
        dateComponents.hour = 0
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyUpdate", content: content, trigger: trigger)

        center.add(request) { (error) in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == "dailyUpdate" {
            NotificationCenter.default.post(name: NSNotification.Name("DateChanged"), object: nil)
        }
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([])  // 알림을 표시하지 않음
    }
}



//class AppDelegate: UIResponder, UIApplicationDelegate {
//    
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        
//        setupDailyNotification()
//        UNUserNotificationCenter.current().delegate = self
//        return true
//        
//        scheduleReminderUpdate()
//        setupDailyUpdate()
//        
//        // Realm 데이터베이스 마이그레이션 설정
//        let config = Realm.Configuration(
//            schemaVersion: 8, // 새로운 버전 번호
//            migrationBlock: { migration, oldSchemaVersion in
//                if oldSchemaVersion < 1 {
//                    // 마이그레이션 코드 추가
//                    migration.enumerateObjects(ofType: ReminderTable.className()) { oldObject, newObject in
//                        if let dateString = oldObject?["date"] as? String {
//                            let dateFormatter = DateFormatter()
//                            dateFormatter.dateFormat = "yyyy.MM.dd (E)"
//                            if let date = dateFormatter.date(from: dateString) {
//                                newObject?["date"] = date
//                            } else {
//                                newObject?["date"] = nil
//                            }
//                        }
//                    }
//                }
//                if oldSchemaVersion < 2 {
//                    // 새로운 필드에 대한 기본값 설정
//                    migration.enumerateObjects(ofType: ReminderTable.className()) { oldObject, newObject in
//                        newObject?["isFlagged"] = false
//                        newObject?["isCompleted"] = false
//                    }
//                }
//                if oldSchemaVersion < 3 {
//                    // icon 추가
//                    migration.enumerateObjects(ofType: Folder.className()) { oldObject, newObject in
//                        newObject?["icon"] = "folder.circle"
//                    }
//                }
//                if oldSchemaVersion < 4 {
//                    // Folder icon, name 수정
//                }
//                if oldSchemaVersion < 5 {
//                    // Folder filterType 추가
//                    // ReminderTable Linking Object 연결
//                }
//                if oldSchemaVersion < 6 {
//                    // Folder count type 수정
//                }
//                if oldSchemaVersion < 7 {
//                    // Folder count 프로퍼티 삭제(UI에서 해결)
//                }
//                if oldSchemaVersion < 8 {
//                    // ReminderTable priority 수정
//                }
//            }
//        )
//        
//        let icons: [String] = [
//            "pencil.circle.fill",
//            "calendar.circle.fill",
//            "tray.circle.fill",
//            "flag.circle.fill",
//            "checkmark.circle.fill"
//        ]
//        
//        let folderTitles: [String] = [
//            "오늘",
//            "예정",
//            "전체",
//            "깃발 표시",
//            "완료됨"
//        ]
//        
//        let folderTypes: [String] = [
//            "today",
//            "upcoming",
//            "all",
//            "flagged",
//            "completed"
//        ]
//        
//        
//        Realm.Configuration.defaultConfiguration = config
//        
//        let realm = try! Realm()
//        
//        let count = realm.objects(Folder.self).count
//        
//        if count == 0 {
//            for i in 0...4 {
//                let folder = Folder()
//                folder.icon = icons[i]
//                folder.name = folderTitles[i]
//                folder.filterType = folderTypes[i]
//                
//                do {
//                    try realm.write {
//                        realm.add(folder)
//                    }
//                } catch {
//                    print("Write error!")
//                }
//            }
//        }
//        
//        return true
//    }
//    
//    func scheduleReminderUpdate() {
//        let calendar = Calendar.current
//        var dateComponents = DateComponents()
//        dateComponents.hour = 0
//        dateComponents.minute = 0
//        dateComponents.second = 0
//        
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
//        
//        let request = UNNotificationRequest(identifier: "com.yourapp.dailyUpdate", content: UNNotificationContent(), trigger: trigger)
//        
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error = error {
//                print("Error scheduling notification: \(error)")
//            }
//        }
//    }
//    
//    func setupDailyUpdate() {
//        let center = UNUserNotificationCenter.current()
//        let content = UNMutableNotificationContent()
//        content.sound = .none
//        
//        var dateComponents = DateComponents()
//        dateComponents.hour = 0
//        dateComponents.minute = 0
//        
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
//        let request = UNNotificationRequest(identifier: "dailyUpdate", content: content, trigger: trigger)
//        
//        center.add(request) { (error) in
//            if let error = error {
//                print("Error scheduling notification: \(error.localizedDescription)")
//            }
//        }
//        
//        center.delegate = self
//    }
//    
//    func setupDailyNotification() {
//        let center = UNUserNotificationCenter.current()
//        let content = UNMutableNotificationContent()
//        content.sound = .none
//
//        var dateComponents = DateComponents()
//        dateComponents.hour = 0
//        dateComponents.minute = 0
//
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
//        let request = UNNotificationRequest(identifier: "dailyUpdate", content: content, trigger: trigger)
//
//        center.add(request) { (error) in
//            if let error = error {
//                print("Error scheduling notification: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    // MARK: UISceneSession Lifecycle
//    
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//    
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }
//    
//    
//}
//
//extension AppDelegate: UNUserNotificationCenterDelegate {
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandledr completionHandler: @escaping () -> Void) {
//        if response.notification.request.identifier == "dailyUpdate" {
//            NotificationCenter.default.post(name: NSNotification.Name("DateChanged"), object: nil)
//        }
//        completionHandler()
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([])  // 알림을 표시하지 않음
//    }
//}

