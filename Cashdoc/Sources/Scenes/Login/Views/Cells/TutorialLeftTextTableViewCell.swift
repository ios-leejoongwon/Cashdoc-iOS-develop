//
//  TutorialLeftTextTableViewCell.swift
//  Cashdoc
//
//  Created by Oh Sangho on 23/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

final class TutorialLeftTextTableViewCell: CashdocTableViewCell {
    
    // MARK: - Properties
    
    private var isStartDialog: Bool = false
    
    // MARK: - UI Components
    
    private let botImage = ResizableImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgChatLogo")
    }
    private let containerView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let dialogView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
    }
    private let tailImage = ResizableImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgBallloonLeft")
    }
    private let questionLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .blackCw
        $0.numberOfLines = 0
    }
    
    // MARK: - Con(De)structor
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setProperties()
        contentView.addSubview(botImage)
        contentView.addSubview(containerView)
        containerView.addSubview(tailImage)
        containerView.addSubview(dialogView)
        dialogView.addSubview(questionLabel)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        questionLabel.text = nil
    }
    
    // MARK: - Internal methods
    
    func configure(with item: TutorialLeftItem) {
        checkStartDialog(item.isStart)
        if item.isNeedName {
            UserManager.shared.user
                .bind { (user) in
                    if let first = item.dialog.first,
                        let last = item.dialog.last {
                        if user.nickname.count <= 4 {
                            self.questionLabel.text = String(format: "%@%@%@", first, user.nickname, last)
                        } else {
                            let nickName = String(format: "%@...", String(user.nickname.prefix(4)))
                            self.questionLabel.text = String(format: "%@%@%@", first, nickName, last)
                        }
                    }
            }
            .disposed(by: cellDisposeBag)
        } else {
            if let _dialog = item.dialog.first {
                questionLabel.text = _dialog
            }
        }
        animatedShowContainerView()
    }
    
    // MARK: - Private methods
    
    private func checkStartDialog(_ isStart: Bool) {
        if isStart {
            botImage.isHidden = false
            tailImage.isHidden = false
        } else {
            botImage.isHidden = true
            tailImage.isHidden = true
        }
    }
    
    private func setProperties() {
        contentView.backgroundColor = .veryLightPinkThreeCw
        containerView.alpha = 0
    }
    
    private func animatedShowContainerView() {
        UIView.animate(withDuration: 0.25) {
            self.containerView.alpha = 1
        }
    }
    
}

// MARK: - Layout

extension TutorialLeftTextTableViewCell {
    private func layout() {
        botImage.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        botImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = true
        
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4).isActive = true
        containerView.leadingAnchor.constraint(equalTo: botImage.trailingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        containerViewLayout()
    }
    
    private func containerViewLayout() {
        dialogView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        dialogView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        dialogView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 9).isActive = true
        dialogView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        dialogView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        tailImage.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        tailImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 7).isActive = true
        
        questionLabel.topAnchor.constraint(equalTo: dialogView.topAnchor, constant: 8).isActive = true
        questionLabel.bottomAnchor.constraint(equalTo: dialogView.bottomAnchor, constant: -8).isActive = true
        questionLabel.leadingAnchor.constraint(equalTo: dialogView.leadingAnchor, constant: 14).isActive = true
        questionLabel.trailingAnchor.constraint(equalTo: dialogView.trailingAnchor, constant: -14).isActive = true
        questionLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
}
