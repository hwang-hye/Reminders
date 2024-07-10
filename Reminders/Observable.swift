//
//  Observable.swift
//  Reminders
//
//  Created by hwanghye on 7/9/24.
//

import Foundation

class Observable<T> {
    
    var closure: ((T) -> Void)?
    
    var value: T {
        didSet {
            print("didset")
            closure?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(closure: @escaping (T) -> Void) {
        closure(value) // 무조건 실행, 기능에 따라 필요 없을 수도 있다
        self.closure = closure
    }
}
