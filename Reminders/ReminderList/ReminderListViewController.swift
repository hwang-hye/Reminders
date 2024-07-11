//
//  ReminderListViewController.swift
//  Reminders
//
//  Created by hwanghye on 7/3/24.
//

import UIKit
import RealmSwift
import SnapKit

class ReminderListViewController: BaseViewController, PriorityViewControllerDelegate, ListTableViewCellDelegate {
    
    let reminderListTableView = UITableView()
    var reminderList: Results<ReminderTable>?
    var filterType: FilterType?
    let repository = DataRepository()
    let realm = try! Realm()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
        fetchData()
    }
    
    override func configureHierarchy() {
        view.addSubview(reminderListTableView)
    }
    
    override func configureLayout() {
        reminderListTableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configureView() {
        super.configureView()
        reminderListTableView.backgroundColor = .black
        reminderListTableView.delegate = self
        reminderListTableView.dataSource = self
        reminderListTableView.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.id)
    }
    
    @objc private func fetchData() {
        // filterType에 따라 reminderList 업데이트
        switch filterType {
        case .today:
            let today = Date()
            let startOfDay = Calendar.current.startOfDay(for: today)
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
            reminderList = realm.objects(ReminderTable.self).filter("date >= %@ AND date < %@ AND isCompleted == false", startOfDay, endOfDay).sorted(byKeyPath: "title", ascending: false)
//        case .upcoming:
//            let today = Date()
//            reminderList = realm.objects(ReminderTable.self).filter("date >= %@ AND isCompleted == false", today).sorted(byKeyPath: "title", ascending: false)
        case .upcoming:
            let today = Calendar.current.startOfDay(for: Date())
            reminderList = realm.objects(ReminderTable.self)
                .filter("date > %@ AND isCompleted == false", today)
                .sorted(byKeyPath: "date", ascending: true)
        case .all:
            reminderList = realm.objects(ReminderTable.self).filter("isCompleted == false").sorted(byKeyPath: "title", ascending: false)
        case .flagged:
            reminderList = realm.objects(ReminderTable.self).filter("isFlagged == true AND isCompleted == false").sorted(byKeyPath: "title", ascending: false)
        case .completed:
            reminderList = realm.objects(ReminderTable.self).filter("isCompleted == true").sorted(byKeyPath: "title", ascending: false)
        case .none:
            reminderList = realm.objects(ReminderTable.self).filter("isCompleted == false").sorted(byKeyPath: "title", ascending: false)
        }
    }
    
    private func deleteReminder(at indexPath: IndexPath) {
        guard let reminder = reminderList?[indexPath.row] else { return }
        
        let reminderId = reminder.id
        
        do {
            try realm.write {
                realm.delete(reminder)
            }
            removeImageFromDocument(filename: "\(reminderId)")
            fetchData()
        } catch {
            print("Error deleting reminder: \(error)")
        }
    }
    
    // flagReminder 메서드 수정
    private func flagReminder(at indexPath: IndexPath) {
        guard let reminder = reminderList?[indexPath.row] else { return }
        
        do {
            try realm.write {
                reminder.isFlagged.toggle() // isFlagged 상태를 토글
            }
            fetchData() // 데이터를 새로고침하여 UI 업데이트
        } catch {
            print("Error flagging reminder: \(error)")
        }
    }
    
    
    func didSelectPriority(_ priority: String) {
        guard let selectedIndexPath = reminderListTableView.indexPathForSelectedRow,
              let reminder = reminderList?[selectedIndexPath.row] else {
            return
        }
        
        do {
            try realm.write {
                reminder.priority = priority
            }
            reminderListTableView.reloadRows(at: [selectedIndexPath], with: .automatic)
        } catch {
            print("Error updating reminder priority: \(error)")
        }
    }
    
    
    func showPriorityViewController(for indexPath: IndexPath) {
        let priorityVC = PriorityViewController()
        priorityVC.delegate = self
        if let reminder = reminderList?[indexPath.row] {
            if let priorityInt = Int(reminder.priority!) {
                priorityVC.viewModel.inputPriorityTag.value = Priority(rawValue: priorityInt) ?? .medium
            } else {
                priorityVC.viewModel.inputPriorityTag.value = .medium
            }
        }
        navigationController?.pushViewController(priorityVC, animated: true)
    }
    
    func didToggleCheckBox(at indexPath: IndexPath, isCompleted: Bool) {
        guard let reminder = reminderList?[indexPath.row] else { return }
        
        do {
            realm.beginWrite()
            
            reminder.isCompleted = isCompleted
            
            if isCompleted {
                repository.moveToCompleted(reminder)
            }
            
            try realm.commitWrite()
            
            if isCompleted {
                // 데이터 소스 업데이트
                fetchData()
                
                // UI 업데이트를 메인 스레드에서 수행
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    // 테이블 뷰 업데이트
                    self.reminderListTableView.reloadData()
                    
                    // MainViewController의 카운트 업데이트
                    NotificationCenter.default.post(name: NSNotification.Name("UpdateMainViewControllerCounts"), object: nil)
                }
            }
        } catch {
            print("Error updating reminder completion status: \(error)")
        }
    }
}

