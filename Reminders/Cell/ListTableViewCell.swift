//
//  ListTableViewCell.swift
//  Reminders
//
//  Created by hwanghye on 7/3/24.
//

import UIKit
import SnapKit

protocol ListTableViewCellDelegate: AnyObject {
    func didToggleCheckBox(at indexPath: IndexPath, isCompleted: Bool)
}

class ListTableViewCell: BaseTableViewCell {
    static let id = "ListTableViewCell"
    
    var indexPath: IndexPath!
    weak var delegate: ListTableViewCellDelegate?
    
    let checkBoxButton = UIButton()
    let photoImage = UIImageView()
    let titleLabel = UILabel()
    let memoLabel = UILabel()
    let dateLabel = UILabel()
    let tagLabel = UILabel()
    
    var deleteAction: (() -> Void)?
    
    let priorityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    override func configureHierarchy() {
        contentView.addSubview(checkBoxButton)
        contentView.addSubview(photoImage)
        contentView.addSubview(titleLabel)
        contentView.addSubview(memoLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(tagLabel)
        contentView.addSubview(priorityLabel)
    }
    
    override func configureLayout() {
        checkBoxButton.snp.makeConstraints { make in
            make.leading.verticalEdges.equalTo(contentView.safeAreaLayoutGuide)
            make.width.equalTo(80)
        }
        
        photoImage.snp.makeConstraints { make in
            make.leading.equalTo(checkBoxButton.snp.trailing)
            make.verticalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(16)
            make.width.equalTo(100)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(16)
            make.leading.equalTo(photoImage.snp.trailing).offset(8)
            make.height.equalTo(18)
        }
        
        priorityLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).inset(16)
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
           }
        
        memoLabel.snp.makeConstraints { make in
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(16)
            make.leading.equalTo(photoImage.snp.trailing).offset(8)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.height.equalTo(18)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(16)
            make.leading.equalTo(photoImage.snp.trailing).offset(8)
            make.top.equalTo(memoLabel.snp.bottom).offset(8)
        }
        
        tagLabel.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(16)
            make.leading.equalTo(photoImage.snp.trailing).offset(8)
            make.top.equalTo(dateLabel.snp.bottom)
        }
    }
    
    override func configureView() {
        contentView.backgroundColor = .backgroundGray
        titleLabel.textColor = .white
        memoLabel.textColor = .white
        dateLabel.textColor = .white
        tagLabel.textColor = .white
        memoLabel.numberOfLines = 0
        
        setupCheckBoxButton()
    }
    
    func setupCheckBoxButton() {
        checkBoxButton.setImage(UIImage(systemName: "circle"), for: .normal)
        checkBoxButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        checkBoxButton.addTarget(self, action: #selector(checkBoxToggle), for: .touchUpInside)
    }
    
    @objc func checkBoxToggle() {
        checkBoxButton.isSelected.toggle()
        if delegate != nil {
            delegate!.didToggleCheckBox(at: indexPath, isCompleted: checkBoxButton.isSelected)
        } else {
            print("Delegate is nil")
        }
    }
}
