//
//  ProfilePointView.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 20/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import Kingfisher
import Then

final class ProfilePointView: UIView {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let profileImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFill
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.grayCw.cgColor
        $0.layer.cornerRadius = 40 / 2
        $0.clipsToBounds = true
        $0.image = UIImage(named: "imgPlaceholderProfile")
    }
    private let nicknameLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 1
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .blackCw
        $0.text = "캐시닥사용자"
    }
    private let cashImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFill
        $0.image = UIImage(named: "icCoinYellow")
    }
    private let pointLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .blackTwoCw
        $0.setFontToMedium(ofSize: 14)
        $0.text = "0 캐시"
    }
    private let horizontalLine = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayCw
    }
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        addSubview(nicknameLabel)
        addSubview(cashImageView)
        addSubview(pointLabel)
        addSubview(horizontalLine)
        layout()
        refreshView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addSubview(profileImageView)
        addSubview(nicknameLabel)
        addSubview(cashImageView)
        addSubview(pointLabel)
        addSubview(horizontalLine)
        layout()
        refreshView()
    }
    
    // MARK: - Internal methods
    
    func refreshView() {
        UserManager.shared.user.bind { (user) in
            DispatchQueue.main.async {
                if let urlString = user.profileUrl, let url = URL(string: urlString) {
                    self.profileImageView.kf.setImage(with: url, options: [.transition(.fade(0.1))])
                }
                self.nicknameLabel.text = user.nickname
                self.pointLabel.text = "\((user.point ?? 0).commaValue) 캐시"
            }
        }.disposed(by: DisposeBag())
    }
    
}

// MARK: - Layout

extension ProfilePointView {
    
    private func layout() {
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        nicknameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        nicknameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16).isActive = true
        nicknameLabel.trailingAnchor.constraint(equalTo: cashImageView.leadingAnchor, constant: -8).isActive = true
        
        cashImageView.trailingAnchor.constraint(equalTo: pointLabel.leadingAnchor, constant: -4).isActive = true
        cashImageView.centerYAnchor.constraint(equalTo: pointLabel.centerYAnchor).isActive = true
        cashImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        cashImageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        pointLabel.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        pointLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        pointLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        pointLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16) .isActive = true
        
        horizontalLine.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        horizontalLine.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        horizontalLine.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        horizontalLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
}
