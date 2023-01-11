//
//  ManageConsumeTableViewCell.swift
//  Cashdoc
//
//  Created by Taejune Jung on 31/01/2020.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RxGesture
import RxSwift
import RxCocoa

final class ManageConsumeTableViewCell: CashdocTableViewCell {
    
    var okButtonClickEvent: Observable<UITapGestureRecognizer> {
        return linkFailedImage.rx.tapGesture().when(.recognized)
    }
    
    // MARK: - Properties
    
    private var propertyImageBottom: NSLayoutConstraint!
    private var linkedStatusLabelTrailing: NSLayoutConstraint!
    private var dates: (String, String)?
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let propertyImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let propertyName = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 14)
        $0.textColor = .blackCw
    }
    private let linkedStatusLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textAlignment = .right
        $0.textColor = .blueCw
        $0.text = "연동 성공"
    }
    private let linkFailedImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icUpdateColor")
        $0.isHidden = true
    }
    private let errorMsgWhenFailed = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGrayCw
        $0.numberOfLines = 0
    }
    
    // MARK: - Con(De)structor
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(containerView)
        containerView.addSubview(propertyImage)
        containerView.addSubview(propertyName)
        containerView.addSubview(linkedStatusLabel)
        containerView.addSubview(linkFailedImage)
        containerView.addSubview(errorMsgWhenFailed)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UITableViewCell
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        propertyImage.image = nil
        propertyName.text = nil
        linkedStatusLabel.text = nil
        errorMsgWhenFailed.text = nil
    }
    
    func configure(with info: LinkedScrapingInfo, dates: (String, String)) {
        self.dates = dates
        if let image = FCode(rawValue: info.fCodeName ?? "")?.image {
            propertyName.text = info.fCodeName
            propertyImage.image = UIImage(named: image)
        }
        checkLinkedStatus(with: info.cIsError, errorMsg: info.cErrorMsg)
    }
    
    // MARK: - Private methods
    
    private func checkLinkedStatus(with isError: Bool,
                                   errorMsg: String? = nil) {
        propertyImageBottom.isActive = false
        linkedStatusLabelTrailing.isActive = false
        if isError {
            linkedStatusLabel.text = "재연동 필요"
            linkedStatusLabel.textColor = .redCw
            linkFailedImage.isHidden = false
            errorMsgWhenFailed.text = errorMsg
            propertyImageBottom = propertyImage.bottomAnchor.constraint(equalTo: errorMsgWhenFailed.topAnchor, constant: -12)
            linkedStatusLabelTrailing = linkedStatusLabel.trailingAnchor.constraint(equalTo: linkFailedImage.leadingAnchor, constant: -4)
        } else {
            linkedStatusLabel.text = "연동 성공"
            linkedStatusLabel.textColor = .blueCw
            linkFailedImage.isHidden = true
            propertyImageBottom = propertyImage.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24)
            linkedStatusLabelTrailing = linkedStatusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24)
        }
        propertyImageBottom.isActive = true
        linkedStatusLabelTrailing.isActive = true
    }
    
}

// MARK: - Layout

extension ManageConsumeTableViewCell {
    private func layout() {
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        propertyImage.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24).isActive = true
        propertyImageBottom = propertyImage.bottomAnchor.constraint(equalTo: errorMsgWhenFailed.topAnchor, constant: -24)
        propertyImageBottom.isActive = true
        propertyImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24).isActive = true
        propertyImage.widthAnchor.constraint(equalToConstant: 24).isActive = true
        propertyImage.heightAnchor.constraint(equalTo: propertyImage.widthAnchor).isActive = true
        
        propertyName.centerYAnchor.constraint(equalTo: propertyImage.centerYAnchor).isActive = true
        propertyName.leadingAnchor.constraint(equalTo: propertyImage.trailingAnchor, constant: 8).isActive = true
        
        linkFailedImage.centerYAnchor.constraint(equalTo: propertyImage.centerYAnchor).isActive = true
        linkFailedImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24).isActive = true
        linkFailedImage.widthAnchor.constraint(equalToConstant: 24).isActive = true
        linkFailedImage.heightAnchor.constraint(equalTo: linkFailedImage.widthAnchor).isActive = true
        
        linkedStatusLabel.centerYAnchor.constraint(equalTo: propertyImage.centerYAnchor).isActive = true
        linkedStatusLabelTrailing = linkedStatusLabel.trailingAnchor.constraint(equalTo: linkFailedImage.leadingAnchor, constant: -24)
        linkedStatusLabelTrailing.isActive = true
        
        errorMsgWhenFailed.leadingAnchor.constraint(equalTo: propertyImage.leadingAnchor).isActive = true
        errorMsgWhenFailed.trailingAnchor.constraint(equalTo: linkFailedImage.trailingAnchor).isActive = true
        errorMsgWhenFailed.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24).isActive = true
    }
}
