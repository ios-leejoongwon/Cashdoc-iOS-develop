//
//  NetworkExceptionContentView.swift
//  Cashdoc
//
//  Created by DongHeeKang on 19/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit

final class NetworkExceptionContentView: UIView {
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "imgCautionBig")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Con(De)structor
    
    init() {
        super.init(frame: .zero)
        
        setProperties()
        addSubview(containerView)
        containerView.addSubview(imageView)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        backgroundColor = .clear
    }
    
}

// MARK: - Layout

extension NetworkExceptionContentView {
    
    private func layout() {
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        imageView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
    
}
