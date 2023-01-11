//
//  ShopMainBestCollectionViewCell.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 20/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit
import Then

final class ShopMainBestCollectionViewCell: UICollectionViewCell {
    
    // MARK: - NSLayoutConstraints
    
    private var titleImageWidth: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var bestItem: ShopItemModel? {
        didSet {
            guard let bestItem = bestItem else {return}
            
            let price = bestItem.price ?? 0
            cashLabel.text = "\(price.commaValue)캐시"
            
            if let imageUrl = bestItem.imageUrl, let url = URL(string: imageUrl) {
                titleImage.kf.setImage(with: url, placeholder: UIImage(named: "imgPlaceholder"))
            }
        }
    }
    
    // MARK: - UI Components
    
    private let titleImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 80/2
        $0.clipsToBounds = true
    }
//    private let titleLabel = UILabel().then {
//        $0.translatesAutoresizingMaskIntoConstraints = false
//        $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
//        $0.textColor = .blackCw
//        $0.textAlignment = .center
//    }
    private let cashLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 13)
        $0.textColor = .brownishGrayCw
        $0.textAlignment = .center
    }
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setProperties()
        addSubview(titleImage)
//        addSubview(titleLabel)
        addSubview(cashLabel)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Overridden: UICollectionViewCell
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cashLabel.text = nil
        titleImage.image = nil
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        backgroundColor = .clear
    }
    
    // MARK: - Internal methods
    
    func updateShoppingBestCVCell(best: ShopBestModel) {
//        if let title = best.title {
//            titleLabel.text = title
//        }
        if let price = best.price {
            cashLabel.text = "\(price.commaValue)캐시"
        }
        if let imageUrl = best.imageUrl, let url = URL(string: imageUrl) {
            titleImage.kf.setImage(with: url, placeholder: UIImage(named: "imgPlaceholder"))
        }
        
        titleImageWidth.constant = 100
        titleImage.layer.cornerRadius = 100/2
    }

    func configure(item: ShopBestModel) {
//        titleLabel.text = item.title
        cashLabel.text = "\((item.price ?? 0).commaValue)캐시"
        
        if let imageUrlStr = item.imageUrl {
            guard let url = URL(string: imageUrlStr) else {return}
            titleImage.kf.setImage(with: url)
        }
    }
}

// MARK: - Layout

extension ShopMainBestCollectionViewCell {
    
    private func layout() {
        titleImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        titleImage.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleImageWidth = titleImage.widthAnchor.constraint(equalToConstant: 80)
        titleImageWidth.isActive = true
        titleImage.heightAnchor.constraint(equalTo: titleImage.widthAnchor).isActive = true
        
//        titleLabel.topAnchor.constraint(equalTo: titleImage.bottomAnchor, constant: 8).isActive = true
//        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
//        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        cashLabel.topAnchor.constraint(equalTo: titleImage.bottomAnchor, constant: 6).isActive = true
        cashLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        cashLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
}
