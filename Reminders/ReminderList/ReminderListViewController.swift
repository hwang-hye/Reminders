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
    var reminderList: Results<ReminderListTable>!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reminderList = realm.objects(ReminderListTable.self).sorted(byKeyPath: "title", ascending: false)
        print(realm.configuration.fileURL)
        // 필터 기능 처리
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
        reminderListTableView.reloadData()
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
        reminderListTableView.rowHeight = 120
        reminderListTableView.delegate = self
        reminderListTableView.dataSource = self
        reminderListTableView.register(ListTableViewCell.self, forCellReuseIdentifier: ListTableViewCell.id)
    }
}

extension ReminderListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminderList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.id) as! ListTableViewCell
        let data = reminderList[indexPath.row]
        cell.configure(with: indexPath, delegate: self)
        cell.titleLabel.text = data.title
        cell.memoLabel.text = data.content
        cell.dateLabel.text = data.deadLineDate
        return cell
    }
}

extension ReminderListViewController: ListTableViewCellDelegate {
    func didToggleCheckButton(at indexPath: IndexPath) {
        try! realm.write {
            realm.delete(reminderList[indexPath.row])
        }
        reminderListTableView.deleteRows(at: [indexPath], with: .automatic)
        reminderListTableView.reloadData()
    }
}

