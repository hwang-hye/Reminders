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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.id) as! ListTableViewCell
        return cell
    }
}

