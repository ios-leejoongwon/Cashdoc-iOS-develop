//
//  InsuranceLogin01VC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/02.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Foundation
import SwiftyJSON

final class InsuranceLoginInitVC: CashdocViewController {
    @IBOutlet weak var nameServiceLabel: UILabel!
    @IBOutlet weak var alreadyJoinButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bindView()
    }
    
    func bindView() {
        UserManager.shared.user
            .bind { [weak self] (user) in
                guard let self = self else {return}
                self.nameServiceLabel.text = "\(user.nickname)님의 보험을 모아보기 위해\n내보험다보여 서비스 가입이 필요합니다."
                self.nameServiceLabel.setLineHeight(lineHeight: 20)
        }
        .disposed(by: disposeBag)
        
        alreadyJoinButton.setTitleUnderLine()
    }
    
    @IBAction func joinInsuranceAct(sender: UIButton) {
        GlobalFunction.pushVC(InsuranceTermVC(), animated: true)
    }
    
    @IBAction func loginInsuranceAct(sender: UIButton) {
        HealthNavigator.pushInsuranceLoginStoryboard(identi: InsuranceLoginVC.reuseIdentifier)
    }
}
