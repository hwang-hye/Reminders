//
//  TagViewController.swift
//  Reminders
//
//  Created by hwanghye on 7/7/24.
//

import UIKit
import SnapKit

protocol TagViewControllerDelegate: AnyObject {
    func didSelectTag(_ tag: String)
}

class TagViewController: BaseViewController {
    
    let tagTextField = UITextField()
    weak var delegate: TagViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    override func configureHierarchy() {
        view.addSubview(tagTextField)
    }
    override func configureLayout() {
        tagTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(44)
        }
    }
    override func configureView() {
        view.backgroundColor = .backgroundGray
        tagTextField.backgroundColor = .darkGray.withAlphaComponent(0.3)
        tagTextField.textColor = .white
        tagTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        tagTextField.leftViewMode = .always
        tagTextField.layer.cornerRadius = 10
        
        let backButton = UIBarButtonItem(title: "새로운 할 일", style: .plain, target: self, action: #selector(backButtonClicked))
        navigationItem.leftBarButtonItem = backButton
        
    }
    
    @objc func backButtonClicked() {
        delegate?.didSelectTag(tagTextField.text ?? "")
        navigationController?.popViewController(animated: true)
    }
}
