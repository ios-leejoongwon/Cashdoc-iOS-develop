//
//  CheckupFooterView.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/05/28.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation

class CheckupFooterView: UIView {
    @IBOutlet weak var videoLabel: UILabel!
    
    func changeVideoString(_ ment: String) {
        if ment.isEmpty {
            videoLabel.text = "없음"
        } else {
            videoLabel.text = ment
        }
    }
}
