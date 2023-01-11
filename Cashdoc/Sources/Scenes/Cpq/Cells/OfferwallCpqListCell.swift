//
//  OfferwallCpqListCell.swift
//  Cashdoc
//
//  Created by A lim on 04/04/2022.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import UIKit
import Then

class OfferwallCpqListCell: UITableViewCell {
    
   // MARK: - Properties
    
    var cpqListtModel: CpqListModel? {
        didSet {
            guard let cpqListtModel = cpqListtModel else {return}
            
            if let iconImageUrl = cpqListtModel.imageUrl, let url = URL(string: iconImageUrl) {
                logoImageView.kf.setImage(with: url, placeholder: nil)
            }
            if let title = cpqListtModel.title {
                titleLabel.text = title
            }
        }
    }
    
    // MARK: - UI Components
    
    private let logoImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.fromRGB(164, 164, 164)
    }
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.textColor = .blackCw
        $0.numberOfLines = 2
    }
    private let participantsLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        $0.textAlignment = .center
        $0.textColor = .blackCw
        $0.numberOfLines = 1
        $0.backgroundColor = UIColor.fromRGB(255, 210, 0)
        $0.text = "참여형"
    }
    private let subTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor.brownishGrayCw
        $0.numberOfLines = 1
        $0.text = "퀴즈풀고 최대 1만캐시 받자!"
    }
    private let getCashButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 5
        $0.setTitle("캐시받기", for: .normal)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.setBackgroundColor(UIColor.fromRGB(94, 80, 80), forState: .normal)
        $0.setBackgroundColor(UIColor.fromRGB(94, 80, 80), forState: .highlighted)
        $0.isUserInteractionEnabled = false
    }
    private let horizontalLine = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .lineGrayCw
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

     // MARK: - Con(De)structor
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            setProperties()
            contentView.addSubview(logoImageView)
            contentView.addSubview(participantsLabel)
            contentView.addSubview(getCashButton)
            contentView.addSubview(titleLabel)
            contentView.addSubview(subTitleLabel)
            contentView.addSubview(horizontalLine)
            
            layout()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Overridden: UITableViewCell
        
        override func prepareForReuse() {
            super.prepareForReuse()
            
            titleLabel.text = ""
        }
        
        // MARK: - Private methods
        
        private func setProperties() {
            selectionStyle = .none
        }
    }

    // MARK: - Layout

    extension OfferwallCpqListCell {
        private func layout() {
            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            logoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            logoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor, multiplier: 0.52).isActive = true
            
            participantsLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 13).isActive = true
            participantsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
            participantsLabel.widthAnchor.constraint(equalToConstant: 39).isActive = true
            participantsLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
            titleLabel.topAnchor.constraint(equalTo: participantsLabel.bottomAnchor, constant: 6).isActive = true
            
            subTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
            subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16).isActive = true
            subTitleLabel.trailingAnchor.constraint(equalTo: getCashButton.leadingAnchor, constant: -16).isActive = true
            
            getCashButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
            getCashButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
            getCashButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
            getCashButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
            
            horizontalLine.topAnchor.constraint(equalTo: getCashButton.bottomAnchor, constant: 16).isActive = true
            horizontalLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            horizontalLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            horizontalLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            horizontalLine.heightAnchor.constraint(equalToConstant: 7).isActive = true
        }
    }
