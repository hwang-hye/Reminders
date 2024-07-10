//
//  PriorityViewController.swift
//  Reminders
//
//  Created by hwanghye on 7/7/24.
//

import UIKit
import SnapKit


protocol PriorityViewControllerDelegate: AnyObject {
    func didSelectPriority(_ priority: String)
}

class PriorityViewController: BaseViewController {
    
    let segmentedController: UISegmentedControl = {
        let control = UISegmentedControl(items: ["높음", "보통", "낮음"])
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    weak var delegate: PriorityViewControllerDelegate?
    
    let viewModel = PriorityViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindData()
    }
    
    func bindData() {
        viewModel.outputPriorityTag.bind { [weak self] priorityString in
            switch priorityString {
            case "높음":
                self?.segmentedController.selectedSegmentIndex = 0
            case "보통":
                self?.segmentedController.selectedSegmentIndex = 1
            case "낮음":
                self?.segmentedController.selectedSegmentIndex = 2
            default:
                self?.segmentedController.selectedSegmentIndex = UISegmentedControl.noSegment
            }
        }
    }
    
    override func configureHierarchy() {
        view.addSubview(segmentedController)
    }
    override func configureLayout() {
        segmentedController.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(50)
        }
    }
    override func configureView() {
        view.backgroundColor = .backgroundGray
        
        let backButton = UIBarButtonItem(title: "새로운 할 일", style: .plain, target: self, action: #selector(backButtonClicked))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func backButtonClicked() {
        if segmentedController.selectedSegmentIndex != UISegmentedControl.noSegment {
            let selectedPriority = Priority(rawValue: segmentedController.selectedSegmentIndex) ?? .medium
            viewModel.inputPriorityTag.value = selectedPriority
            
            let selectedPriorityString = selectedPriority.description
            
            print("선택된 우선순위: \(selectedPriorityString)")
            delegate?.didSelectPriority(selectedPriorityString)
        } else {
            print("우선순위가 선택되지 않음")
            delegate?.didSelectPriority("")
        }
        
        navigationController?.popViewController(animated: true)
        
    }
}
