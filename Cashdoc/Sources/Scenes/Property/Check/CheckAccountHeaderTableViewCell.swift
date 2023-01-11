//
//  CheckAccountHeaderTableViewCell.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/05/19.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

final class CheckAccountHeaderTableViewCell: CashdocTableViewCell {
    
    private weak var dateLabel: UILabel!
    private weak var weekDayLabel: UILabel!
    
    func setupView() {
        let borderView = UIView().then {
            $0.layer.cornerRadius = 4
            $0.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            $0.layer.borderWidth = 0.5
            $0.layer.borderColor = UIColor.grayCw.cgColor
            $0.backgroundColor = .white
            $0.clipsToBounds = true
            contentView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.equalToSuperview().inset(8)
                m.leading.trailing.equalToSuperview().inset(16)
                m.bottom.equalToSuperview()
            }
        }
        dateLabel = UILabel().then {
            $0.setFontToMedium(ofSize: 18)
            $0.setLineHeight(lineHeight: 26)
            $0.textColor = .blackCw
            borderView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.bottom.equalToSuperview().inset(15)
                m.leading.equalToSuperview().inset(20)
            }
        }
        weekDayLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 12)
            $0.textColor = .brownGrayCw
            borderView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.centerY.equalToSuperview()
                m.leading.equalTo(dateLabel.snp.trailing).offset(5.5)
            }
        }
        _ = UIImageView().then {
            $0.backgroundColor = .grayCw
            borderView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.leading.trailing.equalToSuperview()
                m.bottom.equalToSuperview()
                m.height.equalTo(0.5)
            }
        }
    }
    
    func setupProperty() {
        backgroundColor = .clear
    }
    
    func configure(_ date: (String, String)) {
        dateLabel.text = date.0
        weekDayLabel.text = date.1
    }
}
