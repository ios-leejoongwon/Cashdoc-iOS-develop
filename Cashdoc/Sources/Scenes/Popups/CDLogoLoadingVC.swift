//
//  CDLogoLoadingVC.swift
//  Cashdoc
//
//  Created by 이아림 on 2022/07/20.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import Foundation
import Lottie
 
class CDLogoLoadingVC: CashdocViewController {
    
    private let loadingAnimaion = LottieAnimationView(name: "cashdoc_loading").then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.loopMode = .loop
        $0.contentMode = .scaleAspectFill
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingAnimaion.play()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        loadingAnimaion.stop()
    }
    
    func setupView() {
        view.backgroundColor = .blackAlphaCw
        view.addSubview(loadingAnimaion)
        loadingAnimaion.snp.makeConstraints { m in
            m.width.height.equalTo(64)
            m.center.equalToSuperview()
        }
    }
    
}
