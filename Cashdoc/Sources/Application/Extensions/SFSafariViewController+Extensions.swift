//
//  SFSafariViewController+Extensions.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 17/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import SafariServices

extension SFSafariViewController {
    func setTintColor() {
        if #available(iOS 10.0, *) {
            preferredBarTintColor = .yellowCw
            preferredControlTintColor = .darkBrown
        }
    }
}
