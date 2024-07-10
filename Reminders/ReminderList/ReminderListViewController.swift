//
//  ReminderListViewController.swift
//  Reminders
//
//  Created by hwanghye on 7/3/24.
//

import UIKit
import RealmSwift
import SnapKit

class ReminderListViewController: BaseViewController, PriorityViewControllerDelegate {
    
    let reminderListTableView = UITableView()
    var reminderList: Results<ReminderTable>!
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
        switch filterType {
        case .today:
            let today = Date()
            let startOfDay = Calendar.current.startOfDay(for: today)
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
            reminderList = realm.objects(ReminderTable.self).filter("date >= %@ AND date < %@", startOfDay, endOfDay).sorted(byKeyPath: "title", ascending: false)
        case .upcoming:
            let today = Date()
            reminderList = realm.objects(ReminderTable.self).filter("date >= %@", today).sorted(byKeyPath: "title", ascending: false)
        case .all:
            reminderList = realm.objects(ReminderTable.self).sorted(byKeyPath: "title", ascending: false)
        case .flagged:
            reminderList = realm.objects(ReminderTable.self).filter("isFlagged == true").sorted(byKeyPath: "title", ascending: false)
        case .completed:
            reminderList = realm.objects(ReminderTable.self).filter("isCompleted == true").sorted(byKeyPath: "title", ascending: false)
        case .none:
            reminderList = realm.objects(ReminderTable.self).sorted(byKeyPath: "title", ascending: false)
        }
        DispatchQueue.main.async {
            self.reminderListTableView.reloadData()
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
}

extension ReminderListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminderList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.id) as! ListTableViewCell
        let data = reminderList[indexPath.row]
        cell.selectionStyle = .none
        cell.photoImage.image = loadImageToDocument(filename: "\(data.id)")
        cell.titleLabel.text = data.title
        cell.memoLabel.text = data.content
        cell.priorityLabel.text = data.priority
        
        if let date = data.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd (E)"
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = nil
        }
        cell.tagLabel.text = data.tag
        cell.deleteAction = { [weak self] in
            self?.deleteReminder(at: indexPath)
        }
        cell.priorityLabel.text = data.priority
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showPriorityViewController(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteReminder(at: indexPath)
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


