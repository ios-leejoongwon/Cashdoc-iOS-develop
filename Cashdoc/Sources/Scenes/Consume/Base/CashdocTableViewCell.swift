//
//  CashdocTableViewCell.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 17/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit
import RxSwift

@objc protocol CashdocTableViewCellCustomizable: AnyObject {
    @objc optional func setupView()
    @objc optional func setupProperty()
}

class CashdocTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    var cellDisposeBag = DisposeBag()
    
    // MARK: - Con(De)structor
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _setupView()
        _setupProperty()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UITableViewCell
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellDisposeBag = DisposeBag()
    }
    
    // MARK: - Private methods
    
    private func _setupView() {
        (self as CashdocTableViewCellCustomizable).setupView?()
    }
    
    private func _setupProperty() {
        selectionStyle = .none
        (self as CashdocTableViewCellCustomizable).setupProperty?()
    }
    
}

extension CashdocTableViewCell: CashdocTableViewCellCustomizable {}
