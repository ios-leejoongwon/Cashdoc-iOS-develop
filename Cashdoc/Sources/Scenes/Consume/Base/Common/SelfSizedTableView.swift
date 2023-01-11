//
//  SelfSizedTableView.swift
//  Cashdoc
//
//  Created by Oh Sangho on 09/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

class SelfSizedTableView: UITableView {
    var maxHeight: CGFloat = ScreenSize.HEIGHT
    
    override func reloadData() {
        super.reloadData()
        DispatchQueue.main.async { [weak self] in
            self?.invalidateIntrinsicContentSize()
            self?.layoutIfNeeded()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        DispatchQueue.main.async { [weak self] in
            self?.setNeedsLayout()
            self?.layoutIfNeeded()
        }
        let height = min(contentSize.height, maxHeight)
        return CGSize(width: contentSize.width, height: height)
    }
    
}
