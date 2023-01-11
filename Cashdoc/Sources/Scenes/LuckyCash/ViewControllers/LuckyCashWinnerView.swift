//
//  LuckyCashWinnerView.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/06/24.
//  Copyright © 2020 Cashwalk, Inc. All rights reserved.
//

import Kingfisher

final class LuckyCashWinnerView: UIView {

    // MARK: - Properties
    
    var winner: LuckyCashWinnerModel? {
        didSet {
            guard let winner = winner else {return}
            if let time = winner.created {
                #if CASHWALK
                timeLabel.text = Date.sinceNowKor(time: time)
                #else
                let date = time.simpleDateFormat(SERVER_DATE_FORMAT)
                timeLabel.text = Date.sinceNowKor(date: date)
                #endif
            }
            if let name = winner.nickname, let point = winner.point {
                noticeLabel.text = "\(name)님이 \(point.commaValue)캐시 당첨되셨습니다."
            }
            if let url = winner.imageUrl {
                itemImageView.kf.setImage(with: URL(string: url))
            }
        }
    }
    
    // MARK: - UI Components
    
    private let timeLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .systemFont(ofSize: 13, weight: .medium)
        $0.textColor = .blackTwoCw
        $0.textAlignment = .left
        $0.backgroundColor = .clear
    }
    private let noticeLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.textColor = .brownishGrayCw
        $0.textAlignment = .left
        $0.numberOfLines = 2
        $0.backgroundColor = .clear
    }
    private let itemImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - Con(De)structor
    
    convenience init() {
        self.init(frame: .zero)
        
        setProperties()
        addSubview(timeLabel)
        addSubview(noticeLabel)
        addSubview(itemImageView)
        layout()
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        clipsToBounds = true
        backgroundColor = .clear
    }
}

// MARK: - Layout

extension LuckyCashWinnerView {
    
    private func layout() {
//        timeLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        timeLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        noticeLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        noticeLabel.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 4).isActive = true
        noticeLabel.trailingAnchor.constraint(lessThanOrEqualTo: itemImageView.leadingAnchor, constant: -8).isActive = true
        noticeLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        itemImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        itemImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        itemImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        itemImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }
}
