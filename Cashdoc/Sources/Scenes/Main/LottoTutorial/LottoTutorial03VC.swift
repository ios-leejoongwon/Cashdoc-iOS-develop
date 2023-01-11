//
//  LottoTutorial03VC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/09/29.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation

class LottoTutorial03VC: CashdocViewController { 
    override func viewDidLoad() {
        super.viewDidLoad() 
        GlobalFunction.FirLog(string: "튜토리얼_3단계_진입_iOS")
        self.view.layoutIfNeeded()
    }

    @IBAction func nextAct() {
        GlobalDefine.shared.mainHome?.requestRefresh()
 
        GlobalFunction.FirLog(string: "만보기_연동완료")
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}
