//
//  DataModel.swift
//  Reminders
//
//  Created by hwanghye on 7/3/24.
//

import UIKit
import RealmSwift

class Folder: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var icon: String
    @Persisted var name: String
    @Persisted var regDate: Date
    @Persisted var filterType: String
    
    @Persisted var detail: List<ReminderTable>
}

class ReminderTable: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted(indexed: true) var title: String // 필수
    @Persisted var content: String?
    @Persisted var date: Date?
    @Persisted var tag: String?
    @Persisted var priority: String?
    @Persisted var isFlagged: Bool = false
    @Persisted var isCompleted: Bool = false
    
    @Persisted(originProperty: "detail") var folderList: LinkingObjects<Folder>
    
    convenience init(title: String, content: String?, date: Date?, tag: String?, priority: String?) {
        self.init()
        self.title = title
        self.content = content
        self.date = date
        self.tag = tag
        self.priority = priority
    }
}
