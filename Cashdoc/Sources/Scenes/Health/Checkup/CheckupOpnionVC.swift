//
//  CheckupOpnionVC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/05/25.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation

class CheckupOpnionVC: CashdocViewController {
    @IBOutlet weak var hospitalLabel: UILabel!
    @IBOutlet weak var checkDateLabel: UILabel!
    @IBOutlet weak var opinionTextView: UITextView!
    var getModel = CheckupIncomeModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "의사 소견"
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icShareBlack"), style: .done, target: self, action: #selector(shareAct))
        
        hospitalLabel.text = "일반검진-\(getModel.CHECKUPORGAN)"
        checkDateLabel.text = "검진일자 : \(getModel.CHECKUPDATE.convertDateFormat(beforeFormat: "yyyyMMdd", afterFormat: "yyyy.MM.dd"))"
        opinionTextView.text = getModel.CHECKUPOPINION
    }
    
    @objc func shareAct() {
        
    }
}
