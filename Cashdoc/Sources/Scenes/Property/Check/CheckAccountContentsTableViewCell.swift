//
//  CheckAccountContentsTableViewCell.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/05/19.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

final class CheckAccountContentsTableViewCell: CashdocTableViewCell {
    
    private weak var nameLabel: UILabel!
    private weak var timeLabel: UILabel!
    private weak var inoutLabel: UILabel!
    private weak var totalLabel: UILabel!
    private weak var borderView: UIView!
    private weak var lastHiddenLine: UIView!
    
    func setupView() {
        borderView = UIView().then {
            $0.backgroundColor = .white
            $0.clipsToBounds = true
            contentView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.equalToSuperview()
                m.leading.trailing.equalToSuperview().inset(16)
                m.bottom.equalToSuperview()
            }
        }
        lastHiddenLine = UIView().then {
            $0.backgroundColor = .white
            $0.isHidden = true
            contentView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.equalToSuperview()
                m.leading.trailing.equalToSuperview().inset(16.5)
                m.height.equalTo(0.5)
            }
        }
        nameLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.textColor = .blackCw
            borderView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.equalToSuperview().inset(16)
                m.leading.equalToSuperview().inset(20)
            }
        }
        timeLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 12)
            $0.textColor = .brownGrayCw
            borderView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.equalTo(nameLabel.snp.bottom).offset(2)
                m.leading.equalTo(nameLabel)
                m.bottom.equalToSuperview().inset(16)
            }
        }
        inoutLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.textColor = .blackCw
            borderView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.centerY.equalTo(nameLabel)
                m.trailing.equalToSuperview().inset(20)
            }
            $0.snp.contentCompressionResistanceHorizontalPriority = .greatestFiniteMagnitude
        }
        totalLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 12)
            $0.textColor = .brownGrayCw
            borderView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.centerY.equalTo(timeLabel)
                m.trailing.equalTo(inoutLabel)
            }
        }
        _ = UIView().then {
            $0.backgroundColor = .grayCw
            borderView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.bottom.leading.equalToSuperview()
                m.width.equalTo(0.5)
            }
        }
        _ = UIView().then {
            $0.backgroundColor = .grayCw
            borderView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.bottom.trailing.equalToSuperview()
                m.width.equalTo(0.5)
            }
        }
    }
    
    func setupProperty() {
        backgroundColor = .clear
    }
    
    func configure(_ item: CheckAccountContentItem, isLast: Bool) {
        if item.tranGb == "입금" {
            inoutLabel.textColor = .blueCw
            inoutLabel.text = item.inoutBal.commaValue + "원"
        } else {
            inoutLabel.textColor = .blackCw
            inoutLabel.text = "-" + item.inoutBal.commaValue + "원"
        }
        nameLabel.text = item.name
        timeLabel.text = "\(item.time[0...1]):\(item.time[2...3])"
        totalLabel.text = item.tranBal.commaValue + "원"
        
        if isLast {
            borderView.layer.cornerRadius = 4
            borderView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            borderView.layer.borderWidth = 0.5
            borderView.layer.borderColor = UIColor.grayCw.cgColor
            lastHiddenLine.isHidden = false
        } else {
            borderView.layer.borderWidth = 0
            borderView.layer.cornerRadius = 0
            lastHiddenLine.isHidden = true
        }
    }
}
