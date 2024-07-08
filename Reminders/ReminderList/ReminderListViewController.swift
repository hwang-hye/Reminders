//
//  ReminderListViewController.swift
//  Reminders
//
//  Created by hwanghye on 7/3/24.
//

import UIKit
import RealmSwift
import SnapKit

class ReminderListViewController: BaseViewController {
    
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
            
            //            if let count = self.reminderList?.count {
            //                self.mainVC?.reminderListCount = count
            //                self.mainVC?.collectiocView.reloadData()
            //            }
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
        
        //        try! realm.write {
        //            realm.delete(reminder)
        //        }
        //        reminderListTableView.deleteRows(at: [indexPath], with: .automatic)
        //        removeImageFromDocument(filename: "\(reminder.id)")
        //
        //    }
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
        return cell
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


