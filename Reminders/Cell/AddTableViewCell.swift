//
//  AddTableViewCell.swift
//  Reminders
//
//  Created by hwanghye on 7/6/24.
//

import UIKit
import SnapKit

class AddTableViewCell: BaseTableViewCell {
    static let id = "AddTableViewCell"
    
    let cellBackgroundView = UIView()
    let menuTitleLabel = UILabel()
    let menuIcon = UIImageView()
    
    override func configureHierarchy() {
        contentView.addSubview(cellBackgroundView)
        cellBackgroundView.addSubview(menuTitleLabel)
        cellBackgroundView.addSubview(menuIcon)
    }
    
    override func configureLayout() {
        cellBackgroundView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide)
            make.height.equalTo(44)
        }
        menuTitleLabel.snp.makeConstraints { make in
            make.leading.verticalEdges.equalTo(cellBackgroundView.safeAreaLayoutGuide).inset(14)
            make.height.equalTo(14)
        }
        menuIcon.snp.makeConstraints { make in
            make.trailing.verticalEdges.equalTo(cellBackgroundView.safeAreaLayoutGuide).inset(14)
            make.height.equalTo(14)
        }
    }
    override func configureView() {
        cellBackgroundView.backgroundColor = .white.withAlphaComponent(0.2)
        cellBackgroundView.layer.cornerRadius = 10
//        menuTitleLabel.backgroundColor = .blue
//        menuIconLabel.backgroundColor = .blue
        
        menuTitleLabel.text = "메뉴"
        menuIcon.image = UIImage(systemName: "chevron.right")
    }
}
