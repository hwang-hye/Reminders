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
            schemaVersion: 1, // 새로운 버전 번호
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
            }
        )
        
        Realm.Configuration.defaultConfiguration = config
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

