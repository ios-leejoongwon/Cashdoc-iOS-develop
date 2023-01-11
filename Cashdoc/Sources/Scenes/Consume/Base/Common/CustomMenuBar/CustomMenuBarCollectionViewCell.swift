//
//  CustomMenuBarCollectionViewCell.swift
//  Cashdoc
//
//  Created by Oh Sangho on 21/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

final class CustomMenuBarCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let menuTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 14)
        $0.textColor = .brownishGrayCw
        $0.textAlignment = .center
    }
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setProperties()
        contentView.addSubview(menuTitleLabel)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UICollectionViewCell
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        menuTitleLabel.text = nil
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                menuTitleLabel.textColor = .blackCw
            } else {
                menuTitleLabel.textColor = .brownishGrayCw
            }
        }
    }
    
    // MARK: - Internal methods
    
    func configure(with menu: String) {
        menuTitleLabel.text = menu
    }
    
    // MARK: - Private metdhos
    
    private func setProperties() {
        contentView.backgroundColor = .white
    }
}

// MARK: - Layout

extension CustomMenuBarCollectionViewCell {
    private func layout() {
        menuTitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        menuTitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
}
