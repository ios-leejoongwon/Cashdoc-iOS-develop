//
//  LottoTutorial01VC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/09/29.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation
import Lottie

class LottoTutorial01VC: CashdocViewController {
    @IBOutlet weak var treasureBox: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var lottoMachinButton: UIView!
     
    override func viewDidLoad() {
        super.viewDidLoad()
        #if !DEBUG
        skipButton.isHidden = true
        #endif
        
        UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsLottoTutorial.rawValue)
        GlobalFunction.FirLog(string: "튜토리얼_1단계_진입_iOS")
    }
    
    private func setupView() {
        _ = LottoMachinButton().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isHidden = false
            $0.badgeLabel.isHidden = true
            $0.clipsToBounds = true
            $0.contentMode = .scaleAspectFill
            $0.addTarget(self, action: #selector(self.nextAct), for: .touchUpInside)
            lottoMachinButton.addSubview($0)
            $0.snp.makeConstraints { m in
                m.width.equalTo(60)
                m.height.equalTo(111)
                m.right.equalTo(self.treasureBox.snp.right)
                m.bottom.equalTo(self.treasureBox.snp.bottom)
            }
        }
    }
    
    @objc func nextAct() {
        if let viewcon = UIStoryboard.init(name: "LottoTutorial", bundle: nil).instantiateViewController(withIdentifier: "LottoTutorial02VC") as? LottoTutorial02VC {
            GlobalDefine.shared.curNav?.addChild(viewcon)
            GlobalDefine.shared.curNav?.view.addSubview(viewcon.view)
        }
        
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
      
    @IBAction func clickTrasure(_ sender: UIButton) {
        sender.isEnabled = false
        self.nextAct()
    }
    
    @IBAction func skipAct() {
        GlobalDefine.shared.mainHome?.requestRefresh()
 
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}
