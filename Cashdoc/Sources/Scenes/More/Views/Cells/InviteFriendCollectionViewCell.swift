//
//  InviteFriendCollectionViewCell.swift
//  Cashdoc
//
//  Created by Oh Sangho on 25/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

final class InviteFriendCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let inviteImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgPersonDisabled")
    }
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setProperties()
        contentView.addSubview(inviteImage)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UICollectionViewCell
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        inviteImage.image = nil
    }
    
    // MARK: - Internal methods
    
    func configure(with isInvited: Bool) {
        if isInvited {
            inviteImage.image = UIImage(named: "imgPerson")
        } else {
            inviteImage.image = UIImage(named: "imgPersonDisabled")
        }
    }
    
    // MARK: - Private metdhos
    
    private func setProperties() {
        contentView.backgroundColor = .white
    }
    
}

// MARK: - Layout

extension InviteFriendCollectionViewCell {
    private func layout() {
        inviteImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        inviteImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        inviteImage.widthAnchor.constraint(equalToConstant: 64).isActive = true
        inviteImage.heightAnchor.constraint(equalTo: inviteImage.widthAnchor).isActive = true
    }
}
