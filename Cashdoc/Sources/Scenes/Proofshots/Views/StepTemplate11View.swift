//
//  StepTemplate11View.swift
//  Cashwalk
//
//  Created by lovelycat on 2021/04/27.
//  Copyright © 2021 Cashwalk, Inc. All rights reserved.
//

import Foundation
import UIKit

final class StepTemplate11View: UIView {
    
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
                $0.top.leading.equalToSuperview().offset(18)
            }
        }
        
        dateLabel = UILabel().then {
            self.addSubview($0)
            $0.font = .systemFont(ofSize: 14, weight: .medium)
            $0.textAlignment = .right
            $0.textColor = .white
            $0.text = ""
            $0.snp.makeConstraints {
                $0.top.equalToSuperview().offset(21)
                $0.trailing.equalToSuperview().offset(-18)
            }
        }
    }
    
    func changeStep(step: Int) {
        
    }
    
    func changeDate(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy.MM.dd" 
        let dateString = dateFormatter.string(from: date)
        
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "ko_KR")
        timeFormatter.dateFormat = "hh:mm a"
        timeFormatter.amSymbol = "a.m"
        timeFormatter.pmSymbol = "p.m"
        let timeString = timeFormatter.string(from: Date())
        
        dateLabel.text = "\(dateString) \(timeString)"
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
