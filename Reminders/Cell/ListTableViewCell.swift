//
//  ListTableViewCell.swift
//  Reminders
//
//  Created by hwanghye on 7/3/24.
//

import UIKit
import SnapKit

protocol ListTableViewCellDelegate: AnyObject {
    func didToggleCheckButton(at indexPath: IndexPath)
}

class ListTableViewCell: BaseTableViewCell {
    static let id = "ListTableViewCell"
    
    weak var delegate: ListTableViewCellDelegate?
    var indexPath: IndexPath!
    
    let checkBoxButton = UIButton()
    let titleLabel = UILabel()
    let memoLabel = UILabel()
    let dateLabel = UILabel()
    
    func testUI() {
        titleLabel.text = "title label"
        memoLabel.text = "memo"
        dateLabel.text = "0000.00.00"
    }
    
    override func configureLayout() {
        checkBoxButton.snp.makeConstraints { make in
            make.leading.verticalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(16)
            make.width.equalTo(80)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.trailing.top.equalTo(contentView.safeAreaLayoutGuide).inset(16)
            make.leading.equalTo(checkBoxButton.snp.trailing).offset(8)
            make.height.equalTo(18)
        }
        
        memoLabel.snp.makeConstraints { make in
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(16)
            make.leading.equalTo(checkBoxButton.snp.trailing).offset(8)
            make.top.equalTo(titleLabel.snp.bottom)
            make.height.equalTo(18)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(16)
            make.leading.equalTo(checkBoxButton.snp.trailing).offset(8)
            make.top.equalTo(memoLabel.snp.bottom)
        }
    }
    
    override func configureHierarchy() {
        contentView.addSubview(checkBoxButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(memoLabel)
        contentView.addSubview(dateLabel)
    }
    
    override func configureView() {
        memoLabel.numberOfLines = 0
        setupCheckBoxButton()
        
        
    }
    
    func setupCheckBoxButton() {
        checkBoxButton.setImage(UIImage(systemName: "square"), for: .normal)
        checkBoxButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        
        checkBoxButton.addTarget(self, action: #selector(checkBoxToggle), for: .touchUpInside)
    }
    
    @objc func checkBoxToggle() {
        checkBoxButton.isSelected.toggle()
        if checkBoxButton.isSelected {
            print("CheckBox is checked.")
            delegate?.didToggleCheckButton(at: indexPath)
            
        }
    }
    
    func configure(with indexPath: IndexPath, delegate: ListTableViewCellDelegate) {
        self.indexPath = indexPath
        self.delegate = delegate
    }
}
