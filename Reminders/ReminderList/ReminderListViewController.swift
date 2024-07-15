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
    let viewModel = ReminderListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        setupBindings()
        viewModel.fetchReminders()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
        viewModel.fetchReminders()
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
    
    private func setupBindings() {
        viewModel.reminderList.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.reminderListTableView.reloadData()
            }
        }
        
        viewModel.error.bind { [weak self] error in
            if let error = error {
                self?.showError(error)
            }
        }
    }
    
    func setFilterType(_ filterType: FilterType) {
        viewModel.filterType = filterType
    }
    
    private func showError(_ error: String) {
        let alert = UIAlertController(title: "오류", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showPriorityViewController(for indexPath: IndexPath) {
        let priorityVC = PriorityViewController()
        priorityVC.delegate = self
        let reminder = viewModel.reminderList.value[indexPath.row]
        let priorityValue = Priority.fromString(reminder.priority)
        priorityVC.viewModel.inputPriorityTag.value = priorityValue
        priorityVC.indexPath = indexPath  // 인덱스 패스를 전달
        navigationController?.pushViewController(priorityVC, animated: true)
    }
    
    func didSelectPriority(_ priority: String, at indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        viewModel.updatePriority(priority, at: indexPath.row)
    }
    
    private func deleteReminder(at indexPath: IndexPath) {
        viewModel.deleteReminder(at: indexPath.row)
    }
    
    // flagReminder 메서드 수정
    private func flagReminder(at indexPath: IndexPath) {
        viewModel.toggleFlag(at: indexPath.row)
    }
    
    
    func didToggleCheckBox(at indexPath: IndexPath, isCompleted: Bool) {
        viewModel.toggleCheckBox(at: indexPath.row)
    }
}

extension ReminderListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.reminderList.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.id) as! ListTableViewCell
        let reminder = viewModel.reminderList.value[indexPath.row]
        let image = loadImageToDocument(filename: "\(reminder.id)")
        cell.configure(with: reminder, image: image, isCompletedCategory: viewModel.filterType == .completed)
        cell.indexPath = indexPath
        cell.delegate = self

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.filterType != .completed {
            showPriorityViewController(for: indexPath)
        }
        // 완료됨 카테고리에서는 아무 동작도 하지 않게 하기
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // cell swipe 기능 처리
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.viewModel.deleteReminder(at: indexPath.row)
            completion(true)
        }
        
        let flagAction = UIContextualAction(style: .normal, title: "Flag") { [weak self] _, _, completion in
            self?.viewModel.toggleFlag(at: indexPath.row)
            completion(true)
        }
        flagAction.backgroundColor = .systemYellow
        
        return UISwipeActionsConfiguration(actions: [deleteAction, flagAction])
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


