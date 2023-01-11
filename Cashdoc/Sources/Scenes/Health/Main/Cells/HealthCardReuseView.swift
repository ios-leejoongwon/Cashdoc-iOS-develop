//
//  HealthCardReuseView.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/02.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Foundation

class HealthCardReuseView: UICollectionReusableView {
    private let footerLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .brownGrayCw
        $0.text = "마지막 업데이트 -"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(footerLabel)
        layout()
        
        if let getDate = UserDefaults.standard.string(forKey: UserDefaultKey.kPropertyScrpLastUpdateDate.rawValue) {
            footerLabel.text = "마지막 업데이트 \(getDate)"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd HH:mm"
            let date = formatter.string(from: Date())
            footerLabel.text = String(format: "마지막 업데이트 %@", date)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout

extension HealthCardReuseView {
    private func layout() {
         footerLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        footerLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
}
