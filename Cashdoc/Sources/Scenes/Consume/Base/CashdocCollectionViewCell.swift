//
//  CashdocCollectionViewCell.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/06/08.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import UIKit
import RxSwift

@objc protocol CashdocCollectionViewCellCustomizable: AnyObject {
    @objc optional func setupView()
    @objc optional func setupProperty()
}

class CashdocCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var cellDisposeBag = DisposeBag()
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        (self as CashdocCollectionViewCellCustomizable).setupView?()
    }
    
    private func _setupProperty() {
        (self as CashdocCollectionViewCellCustomizable).setupProperty?()
    }
    
}

extension CashdocCollectionViewCell: CashdocCollectionViewCellCustomizable {}
