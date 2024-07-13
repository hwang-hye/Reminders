//
//  DataModel.swift
//  Reminders
//
//  Created by hwanghye on 7/3/24.
//

import UIKit
import RealmSwift

// 다시 수정하기
// category를 무엇으로 할지 생각해봐야 함
// 해당 테이블의 경우 분류 기준은?
// 1. Date(오늘, 예정, 전체)
// 2. 깃발(like)
// 3. 완료됨
// 오늘이 지난 데이터는 어디로 가야 하는지?


class Folder: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var icon: String
    @Persisted var name: String
    @Persisted var count: String
    @Persisted var regDate: Date
    
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
    
    convenience init(title: String, content: String?, date: Date?, tag: String?, priority: String?) {
        self.init()
        self.title = title
        self.content = content
        self.date = date
        self.tag = tag
        self.priority = priority
    }
}