extension ReminderListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminderList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.id) as! ListTableViewCell
        guard let data = reminderList?[indexPath.row] else { return cell }
        
        let image = loadImageToDocument(filename: "\(data.id)")
        cell.configure(with: data, image: image, isCompletedCategory: filterType == .completed)
        
        cell.indexPath = indexPath
        cell.delegate = self
        cell.deleteAction = { [weak self] in
            self?.deleteReminder(at: indexPath)
        }
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.id) as! ListTableViewCell
//        guard (reminderList?[indexPath.row]) != nil else { return cell } // reminder 객체 가져오기
//        guard let data = reminderList?[indexPath.row] else { return cell }
//        cell.selectionStyle = .none
//        cell.photoImage.image = loadImageToDocument(filename: "\(data.id)")
//        cell.titleLabel.text = data.title
//        cell.memoLabel.text = data.content
//        cell.priorityLabel.text = data.priority
//        
//        cell.indexPath = indexPath
//        cell.deleteAction = { [weak self] in
//            self?.deleteReminder(at: indexPath)
//        }
//        
//        if let date = data.date {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy.MM.dd (E)"
//            cell.dateLabel.text = dateFormatter.string(from: date)
//        } else {
//            cell.dateLabel.text = nil
//        }
//        cell.tagLabel.text = data.tag
//        cell.checkBoxButton.isSelected = data.isCompleted // CheckBox의 상태를 isCompleted 값에 따라 설정
//        
//        // 체크박스 설정
//        let isEnabled = filterType != .completed // 완료됨 카테고리가 아닐 때만 활성화
//        cell.configureCheckBox(isCompleted: data.isCompleted, isEnabled: isEnabled)
//        
//        cell.delegate = self // Cell의 Delegate를 설정
//        
//        return cell
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if filterType != .completed {
            showPriorityViewController(for: indexPath)
        }
        // 완료됨 카테고리에서는 아무 동작도 하지 않게 하기
    }
    
    // cell swipe 기능 처리
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completion) in
            self?.deleteReminder(at: indexPath)
            completion(true)
        }
        
        if filterType != .completed {
            let flagAction = UIContextualAction(style: .normal, title: "Flag") { [weak self] (action, view, completion) in
                self?.flagReminder(at: indexPath)
                completion(true)
            }
            flagAction.backgroundColor = .systemYellow
            
            return UISwipeActionsConfiguration(actions: [deleteAction, flagAction])
        } else {
            // 완료됨 카테고리에서는 삭제 액션만 제공
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear // 간격을 위한 빈 뷰
        return view
    }
}


