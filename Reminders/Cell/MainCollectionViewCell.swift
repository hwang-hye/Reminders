//
//  MainCollectionViewCell.swift
//  Reminders
//
//  Created by hwanghye on 7/5/24.
//

import UIKit
import SnapKit

class MainCollectionViewCell: BaseCollectionViewCell {
    static let id = "MainCollectionViewCell"
    
    let cellView = UIView()
    let cellIcon = UIImageView()
    let statusLabel = UILabel()
    let countLabel = UILabel()
    
    override func configureHierarchy() {
        contentView.addSubview(cellView)
        cellView.addSubview(cellIcon)
        cellView.addSubview(statusLabel)
        cellView.addSubview(countLabel)
    }
    
    override func configureLayout() {
        cellView.snp.makeConstraints { make in
            make.edges.equalTo(contentView.safeAreaLayoutGuide)
        }
        cellIcon.snp.makeConstraints { make in
            make.top.leading.equalTo(contentView.safeAreaLayoutGuide).inset(8)
            make.height.width.equalTo(36)
        }
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(cellIcon.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(12)
            make.height.equalTo(14)
        }
        countLabel.snp.makeConstraints { make in
            make.top.equalTo(cellIcon.snp.top)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(8)
            make.height.equalTo(36)
        }
        
    }
    override func configureView() {
        cellView.backgroundColor = .white.withAlphaComponent(0.12)
        cellView.layer.cornerRadius = 12
        statusLabel.text = "text"
        statusLabel.textColor = .gray
        statusLabel.font = .systemFont(ofSize: 14, weight: .regular)
        countLabel.text = "0"
        countLabel.textAlignment = .right
        countLabel.textColor = .white
        countLabel.font = .systemFont(ofSize: 32, weight: .bold)
    }
}
