//
//  HealthCardCollectionViewCell.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/11/27.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

final class HealthCardCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private var titleName: String?
    // MARK: - UI Components
    
    private let cornerMaskView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowRadius = 6
        $0.layer.shadowOpacity = 0.2
        $0.layer.cornerRadius = 4
        $0.backgroundColor = .white
        $0.layer.shadowOffset = CGSize(width: -1, height: 1)
    }
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 18)
        $0.textColor = .brownGrayCw
        $0.setLineHeight(lineHeight: 26)
        $0.numberOfLines = 3
    }
    
    private let tagLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .brownishGray
        $0.setLineHeight(lineHeight: 22)
        $0.numberOfLines = 3
    }
    
    let rightSideImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let footerLeftLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .brownishGrayCw
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 11
        $0.backgroundColor = UIColor.grayTwoCw
    }
    private let footerLeftImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icSpendYellow")
    }
    private let footerLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .brownGrayCw
    }
    let indicatorView = UIActivityIndicatorView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.hidesWhenStopped = true
        $0.style = .gray
    }
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(cornerMaskView)
        self.addSubview(titleLabel)
        self.addSubview(tagLabel)
        self.addSubview(rightSideImage)
        self.addSubview(footerLabel)
        self.addSubview(footerLeftLabel)
        self.addSubview(footerLeftImage)
        self.addSubview(indicatorView)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal methods
    
    func configure(with healthType: HealthCardType) {
        let makeHealthModel = HealthCardCollectionViewModel(healthType)
        titleLabel.attributedText = makeHealthModel.titleAttribute
        tagLabel.text = makeHealthModel.tagString
        rightSideImage.image = makeHealthModel.rightImage
        footerLabel.attributedText = makeHealthModel.footerAttribute
        footerLeftLabel.text = makeHealthModel.footerLeftString
        footerLeftImage.isHidden = makeHealthModel.footerLeftImageHidden
    }
    // MARK: - Private methods
}

// MARK: - Layout

extension HealthCardCollectionViewCell {
    private func layout() {
        cornerMaskView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        cornerMaskView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        cornerMaskView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        cornerMaskView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: cornerMaskView.topAnchor, constant: 24).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: cornerMaskView.leadingAnchor, constant: 71).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: cornerMaskView.trailingAnchor, constant: 15).isActive = true
        
        tagLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6).isActive = true
        tagLabel.leadingAnchor.constraint(equalTo: cornerMaskView.leadingAnchor, constant: 71).isActive = true
        tagLabel.trailingAnchor.constraint(equalTo: cornerMaskView.trailingAnchor, constant: 15).isActive = true
        
        rightSideImage.topAnchor.constraint(equalTo: cornerMaskView.topAnchor, constant: 32).isActive = true
        rightSideImage.leadingAnchor.constraint(equalTo: cornerMaskView.leadingAnchor, constant: 24).isActive = true
        
        footerLabel.bottomAnchor.constraint(equalTo: cornerMaskView.bottomAnchor, constant: -27).isActive = true
        footerLabel.trailingAnchor.constraint(equalTo: cornerMaskView.trailingAnchor, constant: -26).isActive = true
        
        footerLeftLabel.bottomAnchor.constraint(equalTo: cornerMaskView.bottomAnchor, constant: -24).isActive = true
        footerLeftLabel.leadingAnchor.constraint(equalTo: cornerMaskView.leadingAnchor, constant: 71).isActive = true
        footerLeftLabel.trailingAnchor.constraint(lessThanOrEqualTo: cornerMaskView.trailingAnchor, constant: -15).isActive = true
        footerLeftLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        footerLeftImage.leadingAnchor.constraint(equalTo: cornerMaskView.leadingAnchor, constant: 80).isActive = true
        footerLeftImage.bottomAnchor.constraint(equalTo: cornerMaskView.bottomAnchor, constant: -27).isActive = true
        footerLeftImage.widthAnchor.constraint(equalToConstant: 16).isActive = true
        footerLeftImage.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        indicatorView.topAnchor.constraint(equalTo: cornerMaskView.topAnchor, constant: 32).isActive = true
        indicatorView.leadingAnchor.constraint(equalTo: cornerMaskView.leadingAnchor, constant: 24).isActive = true
        indicatorView.widthAnchor.constraint(equalToConstant: 26).isActive = true
        indicatorView.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }
}
