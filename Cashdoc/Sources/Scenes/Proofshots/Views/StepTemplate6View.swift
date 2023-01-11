//
//  StepTemplate6View.swift
//  Cashwalk
//
//  Created by lovelycat on 2021/04/27.
//  Copyright © 2021 Cashwalk, Inc. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

final class StepTemplate6View: UIView {
    
    private(set) var dataStackViewWidth: Constraint?
    
    // MARK: - Properties
    
    // 탬플릿
    var imageLogoImageView: UIImageView!
    var dateLabel: UILabel!
    
    // MARK: - Con(De)structor
    
    convenience init() {
        self.init(frame: .zero)
        
        _ = UIStackView().then {
            self.addSubview($0)
            $0.axis = .vertical
            $0.distribution = .fill
            $0.alignment = .leading
            $0.spacing = 36
            $0.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
        }
        
        imageLogoImageView = UIImageView().then {
            self.addSubview($0)
            $0.image = UIImage(named: "icLogoWhiteEn")
            $0.snp.makeConstraints {
                $0.bottom.equalToSuperview().offset(-18)
                $0.centerX.equalToSuperview()
            }
        }
 
        dateLabel = UILabel().then {
            self.addSubview($0)
            $0.font = .systemFont(ofSize: 24, weight: .medium)
            $0.textAlignment = .right
            $0.textColor = .white
            $0.text = ""
            $0.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
        }
         
    }
    
    func changeStep(step: Int) { 
    }
    
    func changeDate(date: Date) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy / MM / dd"
        let dateString = formatter.string(from: date)
        dateLabel.text = dateString
    }
    
    func changeDarkModeView(_ isDarkMode: Bool) {
        if isDarkMode {
            imageLogoImageView.image = UIImage(named: "icLogoColorEn")
            dateLabel.textColor = .black
        } else {
            imageLogoImageView.image = UIImage(named: "icLogoWhiteEn")
            dateLabel.textColor = .white
        }
    }
}
