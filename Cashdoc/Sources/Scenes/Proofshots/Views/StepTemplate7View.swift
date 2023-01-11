//
//  StepTemplate7View.swift
//  Cashwalk
//
//  Created by lovelycat on 2021/04/27.
//  Copyright © 2021 Cashwalk, Inc. All rights reserved.
//

import Foundation

final class StepTemplate7View: UIView {
    
    // MARK: - Properties
    
    // 탬플릿
    var imageLogoImageView: UIImageView!
    var stepCountLabel: UILabel!
    var stepTextLabel: UILabel!
    var dateLabel: UILabel!
    var timeLabel: UILabel!
    
    // MARK: - Con(De)structor
    
    convenience init() {
        self.init(frame: .zero)
        
        imageLogoImageView = UIImageView().then {
            self.addSubview($0)
            $0.image = UIImage(named: "icLogoWhiteEn")
            $0.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalToSuperview().offset(18)
            }
        }
        stepCountLabel = UILabel().then {
            self.addSubview($0)
            $0.font = .systemFont(ofSize: 80, weight: .bold)
            $0.textColor = .white
            $0.text = "0"
            $0.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
        }
        
        stepTextLabel = UILabel().then {
            self.addSubview($0)
            $0.font = .systemFont(ofSize: 20, weight: .medium)
            $0.textColor = .white
            $0.text = "steps"
            $0.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalTo(stepCountLabel.snp.bottom).offset(4)
            }
        }
         
        timeLabel = UILabel().then {
            self.addSubview($0)
            $0.font = .systemFont(ofSize: 14, weight: .medium)
            $0.textAlignment = .center
            $0.textColor = .white
            $0.text = ""
            $0.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.bottom.equalToSuperview().offset(-18)
            }
        }
         
        dateLabel = UILabel().then {
            self.addSubview($0)
            $0.font = .systemFont(ofSize: 14, weight: .medium)
            $0.textAlignment = .center
            $0.textColor = .white
            $0.text = ""
            $0.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.bottom.equalTo(timeLabel.snp.top).offset(-4)
            }
        }
        
    }
    
    func changeStep(step: Int) {
        stepCountLabel.text = "\(step)"
    }
    
    func changeDate(date: Date) {
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "ko_KR")
        timeFormatter.dateFormat = "hh:mm a"
        timeFormatter.amSymbol = "AM"
        timeFormatter.pmSymbol = "PM"
        let timeString = timeFormatter.string(from: Date())
        timeLabel.text = timeString
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        dateLabel.text = dateString
    }
    
    func changeDarkModeView(_ isDarkMode: Bool) {
        if isDarkMode {
            imageLogoImageView.image = UIImage(named: "icLogoColorEn")
            stepCountLabel.textColor = .black
            stepTextLabel.textColor = .black
            dateLabel.textColor = .black
            timeLabel.textColor = .black
        } else {
            imageLogoImageView.image = UIImage(named: "icLogoWhiteEn")
            stepCountLabel.textColor = .white
            stepTextLabel.textColor = .white
            dateLabel.textColor = .white
            timeLabel.textColor = .white
        }
    }
}
