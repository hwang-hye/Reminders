//
//  ViewController.swift
//  Reminders
//
//  Created by hwanghye on 7/2/24.
//

import UIKit
import RealmSwift
import SnapKit

class AddViewController: BaseViewController {
    let titleTextField = UITextField()
    let memoTextField = UITextField()
    let deadlineTextField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "새로운 할 일"
    }
    
    override func configureHierarchy() {
        view.addSubview(titleTextField)
        view.addSubview(memoTextField)
        view.addSubview(deadlineTextField)
    }
    
    override func configureView() {
        super.configureView()
        titleTextField.backgroundColor = .darkGray
        memoTextField.backgroundColor = .lightGray
        deadlineTextField.backgroundColor = .systemGray4
        
        let addButton = UIBarButtonItem(title: " 추가", style: .plain, target: self, action: #selector(addButtonClicked))
                navigationItem.rightBarButtonItem = addButton
        
        titleTextField.placeholder = "제목"
        memoTextField.placeholder = "메모"
        deadlineTextField.placeholder = "마감일"
    }
    
    override func configureLayout() {
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(48)
        }
        memoTextField.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(180)
        }
        deadlineTextField.snp.makeConstraints { make in
            make.top.equalTo(memoTextField.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(48)
        }
    }
    
    @objc func addButtonClicked() {
        print(#function)
        let vc = ReminderListViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

