//
//  CDLoadingVC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/01/30.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation

enum LoadingType {
    case normal
    case long
}

class CDLoadingVC: CashdocViewController {
    @IBOutlet weak var loadingCoinImage: UIImageView!
    @IBOutlet weak var longPopupView: UIView!
    @IBOutlet weak var longTextGifImage: UIImageView!
    @IBOutlet weak var longCoinImage: UIImageView!
    
    var getLoadingType: LoadingType = .normal
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var imageArray = [UIImage]()
        for i in 1...8 {
            if let image = UIImage(named: String(format: "cash_%d.png", i)) {
                imageArray.append(image)
            }
        }
        
        if getLoadingType == .normal {
            longPopupView.isHidden = true
            loadingCoinImage.animationImages = imageArray
            loadingCoinImage.animationDuration = 0.7
            DispatchQueue.main.async { [weak self] in
                self?.loadingCoinImage.startAnimating()
            }
        } else {
            longPopupView.isHidden = false
            longCoinImage.animationImages = imageArray
            longCoinImage.animationDuration = 0.7
            DispatchQueue.main.async { [weak self] in
                self?.loadingCoinImage.startAnimating()
                self?.longTextGifImage.loadGif(name: "loading_text")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        DispatchQueue.main.async { [weak self] in
//            self?.loadingCoinImage.stopAnimating()
//            self?.longCoinImage.stopAnimating()
//        }
    }
}
