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
    let textFieldView = UIView()
    let textFieldLine = UIView()
    let titleTextField = UITextField()
    let memoTextField = UITextField()
    //    let dateTextField = UITextField()
    //    let tagTextField = UITextField()
    
    let tableView = UITableView()
    
    let menuTexts: [String] = [
        "마감일",
        "태그",
        "우선 순위",
        "이미지 추가"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "새로운 할 일"
        
        //        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dateTextFieldClicked))
        //        dateTextField.addGestureRecognizer(tapGesture)
    }
    
    override func configureHierarchy() {
        view.addSubview(textFieldView)
        textFieldView.addSubview(titleTextField)
        textFieldView.addSubview(textFieldLine)
        textFieldView.addSubview(memoTextField)
        view.addSubview(tableView)
        //        view.addSubview(dateTextField)
        //        view.addSubview(tagTextField)
    }
    
    override func configureView() {
        super.configureView()
        
        textFieldView.backgroundColor = .white.withAlphaComponent(0.2)
        textFieldView.layer.cornerRadius = 12
        
        titleTextField.placeholder = "제목"
        titleTextField.placeholderColor = .darkGray
        
        textFieldLine.layer.borderWidth = 1
        textFieldLine.backgroundColor = .darkGray
        
        memoTextField.placeholder = "메모"
        memoTextField.placeholderColor = .darkGray
        memoTextField.textAlignment = .natural
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AddTableViewCell.self, forCellReuseIdentifier: AddTableViewCell.id)
        tableView.backgroundColor = .clear
//        tableView.separatorStyle = .none
        
        
        //        titleTextField.backgroundColor = .systemGray4
        //        memoTextField.backgroundColor = .systemGray4
        //        dateTextField.backgroundColor = .systemGray4
        //        tagTextField.backgroundColor = .systemGray4
        
        //        let addButton = UIBarButtonItem(title: " 추가", style: .plain, target: self, action: #selector(addButtonClicked))
        //        navigationItem.rightBarButtonItem = addButton
        
        
        
        //
        //        dateTextField.placeholder = "마감일"
        //        tagTextField.placeholder = "태그"
    }
    
    override func configureLayout() {
        textFieldView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(180)
        }
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(textFieldView.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(textFieldView.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(50)
        }
        textFieldLine.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom)
            make.horizontalEdges.equalTo(titleTextField.safeAreaLayoutGuide).inset(5)
            make.height.equalTo(1)
        }
        memoTextField.snp.makeConstraints { make in
            make.top.equalTo(textFieldLine.snp.bottom)
            make.horizontalEdges.equalTo(textFieldView.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(130)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(textFieldView.snp.bottom).offset(14)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(14)
            make.height.equalTo(300)
        }
        //        dateTextField.snp.makeConstraints { make in
        //            make.top.equalTo(memoTextField.snp.bottom).offset(20)
        //            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        //            make.height.equalTo(48)
        //        }
        //        tagTextField.snp.makeConstraints { make in
        //            make.top.equalTo(dateTextField.snp.bottom).offset(20)
        //            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        //            make.height.equalTo(48)
        //        }
    }
    
    @objc func dateTextFieldClicked() {
        let vc = DateViewController()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //    @objc func addButtonClicked() {
    //        print(#function)
    //        // Realm 위치 찾기
    //        let realm = try! Realm()
    //
    //        guard let title = titleTextField.text, !title.isEmpty,
    //              let content = memoTextField.text,
    //              let date = dateTextField.text  else {
    //            view.showToast(message: "제목을 입력해주세요")
    //            return
    //        }
    //        // Data 생성
    //        let data = ReminderListTable(title: title, content: content, deadLineDate: date)
    //        // Realm에 생성된 Record 추가
    //        try! realm.write {
    //            realm.add(data)
    //            print("Realm Create Succeed")
    //        }
    //        titleTextField.text = ""
    //        memoTextField.text = ""
    //        dateTextField.text = ""
    //
    //        let vc = ReminderListViewController()
    //        navigationController?.pushViewController(vc, animated: true)
    //    }
}

extension AddViewController: DateViewControllerDelegate {
    func didSelectDate(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd (EEEE)"
        //        dateTextField.text = formatter.string(from: date)
    }
}

extension AddViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuTexts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AddTableViewCell.id, for: indexPath) as! AddTableViewCell
        
        cell.backgroundColor = .clear
        cell.contentView.layer.cornerRadius = 8
        cell.selectionStyle = .none
        cell.menuTitleLabel.text = menuTexts[indexPath.row]
        cell.menuTitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        cell.menuTitleLabel.textColor = .white
        cell.menuIcon.tintColor = .darkGray
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // 셀의 위아래 간격을 위한 footer view 추가
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10 // 셀 간의 간격
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear // 간격을 위한 빈 뷰
        return view
    }
    
    
}

