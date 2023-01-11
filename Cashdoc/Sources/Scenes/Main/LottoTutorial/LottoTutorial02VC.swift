//
//  LottoTutorial02VC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/09/29.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation

class LottoTutorial02VC: CashdocViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        GlobalFunction.FirLog(string: "튜토리얼_2단계_진입_iOS")
    }
    
    @IBAction func nextAct() {
        if let viewcon = UIStoryboard.init(name: "LottoTutorial", bundle: nil).instantiateViewController(withIdentifier: "LottoTutorial03VC") as? LottoTutorial03VC {
            GlobalDefine.shared.curNav?.addChild(viewcon)
            GlobalDefine.shared.curNav?.view.addSubview(viewcon.view)
        }
        
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}
