//
//  InsuranAccountResultVC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/19.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Foundation

class InsuranAccountResultVC: CashdocViewController {
    @IBOutlet weak var accountEmailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let getEmail = GlobalDefine.shared.saveInsuranJoinParam["EMAIL"] ?? ""
        accountEmailLabel.attributedText = GlobalFunction.stringToAttriColor("입력하신 메일\n\(getEmail)에서\n확인 가능합니다.", wantText: getEmail, textColor: UIColor.blueCw, lineHeight: 24)
    }
    
    @IBAction func gotoLogin() {
        GlobalDefine.shared.saveInsuranJoinParam = [String: String]() // clear
        
        GlobalFunction.CDPopToRootViewController(animated: false)
        HealthNavigator.pushInsuranceLoginStoryboard(identi: InsuranceLoginVC.reuseIdentifier)
    }
    
    @IBAction func gotoRetry() {
        GlobalDefine.shared.saveInsuranJoinParam = [String: String]() // clear
        GlobalFunction.CDPoptoViewController(InsuranFindSegVC.self, animated: false)
    }
}
