//
//  CheckupMarkView.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/05/22.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation

enum MarkCase: StringLiteralType {
    case 정상
    case 주의
    case 위험
    case 질환의심
}

class CheckupMarkView: UIView {
    private var markLabel: UILabel!
        
    var getType: MarkCase = .정상 {
        didSet {
            switch getType {
            case .정상:
                self.layer.borderColor = UIColor.fromRGB(53, 143, 255).cgColor
                markLabel.textColor = UIColor.fromRGB(53, 143, 255)
                markLabel.text = "정상"
            case .주의:
                self.layer.borderColor = UIColor.fromRGB(60, 175, 16).cgColor
                markLabel.textColor = UIColor.fromRGB(60, 175, 16)
                markLabel.text = "주의"
            case .위험:
                self.layer.borderColor = UIColor.fromRGB(255, 47, 74).cgColor
                markLabel.textColor = UIColor.fromRGB(255, 47, 74)
                markLabel.text = "위험"
            case .질환의심:
                self.layer.borderColor = UIColor.fromRGB(255, 47, 74).cgColor
                markLabel.textColor = UIColor.fromRGB(255, 47, 74)
                markLabel.text = "질환의심"
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.firstInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.firstInit()
    }
    
    private func firstInit() {
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.backgroundColor = .white
        
        markLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 12)
            addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.centerX.centerY.equalToSuperview()
            }
        }
        
        getType = .정상
    }
}
