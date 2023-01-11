//
//  PropertyAddTableViewCell.swift
//  Cashdoc
//
//  Created by Oh Sangho on 01/11/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxGesture
import RxCocoa

final class PropertyAddTableViewCell: CardBaseTableViewCell {
    
    // MARK: - Properties
    
    var containerViewTapGesture: TapControlEvent {
        return containerView.rx.tapGesture()
    }
    
    // MARK: - UI Componenets
    
    private let plusImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icPlusGray")
    }
    private let addLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGrayCw
        $0.text = "내 자산 추가하기"
    }
    
    // MARK: - Con(De)structor
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        containerView.addSubview(plusImage)
        containerView.addSubview(addLabel)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Layout

extension PropertyAddTableViewCell {
    
    private func layout() {
        addLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 22).isActive = true
        addLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -22).isActive = true
        addLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 10).isActive = true
        
        plusImage.centerYAnchor.constraint(equalTo: addLabel.centerYAnchor).isActive = true
        plusImage.trailingAnchor.constraint(equalTo: addLabel.leadingAnchor, constant: -6).isActive = true
        plusImage.widthAnchor.constraint(equalTo: plusImage.heightAnchor).isActive = true
        plusImage.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
}
