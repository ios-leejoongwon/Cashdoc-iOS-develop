//
//  StepTemplate2View.swift
//  Cashwalk
//
//  Created by lovelycat on 2021/04/22.
//  Copyright © 2021 Cashwalk, Inc. All rights reserved.
//

import Foundation

final class StepTemplate2View: UIView {
    
    // MARK: - Properties
    
    // 탬플릿
    var stepCountLabel: UILabel!
    var imageLogoImageView: UIImageView!
    var dateLabel: UILabel!
    var timeLabel: UILabel!
    
    // MARK: - Con(De)structor
    
    convenience init() {
        self.init(frame: .zero)
        
        imageLogoImageView = UIImageView().then {
            self.addSubview($0)
            $0.image = UIImage(named: "template2bg_w")
            $0.snp.makeConstraints {
                $0.top.bottom.leading.trailing.equalToSuperview().inset(18)
            }
        }
        
        timeLabel = UILabel().then {
            self.addSubview($0)
            $0.font = .systemFont(ofSize: 18, weight: .medium)
            $0.textAlignment = .right
            $0.textColor = .white
            $0.text = ""
            $0.snp.makeConstraints {
                $0.bottom.trailing.equalToSuperview().offset(-32)
            }
        }
        
        dateLabel = UILabel().then {
            self.addSubview($0)
            $0.font = .systemFont(ofSize: 18, weight: .medium)
            $0.textAlignment = .right
            $0.textColor = .white
            $0.text = ""
            $0.snp.makeConstraints {
                $0.trailing.equalTo(timeLabel.snp.leading).offset(-4)
                $0.bottom.equalTo(timeLabel.snp.bottom)
            }
        }
        
        stepCountLabel = UILabel().then {
            self.addSubview($0)
            $0.font = .systemFont(ofSize: 24, weight: .bold)
            $0.textColor = .white
            $0.text = "0"
            $0.snp.makeConstraints {
                $0.trailing.equalTo(timeLabel.snp.trailing)
                $0.bottom.equalTo(timeLabel.snp.top).offset(4)
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
            stepCountLabel.textColor = .black
            imageLogoImageView.image = UIImage(named: "template2bg_b")
            dateLabel.textColor = .black
            timeLabel.textColor = .black
        } else {
            stepCountLabel.textColor = .white
            imageLogoImageView.image = UIImage(named: "template2bg_w")
            dateLabel.textColor = .white
            timeLabel.textColor = .white
        }
    }
}
