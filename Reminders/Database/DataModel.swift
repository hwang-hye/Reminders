//
//  DataModel.swift
//  Reminders
//
//  Created by hwanghye on 7/3/24.
//

import UIKit
import RealmSwift

class ReminderListTable: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted(indexed: true) var title: String
    @Persisted var content: String?
    @Persisted var deadLineDate: Date?
    
    convenience init(title: String, content: String?, deadLineDate: Date?) {
        self.init()
        self.title = title
        self.content = content
        self.deadLineDate = deadLineDate
    }
}
