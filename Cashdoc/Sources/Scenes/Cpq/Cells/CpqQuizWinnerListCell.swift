//
//  CpqQuizWinnersListCell.swift
//  Cashdoc
//
//  Created by A lim on 04/04/2022.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import UIKit
import Then

class CpqQuizWinnerListCell: UITableViewCell {
    
    // MARK: - Properties
    
    var cpqWinnerModel: CpqWinnerModel? {
        didSet {
            guard let cpqWinnerModel = cpqWinnerModel else {return}
            
            if let profileUrl = cpqWinnerModel.profileUrl, let url = URL(string: profileUrl) {
                Log.tj(profileUrl)
                if profileUrl.contains("http") {
                    profileUrlImageView.kf.setImage(with: url, placeholder: UIImage(named: "imgPlaceholder"))
                }
            }
            if let nickname = cpqWinnerModel.nickname {
                nicknameLabel.text = nickname
            }
            if let point = cpqWinnerModel.point {
                let commaPoint = point.withComma
                pointLabel.text = "\(commaPoint)포인트" //캐시 -> 포인트
            }
        }
    }
    
    // MARK: - UI Components
    
    private let profileUrlImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .lineGrayCw
        $0.image = UIImage(named: "imgPlaceholderProfile")
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    private let nicknameLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .blackCw
        $0.numberOfLines = 2
        $0.text = ""
    }
    private let cashYellowImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icDpointNavy") //캐시 이미지 -> 포인트 이미지
    }
    private let pointLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .blackCw
        $0.numberOfLines = 1
        $0.text = ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Con(De)structor
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setProperties()
        contentView.addSubview(profileUrlImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(cashYellowImageView)
        contentView.addSubview(pointLabel)
        
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        selectionStyle = .none
    }
}

// MARK: - Layout

extension CpqQuizWinnerListCell {
    private func layout() {
        profileUrlImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        profileUrlImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        profileUrlImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileUrlImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profileUrlImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        
        nicknameLabel.leadingAnchor.constraint(equalTo: profileUrlImageView.trailingAnchor, constant: 8).isActive = true
        nicknameLabel.centerYAnchor.constraint(equalTo: profileUrlImageView.centerYAnchor).isActive = true
        nicknameLabel.trailingAnchor.constraint(equalTo: cashYellowImageView.leadingAnchor, constant: -8).isActive = true
        nicknameLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        cashYellowImageView.leadingAnchor.constraint(equalTo: nicknameLabel.trailingAnchor, constant: 8).isActive = true
        cashYellowImageView.centerYAnchor.constraint(equalTo: profileUrlImageView.centerYAnchor).isActive = true
        cashYellowImageView.trailingAnchor.constraint(equalTo: pointLabel.leadingAnchor, constant: -4).isActive = true
        cashYellowImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        cashYellowImageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        pointLabel.leadingAnchor.constraint(equalTo: cashYellowImageView.trailingAnchor, constant: 4).isActive = true
        pointLabel.centerYAnchor.constraint(equalTo: profileUrlImageView.centerYAnchor).isActive = true
        pointLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        pointLabel.widthAnchor.constraint(equalToConstant: 85).isActive = true
        pointLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
}
