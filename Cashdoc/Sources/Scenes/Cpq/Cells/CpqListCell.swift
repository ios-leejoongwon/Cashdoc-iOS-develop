//
//  CpqListCell.swift
//  Cashdoc
//
//  Created by A lim on 04/04/2022.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import UIKit
import Then

class CpqListCell: UITableViewCell {
    
    // MARK: - Properties 바보
    
    var cpqListtModel: CpqListModel? {
        didSet {
            guard let cpqListtModel = cpqListtModel else { return }
            
            if let iconImageUrl = cpqListtModel.iconImageUrl, let url = URL(string: iconImageUrl) {
                logoImageView.kf.setImage(with: url, placeholder: UIImage(named: "icCpQlogoDefault"))
            }
            if let title = cpqListtModel.title {
                titleLabel.text = title
            }
            
            let winner = cpqListtModel.winner ?? 0
            participantsLabel.text = "\(winner.withComma)명 참여"
            
            if let point = cpqListtModel.point {
                if cpqListtModel.lock == 0 {
                    liveQuizImageView.isHidden = false
                    let commaPoint = point.withComma
                    pointLabel.text = "\(commaPoint)포인트 남음" //캐시 -> 포인트
                    pointLabel.textColor = .blackCw
                    titleLabel.textColor = .blackCw
                    titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
                    setShowCoinImage(isShow: true)
                } else {
                    liveQuizImageView.isHidden = true
                    pointLabel.text = "종료된 퀴즈"
                    pointLabel.textColor = .warmGrayCw
                    titleLabel.textColor = .warmGrayCw
                    titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                    setShowCoinImage(isShow: false)
                }
            }
        }
    }
    
    // MARK: - UI Components
    private let logoImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icCpQlogoDefault")
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
        $0.layer.borderColor =  UIColor.fromRGB(212, 212, 212).cgColor
        $0.layer.borderWidth = 0.5
    }
    private let liveQuizImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgLivequiz")
        $0.isHidden = true
    }
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.textColor = UIColor.fromRGB(12, 12, 12)
        $0.numberOfLines = 2
    }
    private let participantsLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = UIColor.fromRGB(102, 102, 102)
        $0.numberOfLines = 1
    }
    private let coinImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icDpointNavy") //캐시 이미지 -> 포인트 이미지
    }
    private let pointLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        $0.textColor = UIColor.black
        $0.numberOfLines = 1
    }
    private let verticalLine = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayCw
    }
    private let horizontalLine = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.fromRGB(229, 229, 229)
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
        contentView.addSubview(logoImageView)
        contentView.addSubview(liveQuizImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(participantsLabel)
        contentView.addSubview(verticalLine)
        contentView.addSubview(coinImageView)
        contentView.addSubview(pointLabel)
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
        participantsLabel.text = ""
        pointLabel.text = ""
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        selectionStyle = .none
        contentView.backgroundColor = .white
    }

}

// MARK: - Layout

extension CpqListCell {
    
    private func layout() { 
        logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22).isActive = true
        logoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: 42).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        liveQuizImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        liveQuizImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        liveQuizImageView.widthAnchor.constraint(equalToConstant: 42).isActive = true
        
        titleLabel.centerYAnchor.constraint(equalTo: logoImageView.centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 12).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true

        participantsLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        participantsLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 11).isActive = true
        participantsLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        verticalLine.centerYAnchor.constraint(equalTo: participantsLabel.centerYAnchor).isActive = true
        verticalLine.leadingAnchor.constraint(equalTo: participantsLabel.trailingAnchor, constant: 10).isActive = true
        verticalLine.heightAnchor.constraint(equalToConstant: 11).isActive = true
        verticalLine.widthAnchor.constraint(equalToConstant: 1).isActive = true
        
        coinImageView.leadingAnchor.constraint(equalTo: verticalLine.trailingAnchor, constant: 12).isActive = true
        coinImageView.centerYAnchor.constraint(equalTo: pointLabel.centerYAnchor).isActive = true
        coinImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        coinImageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        pointLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        pointLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        pointLabel.leadingAnchor.constraint(equalTo: coinImageView.trailingAnchor, constant: 3).isActive = true
        pointLabel.centerYAnchor.constraint(equalTo: participantsLabel.centerYAnchor).isActive = true
        
        horizontalLine.topAnchor.constraint(equalTo: participantsLabel.bottomAnchor, constant: 24).isActive = true
        horizontalLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        horizontalLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        horizontalLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        horizontalLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    private func setShowCoinImage(isShow: Bool) {
        if isShow {
            coinImageView.isHidden = false
            coinImageView.snp.updateConstraints { m in
                m.leading.equalTo(verticalLine.snp.trailing).offset(12)
                m.width.height.equalTo(16)
                m.centerY.equalTo(pointLabel.snp.centerY)
            }
            
            pointLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            pointLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            pointLabel.snp.updateConstraints { m in
                m.leading.equalTo(coinImageView.snp.trailing).offset(3)
                m.centerY.equalTo(participantsLabel.snp.centerY)
            }
        } else {
            coinImageView.isHidden = true
            pointLabel.snp.updateConstraints { m in
                m.leading.equalTo(coinImageView.snp.trailing).offset(-20)
                m.centerY.equalTo(participantsLabel.snp.centerY)
            }
        }
    }
}

extension Int {
    var withComma: String {
        let decimalFormatter = NumberFormatter()
        decimalFormatter.numberStyle = NumberFormatter.Style.decimal
        decimalFormatter.groupingSeparator = ","
        decimalFormatter.groupingSize = 3
        
        return decimalFormatter.string(from: self as NSNumber) ?? ""
    }
}

extension String {
    var delComma: String {
        if self.count > 0 {
            return self.replacingOccurrences(of: ",", with: "")
        } else {
            return "0"
        }
    }
}
