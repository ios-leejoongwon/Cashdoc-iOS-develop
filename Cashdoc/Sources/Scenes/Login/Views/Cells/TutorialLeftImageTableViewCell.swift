//
//  TutorialLeftImageTableViewCell.swift
//  Cashdoc
//
//  Created by Oh Sangho on 30/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

final class TutorialLeftImageTableViewCell: CashdocTableViewCell {
    
    // MARK: - Properties
    
    private var tutorialImageWidth: NSLayoutConstraint!
    private var tutorialImageHeight: NSLayoutConstraint!
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let tutorialImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
    }
    
    // MARK: - Con(De)structor
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setProperties()
        contentView.addSubview(containerView)
        containerView.addSubview(tutorialImage)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        tutorialImage.image = nil
    }
    
    // MARK: - Internal methods
    
    func configure(with item: [String]) {
        if item.count > 1,
            let hot = item.first,
            let ice = item.last {
            let month = getMonthForGift()
            if TutorialGiftType.Ice.months.contains(month) {
                tutorialImage.image = UIImage(named: ice)
            } else {
                tutorialImage.image = UIImage(named: hot)
            }
            tutorialImageWidth.constant = 197
            tutorialImageHeight.constant = 180
        } else {
            if let brandImg = item.first {
                tutorialImage.image = UIImage(named: brandImg)
            }
            tutorialImageWidth.constant = 240
            tutorialImageHeight.constant = 216
        }
        animatedShowContainerView()
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        contentView.backgroundColor = .veryLightPinkThreeCw
        containerView.alpha = 0
    }
    
    private func animatedShowContainerView() {
        UIView.animate(withDuration: 0.25) {
            self.containerView.alpha = 1
        }
    }
    
    private func getMonthForGift() -> Int {
        return Date().currentMonth
    }
    
}

// MARK: - Layout

extension TutorialLeftImageTableViewCell {
    private func layout() {
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4).isActive = true
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 48).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        tutorialImage.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        tutorialImage.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        tutorialImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 9).isActive = true
        
        tutorialImageWidth = tutorialImage.widthAnchor.constraint(equalToConstant: 0)
        tutorialImageWidth.isActive = true
        tutorialImageHeight = tutorialImage.heightAnchor.constraint(equalToConstant: 0)
        tutorialImageHeight.isActive = true
    }
}
