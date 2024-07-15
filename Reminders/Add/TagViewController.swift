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
    
    let viewModel = TagViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        setupUI()
    }
    
    private func setupBindings() {
        viewModel.tag.bind { [weak self] newTag in
            self?.tagTextField.text = newTag
        }
        viewModel.error.bind { [weak self] error in
            if let error = error {
                self?.showError(error)
            }
        }
        
        tagTextField.addTarget(self, action: #selector(tagTextFieldDidChange), for: .editingChanged)
    }
    
    @objc func tagTextFieldDidChange() {
        viewModel.updateTag(tagTextField.text ?? "")
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
    }
    
    private func setupUI() {
        let backButton = UIBarButtonItem(title: "새로운 할 일", style: .plain, target: self, action: #selector(backButtonClicked))
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func showError(_ error: String) {
        let alert = UIAlertController(title: "오류", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func backButtonClicked() {
        //delegate?.didSelectTag(tagTextField.text ?? "")
        if let text = tagTextField.text, !text.isEmpty {
            delegate?.didSelectTag(text)
        }
        navigationController?.popViewController(animated: true)
    }
}
