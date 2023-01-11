//
//  File.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 04/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

final class ShopAffiliateCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var affiliate: ShopCategoryModel? {
        didSet {
            guard let affiliate = affiliate else {return}
            
            titleLabel.text = affiliate.title ?? ""
            if let imageUrl = affiliate.imageUrl, let url = URL(string: imageUrl) {
                imageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.1))])
            }
        }
    }
    
    // MARK: - UI Components
    
    private let shadowView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.layer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
        $0.layer.shadowOffset = CGSize(width: 2, height: 2)
        $0.layer.shadowRadius = 3.0
        $0.layer.shadowOpacity = 0.2
        $0.layer.cornerRadius = 50/2
        $0.layer.masksToBounds = false
    }
    private let imageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 50/2
        $0.clipsToBounds = true
    }
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .blackTwoCw
        $0.textAlignment = .center
    }
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setProperties()
        addSubview(shadowView)
        addSubview(titleLabel)
        shadowView.addSubview(imageView)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UICollectionViewCell
    
    override func prepareForReuse() {
        titleLabel.text = nil
        imageView.image = nil
    }
    
    // MARK: - Properties
    
    private func setProperties() {
        backgroundColor = .clear
    }
}

// MARK: - Layout

extension ShopAffiliateCell {
    
    private func layout() {
        shadowView.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        shadowView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        shadowView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        shadowView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        imageView.topAnchor.constraint(equalTo: shadowView.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: shadowView.bottomAnchor, constant: 8).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4).isActive = true
    }
}
