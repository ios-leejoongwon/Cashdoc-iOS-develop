//
//  StepTemplate4View.swift
//  Cashwalk
//
//  Created by lovelycat on 2021/04/27.
//  Copyright © 2021 Cashwalk, Inc. All rights reserved.
//

import Foundation
import UIKit

final class StepTemplate4View: UIView {
    
    // MARK: - Properties
    
    // 탬플릿
    var imageLogoImageView: UIImageView!
    var dateLabel: UILabel!
    
    // MARK: - Con(De)structor
    
    convenience init() {
        self.init(frame: .zero)
        
        imageLogoImageView = UIImageView().then {
            self.addSubview($0)
            $0.image = UIImage(named: "icLogoWhiteEn")
            $0.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.bottom.equalToSuperview().offset(-18)
            }
        } 
        
        dateLabel = UILabel().then {
            self.addSubview($0)
            $0.font = .systemFont(ofSize: 24, weight: .medium)
            $0.textAlignment = .left
            $0.textColor = .white
            $0.text = ""
            $0.snp.makeConstraints {
                $0.top.leading.equalToSuperview().offset(18)
            }
        }
        
    }
    
    func changeStep(step: Int) {
       
    }
    
    func changeDate(date: Date) {
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: "default")
        dateformatter.dateFormat = "MMM d, yyyy"
        let dateString = dateformatter.string(from: date)
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
