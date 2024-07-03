//
//  DateViewController.swift
//  Reminders
//
//  Created by hwanghye on 7/4/24.
//

import UIKit
import SnapKit

protocol DateViewControllerDelegate: AnyObject {
    func didSelectDate(_ date: Date)
}

class DateViewController: BaseViewController {
    
    weak var delegate: DateViewControllerDelegate?
    let datePicker = UIDatePicker()
    let selectButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureHierarchy()
        configureLayout()
        configureView()
        
        selectButton.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
    }
    
    override func configureHierarchy() {
        view.addSubview(datePicker)
        view.addSubview(selectButton)
    }
    
    override func configureLayout() {
        datePicker.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
        selectButton.snp.makeConstraints { make in
            make.top.equalTo(datePicker.snp.bottom).offset(20)
            make.centerX.equalTo(view)
        }
    }
    
    override func configureView() {
        datePicker.datePickerMode = .date
        selectButton.setTitle("Select Date", for: .normal)
    }
    
    @objc func selectButtonTapped() {
        let selectedDate = datePicker.date
        delegate?.didSelectDate(selectedDate)
        navigationController?.popViewController(animated: true)
    }
}
