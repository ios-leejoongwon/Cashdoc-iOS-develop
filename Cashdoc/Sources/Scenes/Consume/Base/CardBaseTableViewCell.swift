//
//  CardBaseTableViewCell.swift
//  Cashdoc
//
//  Created by Oh Sangho on 25/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit
import RxSwift

class CardBaseTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    var disposeBag = DisposeBag()
    
    // MARK: - UI Componenets
    
    let containerView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 4
        $0.backgroundColor = .white
        $0.clipsToBounds = true
    }
    private let cornerMaskView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowRadius = 6
        $0.layer.shadowOpacity = 0.2
        $0.layer.shadowOffset = CGSize(width: -1, height: 1)
    }
    
    // MARK: - Con(De)structor
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setProperties()
        contentView.addSubview(cornerMaskView)
        cornerMaskView.addSubview(containerView)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UITableViewCell
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
    // MARK: - Internal methods
    
    func transitionAnimation(subtype: CATransitionSubtype) -> CATransition {
        let transition = CATransition()
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .push
        transition.subtype = subtype
        transition.duration = 0.3
        return transition
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        selectionStyle = .none
        backgroundColor = .clear
    }
    
}

// MARK: - Layout

extension CardBaseTableViewCell {
    
    private func layout() {
        cornerMaskView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        cornerMaskView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        cornerMaskView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        cornerMaskView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        
        containerView.topAnchor.constraint(equalTo: cornerMaskView.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: cornerMaskView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: cornerMaskView.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: cornerMaskView.bottomAnchor).isActive = true
    }
    
}
