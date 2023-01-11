//
//  StepTemplate10View.swift
//  Cashwalk
//
//  Created by lovelycat on 2021/04/27.
//  Copyright © 2021 Cashwalk, Inc. All rights reserved.
//

import Foundation
import UIKit

final class StepTemplate10View: UIView {
    
    // MARK: - Properties
    
    // 탬플릿
    var stepCountLabel: UILabel!
    var stepText: UILabel!
    var imageLogoImageView: UIImageView!
    var dateLabel: UILabel!
    var circleView: UIView!
    
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
                $0.height.equalTo(24)
                $0.top.equalToSuperview().offset(18)
                $0.trailing.equalToSuperview().offset(-18)
            }
        }
        
        circleView = UIView().then {
            self.addSubview($0)
            $0.backgroundColor = .white
            $0.IBcornerRadius = 48
            $0.snp.makeConstraints {
                $0.bottom.trailing.equalToSuperview().offset(-18)
                $0.height.width.equalTo(96)
            }
        }
        
        let stackView =  UIStackView().then {
            circleView.addSubview($0)
            $0.axis = .vertical
            $0.distribution = .fill
            $0.alignment = .center
            $0.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.centerY.equalToSuperview()
            }
        }
        
        stepCountLabel = UILabel().then {
            stackView.addArrangedSubview($0)
            $0.font = .systemFont(ofSize: 22, weight: .bold)
            $0.numberOfLines = 1
            $0.textColor = .black
            $0.text = "0"
        }
        
        stepText = UILabel().then {
            stackView.addArrangedSubview($0)
            $0.font = .systemFont(ofSize: 14, weight: .medium)
            $0.numberOfLines = 1
            $0.textColor = .black
            $0.text = "걸음"
        }
        
    }
    
    func changeStep(step: Int) {
        stepCountLabel.text = "\(step)"
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
            circleView.backgroundColor = .black
            stepCountLabel.textColor = .white
            stepText.textColor = .white
            imageLogoImageView.image = UIImage(named: "icLogoColorEn")
            dateLabel.textColor = .black
        } else {
            circleView.backgroundColor = .white
            stepCountLabel.textColor = .black
            stepText.textColor = .black
            imageLogoImageView.image = UIImage(named: "icLogoWhiteEn")
            dateLabel.textColor = .white
        }
    }
}
