//
//  DataModel.swift
//  Reminders
//
//  Created by hwanghye on 7/3/24.
//

import UIKit
import RealmSwift

class ReminderTable: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted(indexed: true) var title: String // 필수
    @Persisted var content: String?
    @Persisted var date: String?
    @Persisted var tag: String?
    @Persisted var priority: String?
    
    convenience init(title: String, content: String?, date: String?, tag: String?, priority: String?) {
        self.init()
        self.title = title
        self.content = content
        self.date = date
        self.tag = tag
        self.priority = priority
    }
}
