//
//  DateViewModel.swift
//  Reminders
//
//  Created by hwanghye on 7/15/24.
//

import Foundation

class DateViewModel {
    var selectedDate: Observable<Date> = Observable(Date())
    
    func updateDate(_ date: Date) {
        selectedDate.value = date
    }
}
