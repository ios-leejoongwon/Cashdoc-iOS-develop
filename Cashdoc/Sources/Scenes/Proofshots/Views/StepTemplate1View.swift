//
//  StepTemplate1View.swift
//  Cashwalk
//
//  Created by lovelycat on 2021/04/23.
//  Copyright © 2021 Cashwalk, Inc. All rights reserved.
//

import Foundation
import UIKit

final class StepTemplate1View: UIView {
    
    // MARK: - Properties
    
    // 탬플릿
    var imageLogoImageView: UIImageView!
    var dateLabel: UILabel!
    var timeLabel: UILabel!
      
    // MARK: - Con(De)structor
    
    convenience init() {
        self.init(frame: .zero)
         
        imageLogoImageView = UIImageView().then {
            self.addSubview($0)
            $0.image = UIImage(named: "icLogoWhiteEn")
            $0.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(18)
                $0.bottom.equalToSuperview().offset(-26)
            }
        }
          
        timeLabel = UILabel().then {
            self.addSubview($0)
            $0.font = .systemFont(ofSize: 36, weight: .medium)
            $0.textAlignment = .right
            $0.textColor = .white
            $0.text = ""
            $0.snp.makeConstraints {
                $0.bottom.equalToSuperview().offset(-18)
                $0.trailing.equalTo(self.snp.trailing).offset(-18)
            }
        }
        
        dateLabel = UILabel().then {
            self.addSubview($0)
            $0.font = .systemFont(ofSize: 18, weight: .medium)
            $0.textAlignment = .right
            $0.textColor = .white
            $0.text = ""
            $0.snp.makeConstraints {
                $0.bottom.equalTo(timeLabel.snp.top).offset(4)
                $0.trailing.equalTo(timeLabel.snp.trailing)
            }
        }
    }
    
    func changeStep(step: Int) {
        
    }
    
    func changeDate(date: Date) {
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "ko_KR")
        timeFormatter.dateFormat = "hh:mm a"
        timeFormatter.amSymbol = "AM"
        timeFormatter.pmSymbol = "PM"
        let timeString = timeFormatter.string(from: Date())
        timeLabel.text = timeString
        
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
            timeLabel.textColor = .black
        } else {
            imageLogoImageView.image = UIImage(named: "icLogoWhiteEn")
            dateLabel.textColor = .white
            timeLabel.textColor = .white
        }
    }
}
