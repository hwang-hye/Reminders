//
//  AppDelegate.swift
//  Reminders
//
//  Created by hwanghye on 7/2/24.
//

import UIKit
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        // Realm 데이터베이스 마이그레이션 설정
        let config = Realm.Configuration(
            schemaVersion: 7, // 새로운 버전 번호
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    // 마이그레이션 코드 추가
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
                    // 새로운 필드에 대한 기본값 설정
                    migration.enumerateObjects(ofType: ReminderTable.className()) { oldObject, newObject in
                        newObject?["isFlagged"] = false
                        newObject?["isCompleted"] = false
                    }
                }
                if oldSchemaVersion < 3 {
                    // icon 추가
                    migration.enumerateObjects(ofType: Folder.className()) { oldObject, newObject in
                        newObject?["icon"] = "folder.circle"
                    }
                }
                if oldSchemaVersion < 4 {
                    // Folder icon, name 수정
                }
                if oldSchemaVersion < 5 {
                    // Folder filterType 추가
                    // ReminderTable Linking Object 연결
                }
                if oldSchemaVersion < 6 {
                    // Folder count type 수정
                }
                if oldSchemaVersion < 7 {
                    // Folder count 프로퍼티 삭제(UI에서 해결)
                }
            }
        )
        
        let icons: [String] = [
            "pencil.circle.fill",
            "calendar.circle.fill",
            "tray.circle.fill",
            "flag.circle.fill",
            "checkmark.circle.fill"
        ]
        
        let folderTitles: [String] = [
            "오늘",
            "예정",
            "전체",
            "깃발 표시",
            "완료됨"
        ]
        
        let folderTypes: [String] = [
            "today",
            "upcoming",
            "all",
            "flagged",
            "completed"
        ]
        
        
        Realm.Configuration.defaultConfiguration = config
        
        let realm = try! Realm()
        
        let count = realm.objects(Folder.self).count
        
        if count == 0 {
            for i in 0...4 {
                let folder = Folder()
                folder.icon = icons[i]
                folder.name = folderTitles[i]
                folder.filterType = folderTypes[i]
                
                do {
                    try realm.write {
                        realm.add(folder)
                    }
                } catch {
                    print("Write error!")
                }
            }
        }
        
        return true
    }

    
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

