//
//  UITableView+Extensions.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2019/12/13.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

extension UITableView {
    func CDScrollToRow(at ip: IndexPath, at position: UITableView.ScrollPosition, animated: Bool) {
        guard indexPathIsValid(with: ip) else { return }
        scrollToRow(at: ip, at: position, animated: animated)
    }
    
    private func indexPathIsValid(with ip: IndexPath) -> Bool {
        return ip.section < numberOfSections &&
            ip.row < numberOfRows(inSection: ip.section)
    }
}
