//
//  ShopGoodsListTableViewCell.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 04/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Then

final class ShoppingListCell: UITableViewCell {
    
    // MARK: - UI Components
    
    private let titleImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
    }
    private let affiliteLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .warmGray
        $0.textAlignment = .left
    }
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .blackCw
        $0.textAlignment = .left
        $0.numberOfLines = 2
    }
    private let priceButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.setTitleColor(.blackTwoCw, for: .normal)
        $0.setImage(UIImage(named: "icCoinYellow"), for: .normal)
        $0.contentHorizontalAlignment = .left
        $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        $0.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
    }
    private let horizontalLine = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .lineGray
    }
    
    // MARK: - Overridden: UITableViewCell
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setProperties()
        addSubview(titleImage)
        addSubview(affiliteLabel)
        addSubview(titleLabel)
        addSubview(priceButton)
        addSubview(horizontalLine)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleImage.image = nil
        affiliteLabel.text = nil
        titleLabel.text = nil
        priceButton.setTitle("", for: .normal)
    }
    
    // MARK: - Internal methods
    
    func configuration(item: ShopItemModel, searchString: String) {
        affiliteLabel.text = item.affiliate ?? ""
        
        let price = item.price ?? 0
        priceButton.setTitle("\(price.commaValue)캐시", for: .normal)
        
        if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
            titleImage.kf.setImage(with: url, placeholder: UIImage(named: "imgPlaceholder"))
        }
        
        guard let title = item.title else {return}
        if searchString == "" {
            titleLabel.text = title
        } else {
//            let mainString = title
//            if let nsRange = mainString.lowercased().nsRange(of: searchString.lowercased()) {
//                let attribute = NSMutableAttributedString(string: mainString)
//                attribute.addAttribute(.foregroundColor, value: UIColor.coralRedCw, range: nsRange)
//                titleLabel.attributedText = attribute
//            }
        }
    }
    
    func updateShoppingListCell(best: ShopBestModel) {
        titleLabel.text = best.title ?? ""
        affiliteLabel.text = best.affiliate ?? ""
        
        if let price = best.price {
            priceButton.setTitle("\(price.commaValue)캐시", for: .normal)
        }
        if let imageUrl = best.imageUrl, let url = URL(string: imageUrl) {
            titleImage.kf.setImage(with: url, placeholder: UIImage(named: "imgPlaceholder"))
        }
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
//        fh.enable(normalColor: .white, highlightedColor: .white3)
        selectionStyle = .none
    }
}

// MARK: - Layout

extension ShoppingListCell {
    
    private func layout() {
        titleImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        titleImage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
        titleImage.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        affiliteLabel.topAnchor.constraint(equalTo: topAnchor, constant: 26).isActive = true
        affiliteLabel.leadingAnchor.constraint(equalTo: titleImage.trailingAnchor, constant: 8).isActive = true
        affiliteLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: affiliteLabel.bottomAnchor, constant: 2).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: titleImage.trailingAnchor, constant: 8).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        
        priceButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8).isActive = true
        priceButton.leadingAnchor.constraint(equalTo: titleImage.trailingAnchor, constant: 8).isActive = true
        priceButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        
        horizontalLine.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        horizontalLine.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        horizontalLine.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        horizontalLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
}
