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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let selectedPriority: String
          if segmentedController.selectedSegmentIndex != UISegmentedControl.noSegment {
              selectedPriority = segmentedController.titleForSegment(at: segmentedController.selectedSegmentIndex) ?? ""
          } else {
              selectedPriority = ""
          }
          
          print("선택된 우선순위: \(selectedPriority)")
          delegate?.didSelectPriority(selectedPriority)
          navigationController?.popViewController(animated: true)
    }
}
