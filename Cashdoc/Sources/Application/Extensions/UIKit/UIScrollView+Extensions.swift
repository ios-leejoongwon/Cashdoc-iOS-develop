//
//  UIScrollView+Extensions.swift
//  Cashdoc
//
//  Created by Oh Sangho on 04/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

extension UIScrollView {
    
    func scrollToTop(animated: Bool) {
        setContentOffset(CGPoint(x: 0, y: -1), animated: animated)
    }
    
    func scrollToBottom(animated: Bool) {
        if self.contentSize.height < self.bounds.size.height { return }
        let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height)
        self.setContentOffset(bottomOffset, animated: animated)
    }
    
    var isBouncingBottom: Bool {
        let threshold: CGFloat
        let decimalPoint: CGFloat = 10000000
        if contentSize.height > frame.size.height {
            threshold = (contentSize.height - frame.size.height + contentInset.bottom)
        } else {
            threshold = 0
        }
        return floor(contentOffset.y * decimalPoint) > floor(threshold * decimalPoint)
    }
    
}
