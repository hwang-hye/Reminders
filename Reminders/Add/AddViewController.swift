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
    let dateTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "새로운 할 일"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dateTextFieldClicked))
        dateTextField.addGestureRecognizer(tapGesture)
    }
    
    override func configureHierarchy() {
        view.addSubview(titleTextField)
        view.addSubview(memoTextField)
        view.addSubview(dateTextField)
    }
    
    override func configureView() {
        super.configureView()
        titleTextField.backgroundColor = .darkGray
        memoTextField.backgroundColor = .lightGray
        dateTextField.backgroundColor = .systemGray4
        
        let addButton = UIBarButtonItem(title: " 추가", style: .plain, target: self, action: #selector(addButtonClicked))
        navigationItem.rightBarButtonItem = addButton
        
        titleTextField.placeholder = "제목"
        memoTextField.placeholder = "메모"
        dateTextField.placeholder = "마감일"
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
        dateTextField.snp.makeConstraints { make in
            make.top.equalTo(memoTextField.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(48)
        }
    }
    
    @objc func dateTextFieldClicked() {
        let vc = DateViewController()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func addButtonClicked() {
        print(#function)
        // Realm 위치 찾기
        let realm = try! Realm()
        
        guard let title = titleTextField.text, !title.isEmpty,
              let content = memoTextField.text,
              let date = dateTextField.text  else {
            view.showToast(message: "제목을 입력해주세요")
            return
        }
        // Data 생성
        let data = ReminderListTable(title: title, content: content, deadLineDate: date)
        // Realm에 생성된 Record 추가
        try! realm.write {
            realm.add(data)
            print("Realm Create Succeed")
        }
        titleTextField.text = ""
        memoTextField.text = ""
        dateTextField.text = ""
        
        let vc = ReminderListViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension AddViewController: DateViewControllerDelegate {
    func didSelectDate(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd (EEEE)"
        dateTextField.text = formatter.string(from: date)
    }
}

