//
//  ViewController.swift
//  Reminders
//
//  Created by hwanghye on 7/2/24.
//

import UIKit
import RealmSwift
import SnapKit
import PhotosUI

class AddViewController: BaseViewController {
    let textFieldView = UIView()
    let textFieldLine = UIView()
    let titleTextField = UITextField()
    let memoTextField = UITextField()
    let tableView = UITableView()
    let photoImageView = UIImageView()
    
    let menuTexts: [String] = [
        "마감일",
        "태그",
        "우선 순위",
        "이미지 추가"
    ]
    
    var selectedDate: Date?
    var selectedTag: String?
    var selectedPriority: String?
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "새로운 할 일"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelButtonClicked))
        navigationItem.leftBarButtonItem = cancelButton
        
        let addButton = UIBarButtonItem(title: "추가", style: .plain, target: self, action: #selector(addButtonClicked))
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc func cancelButtonClicked() {
        print("취소 버튼")
        dismiss(animated: true, completion: nil)
    }
    
    @objc func addButtonClicked() {
        print("추가 버튼")
        print(#function)
        // Realm 위치 찾기ehe
        let realm = try! Realm()
    }
    
    override func configureHierarchy() {
        view.addSubview(textFieldView)
        textFieldView.addSubview(titleTextField)
        textFieldView.addSubview(textFieldLine)
        textFieldView.addSubview(memoTextField)
        view.addSubview(tableView)
        view.addSubview(photoImageView)
    }
    
    override func configureLayout() {
        textFieldView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
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
            make.height.equalTo(230)
        }
        photoImageView.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(14)
            make.height.equalTo(200)
        }
    }
    
    override func configureView() {
        super.configureView()
        view.backgroundColor = UIColor(named: "BackgroundGray")
        
        textFieldView.backgroundColor = .white.withAlphaComponent(0.08)
        textFieldView.layer.cornerRadius = 12
        
        titleTextField.placeholder = "제목"
        titleTextField.placeholderColor = .darkGray
        titleTextField.textColor = .white
        
        textFieldLine.layer.borderWidth = 1
        textFieldLine.layer.borderColor = UIColor.darkGray.cgColor
        
        memoTextField.placeholder = "메모"
        memoTextField.placeholderColor = .darkGray
        memoTextField.textAlignment = .natural
        memoTextField.textColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AddTableViewCell.self, forCellReuseIdentifier: AddTableViewCell.id)
        tableView.backgroundColor = .clear
        
        photoImageView.contentMode = .scaleAspectFit
    }
}

extension AddViewController: DatePickerViewControllerDelegate {
    func didSelectDate(_ date: Date) {
        selectedDate = date
        tableView.reloadData()
    }
}

extension AddViewController: TagViewControllerDelegate {
    func didSelectTag(_ tag: String) {
        selectedTag = tag
        tableView.reloadData()
    }
}

extension AddViewController: PriorityViewControllerDelegate {
    func didSelectPriority(_ priority: String) {
        selectedPriority = priority
        tableView.reloadData()
    }
}
extension AddViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        print(#function)
        
        picker.dismiss(animated: true)
        
        guard let itemProvider = results.first?.itemProvider else {
            return
        }
        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let self = self, let image = image as? UIImage else {
                    return
                }
                
                if let itemProvider = results.first?.itemProvider,
                   itemProvider.canLoadObject(ofClass: UIImage.self) {
                    
                    DispatchQueue.main.async {
                        self.selectedImage = image  // 선택된 이미지를 프로퍼티에 저장
                        self.photoImageView.image = self.selectedImage
                        self.tableView.reloadData()  // 테이블 뷰를 리로드하여 변경 사항을 반영
                    }
                }
            }
        }
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
        
        switch indexPath.row {
        case 0:
            if let date = selectedDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy.MM.DD (E)"
                cell.inputTextLabel.text = dateFormatter.string(from: date)
            } else {
                cell.inputTextLabel.text = nil
            }
        case 1:
            if let tag = selectedTag {
                cell.inputTextLabel.text = tag
            } else {
                cell.inputTextLabel.text = nil
            }
        case 2:
            if let priority = selectedPriority {
                cell.inputTextLabel.text = priority
            } else {
                cell.inputTextLabel.text = nil
            }
//        case 3:
//            if let image = selectedImage {
//                cell.menuIcon.image = image
//            } else {
//                cell.menuIcon.image = UIImage(systemName: "camera")
//            }
        default:
            cell.inputTextLabel.text = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            print("마감일")
            let dateVC = DateViewController()
            dateVC.delegate = self
            navigationController?.pushViewController(dateVC, animated: true)
        case 1:
            print("태그")
            let tagVC = TagViewController()
            tagVC.delegate = self
            navigationController?.pushViewController(tagVC, animated: true)
        case 2:
            print("우선순위")
            let priorityVC = PriorityViewController()
            priorityVC.delegate = self
            navigationController?.pushViewController(priorityVC, animated: true)
        case 3:
            print("이미지 추가")
            var configuration = PHPickerConfiguration()
            configuration.selectionLimit = 3
            configuration.filter = .any(of: [.screenshots, .images])
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            present(picker, animated: true)
        default:
            break
        }
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
