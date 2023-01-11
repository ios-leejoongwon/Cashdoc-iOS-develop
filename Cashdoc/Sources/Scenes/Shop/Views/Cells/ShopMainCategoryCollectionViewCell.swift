//
//  ShopMainCategoryCollectionViewCell.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 21/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Then
import SnapKit

final class ShopMainCategoryCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    
    var category: ShopCategoryModel? {
        didSet {
            guard let category = category else {return}
            
            categoryTitleLabel.text = category.title ?? ""
            
            if let imageUrl = category.imageUrl, let url = URL(string: imageUrl) {
                categoryImageView.kf.setImage(with: url, placeholder: UIImage(named: "imgPlaceholder"), options: [.transition(.fade(0.1))])
            }
            
            if let name = category.name {
                categoryTitleLabel.text = name
            }
        }
    }
    
    // MARK: - UI Components
    
    private let categoryImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFit
    }
    private let categoryTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToBold(ofSize: 14)
        $0.textColor = .blackCw
        $0.textAlignment = .center
    }
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setProperties()
        addSubview(categoryImageView)
        addSubview(categoryTitleLabel)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UICollectionViewCell
    
    override func prepareForReuse() {
        
        categoryImageView.image = UIImage(named: "imgPlaceholder")
        categoryTitleLabel.text = nil
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.white.withAlphaComponent(0.5) : .white
        }
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        backgroundColor = .white
        clipsToBounds = true
    }
    
    // MARK: - Internal methods
    
    func configure(item: ShopCategoryModel) {
        categoryTitleLabel.text = item.title
        
        if let imageUrlStr = item.imageUrl {
            guard let url = URL(string: imageUrlStr) else {return}
            categoryImageView.kf.setImage(with: url)
        }
    }
}

// MARK: - Layout

extension ShopMainCategoryCollectionViewCell {
    
    private func layout() {
        categoryImageView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        categoryImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32).isActive = true
        let calcu = (ScreenSize.WIDTH - 76) / 3 / 100 * 58
        categoryImageView.heightAnchor.constraint(equalToConstant: calcu).isActive = true
        categoryImageView.widthAnchor.constraint(equalToConstant: calcu).isActive = true

        categoryTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        categoryTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        categoryTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        categoryTitleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
}
