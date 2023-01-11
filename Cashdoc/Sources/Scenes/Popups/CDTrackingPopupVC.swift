//
//  CDTrackingPopupVC.swift
//  Cashdoc
//
//  Created by bzjoowan on 2021/05/04.
//  Copyright © 2021 Cashwalk. All rights reserved.
//

import Foundation
import AppTrackingTransparency

class CDTrackingPopupVC: CashdocViewController {
    @IBOutlet weak var setupView: UIView!
    @IBOutlet weak var confirmBtn: UIButton!
    
    var firstType = true
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "맞춤 정보 제공"

        setupView.isHidden = firstType
        confirmBtn.setTitle(firstType ? "다음" : "설정하러 가기", for: .normal)
    }
    
    @IBAction func confirmAct(_ sender: UIButton) {
        if firstType {
            requestPermission()
        } else {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
    }
    
    func requestPermission() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { _ in
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                    GlobalDefine.shared.mainSeg?.gotoLottoTutorial()
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
