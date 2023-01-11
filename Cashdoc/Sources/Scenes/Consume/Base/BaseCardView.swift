//
//  BaseCardView.swift
//  Cashdoc
//
//  Created by Oh Sangho on 11/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit
import RxGesture

class BaseCardView: UIView {
    
    // MARK: - Properties
    
    var tapGesture: TapControlEvent {
        return containerView.rx.tapGesture()
    }
    
    // MARK: - UI Components
    
    let containerView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.clipsToBounds = true
    }
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(containerView)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout

extension BaseCardView {
    
    private func layout() {
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func setActiveLayoutWithPriority(_ constraint: NSLayoutConstraint) {
        constraint.priority = .init(999)
        constraint.isActive = true
    }
    
}
