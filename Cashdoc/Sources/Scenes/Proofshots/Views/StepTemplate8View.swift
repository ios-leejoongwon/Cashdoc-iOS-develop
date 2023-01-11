//
//  StepTemplate8View.swift
//  Cashwalk
//
//  Created by lovelycat on 2021/04/27.
//  Copyright © 2021 Cashwalk, Inc. All rights reserved.
//

import Foundation

final class StepTemplate8View: UIView {
    
    // MARK: - Properties
    
    // 탬플릿
    var logoImageView: UIImageView!
    var logoTextImageView: UIImageView!
    var stepCountLabel: UILabel!
    var dateLabel: UILabel!
    var timeLabel: UILabel!
    
    // MARK: - Con(De)structor
    
    convenience init() {
        self.init(frame: .zero)
        
        logoTextImageView = UIImageView().then {
            self.addSubview($0)
            $0.image = UIImage(named: "icLogoWhiteText")
            $0.snp.makeConstraints {
                $0.top.leading.equalToSuperview().offset(18)
            }
        }
        
        logoImageView = UIImageView().then {
            self.addSubview($0)
            $0.image = UIImage(named: "icHealthWhite")
            $0.snp.makeConstraints {
                $0.top.equalToSuperview().offset(18)
                $0.trailing.equalToSuperview().offset(-18)
            }
        }
        
        timeLabel = UILabel().then {
            self.addSubview($0)
            $0.font = .systemFont(ofSize: 18, weight: .medium)
            $0.textAlignment = .left
            $0.textColor = .white
            $0.text = ""
            $0.snp.makeConstraints {
                $0.bottom.equalToSuperview().offset(-18)
                $0.leading.equalToSuperview().offset(18)
            }
        }
        
        dateLabel = UILabel().then {
            self.addSubview($0)
            $0.font = .systemFont(ofSize: 18, weight: .medium)
            $0.textAlignment = .left
            $0.textColor = .white
            $0.text = ""
            $0.snp.makeConstraints {
                $0.bottom.equalTo(timeLabel.snp.top).offset(-4)
                $0.leading.equalToSuperview().offset(18)
            }
        }
        
        stepCountLabel = UILabel().then {
            self.addSubview($0)
            $0.font = .systemFont(ofSize: 24, weight: .bold)
            $0.textAlignment = .left
            $0.textColor = .white
            $0.text = "0 걸음"
            $0.snp.makeConstraints {
                $0.bottom.equalTo(dateLabel.snp.top).offset(-4)
                $0.leading.equalToSuperview().offset(18)
            }
        }
        
    }
    
    func changeStep(step: Int) {
        stepCountLabel.text = "\(step) 걸음"
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
            logoTextImageView.image = UIImage(named: "icLogoColorText")
            logoImageView.image = UIImage(named: "ic24HealthWhiteCopy")
            stepCountLabel.textColor = .black
            dateLabel.textColor = .black
            timeLabel.textColor = .black
        } else {
            logoTextImageView.image = UIImage(named: "icLogoWhiteText")
            logoImageView.image = UIImage(named: "icHealthWhite")
            stepCountLabel.textColor = .white
            dateLabel.textColor = .white
            timeLabel.textColor = .white
        }
    }
}
