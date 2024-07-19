//
//  ReminderListViewModel.swift
//  Reminders
//
//  Created by hwanghye on 7/15/24.
//

import Foundation

class ReminderListViewModel {
    var reminderList: Observable<[ReminderTable]> = Observable([])
    var filterType: FilterType?
    
    var error: Observable<String?> = Observable(nil)
    
    private let repository: DataRepository
    
    // 의존성 주입(Dependency Injection)
    // 필요에 따라 다른 종류의 repository 사용
    // 테스트 코드 등 사용 용이
    init(repository: DataRepository = DataRepository()) {
        self.repository = repository
    }
    
//    func fetchReminders() {
//        guard let filterType = filterType else {
//            error.value = "filterType 지정 안됨"
//            return
//        }
//        
//        let results = repository.fetchData(filterType)
//        reminderList.value = Array(results)
//    }
    
    
    func fetchReminders() {
        guard let filterType = filterType else { return }
        let results = repository.fetchData(filterType)
        reminderList.value = Array(results)
    }
    
    func deleteReminder(at index: Int) {
        guard index < reminderList.value.count else { return }
        let reminder = reminderList.value[index]
        repository.deleteItem(reminder)
        fetchReminders()
    }
    
//    func toggleFlag(at index: Int) {
//        guard index < reminderList.value.count else { return }
//        let reminder = reminderList.value[index]
//        repository.toggleFlag(reminder)
//        fetchReminders()
//    }
    
    func toggleFlag(at index: Int) {
        guard index < reminderList.value.count else { return }
        let reminder = reminderList.value[index]
        repository.toggleFlag(reminder)
        fetchReminders() // 데이터를 다시 불러와 UI를 업데이트합니다.
        NotificationCenter.default.post(name: NSNotification.Name("UpdateMainViewControllerCounts"), object: nil)
    }

    func toggleCheckBox(at index: Int) {
        guard index < reminderList.value.count else { return }
        let reminder = reminderList.value[index]
        repository.toggleCheckBox(reminder)
        fetchReminders()
    }
    
    func removeItem(at index: Int) {
        guard index < reminderList.value.count else { return }
        reminderList.value.remove(at: index)
    }
    
    func updatePriority(_ priority: String, at index: Int) {
        guard index < reminderList.value.count else { return }
        let reminder = reminderList.value[index]
        
        do {
            try repository.updatePriority(for: reminder, with: priority)
            fetchReminders() // 데이터를 다시 불러와 UI 업데이트
            print("우선순위 업데이트: \(priority)")
        } catch {
            self.error.value = "우선순위 업데이트 실패: \(error.localizedDescription)"
        }
    }
}
