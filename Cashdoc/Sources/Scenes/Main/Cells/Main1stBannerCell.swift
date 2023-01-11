//
//  Main1stBannerCell.swift
//  Cashdoc
//
//  Created by bzjoowan on 2021/04/19.
//  Copyright © 2021 Cashwalk. All rights reserved.
//

import UIKit

class Main1stBannerCell: UICollectionViewCell {
    @IBOutlet weak var bannerTitleLabel: UILabel!
    @IBOutlet weak var bannerDescLabel: UILabel!
    @IBOutlet weak var bannerImageView: UIImageView!
    
    func drawCell(_ model: LottoBannerModel) {
        bannerImageView.kf.setImage(with: URL(string: model.imageUrl)) 
    }
}
