//
//  CashdocView.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/04/22.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RxSwift

@objc protocol CashdocViewCustomizable: AnyObject {
    @objc optional func setupView()
    @objc optional func setupProperty()
}

class CashdocView: UIView {
    
    var disposeBag: DisposeBag = .init()
    
    init() {
        super.init(frame: .zero)
        _setupView()
        _setupProperty()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func _setupView() {
        (self as CashdocViewCustomizable).setupView?()
    }
    
    private func _setupProperty() {
        (self as CashdocViewCustomizable).setupProperty?()
    }
    
}

extension CashdocView: CashdocViewCustomizable {}
