//
//  ExpandAddView.swift
//  Cashdoc
//
//  Created by Oh Sangho on 01/11/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

final class ExpandAddView: BaseCardView {
    
    // MARK: - UI Components
    
    private let plusImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icPlusGray")
    }
    private let addLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGrayCw
    }
    
    // MARK: - Con(De)structor
    
    init() {
        super.init(frame: .zero)
        
        setProperties()
        containerView.addSubview(plusImage)
        containerView.addSubview(addLabel)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal methods
    
    func configure(_ type: String) {
        addLabel.text = String(format: "%@ 추가하기", type)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        backgroundColor = .grayTwoCw
    }
    
}

// MARK: - Layout

extension ExpandAddView {
    
    private func layout() {
        addLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14).isActive = true
        addLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14).isActive = true
        addLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 10.5).isActive = true
        addLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        plusImage.centerYAnchor.constraint(equalTo: addLabel.centerYAnchor).isActive = true
        plusImage.trailingAnchor.constraint(equalTo: addLabel.leadingAnchor, constant: -6).isActive = true
        plusImage.widthAnchor.constraint(equalTo: plusImage.heightAnchor).isActive = true
        plusImage.heightAnchor.constraint(equalToConstant: 16).isActive = true
        plusImage.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }
    
}
