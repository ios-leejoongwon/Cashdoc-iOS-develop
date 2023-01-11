//
//  StepTemplate5View.swift
//  Cashwalk
//
//  Created by lovelycat on 2021/04/27.
//  Copyright © 2021 Cashwalk, Inc. All rights reserved.
//

import Foundation
import UIKit

final class StepTemplate5View: UIView {
    
    // MARK: - Properties
    
    // 걸음수
    
    var backgroundView: UIView!
    var imageLogoImageView: UIImageView!
    private var bottomView: UIView!
    var stepCountImageView: UIImageView!
    var stepCountLabel: UILabel!
    
    var dateLabel: UILabel!
     
    // MARK: - Con(De)structor
    
    convenience init() {
        self.init(frame: .zero)
        
        backgroundView = UIView().then {
            self.addSubview($0)
            $0.backgroundColor = .clear
            $0.IBborderColor = .white
            $0.IBborderWidth = 2.1
            $0.snp.makeConstraints {
                $0.height.width.equalToSuperview()
            }
        }
        
        imageLogoImageView = UIImageView().then {
            self.addSubview($0)
            $0.image = UIImage(named: "icLogoWhiteEn")
            $0.snp.makeConstraints {
                $0.top.leading.equalToSuperview().offset(18)
            }
        }
        
        bottomView = UIView().then {
            self.addSubview($0)
            $0.backgroundColor = .white
            $0.snp.makeConstraints {
                $0.trailing.bottom.leading.equalToSuperview() 
                $0.height.equalTo(75)
            }
        }
          
        stepCountImageView = UIImageView().then {
            bottomView.addSubview($0)
            $0.image = UIImage(named: "icPinColor")
            $0.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(25)
                $0.centerY.equalToSuperview()
            }
        }
        
        stepCountLabel = UILabel().then {
            bottomView.addSubview($0)
            $0.font = .systemFont(ofSize: 22, weight: .bold)
            $0.textColor = .black
            $0.text = "0"
            $0.snp.makeConstraints {
                $0.leading.equalTo(stepCountImageView.snp.trailing).offset(4)
                $0.centerY.equalTo(stepCountImageView)
            }
        }
        
        dateLabel = UILabel().then {
            bottomView.addSubview($0)
            $0.font = .systemFont(ofSize: 14, weight: .bold)
            $0.textAlignment = .right
            $0.textColor = .black
            $0.text = ""
            $0.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().offset(-25)
            }
        }
    }
    
    func changeStep(step: Int) {
        stepCountLabel.text = "\(step)"
    }
    
    func changeDate(date: Date) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월 dd일"
        let dateString = formatter.string(from: date)
        
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "ko_KR")
        timeFormatter.dateFormat = "hh시 mm분"
        let timeString = timeFormatter.string(from: Date())
        
        dateLabel.text = "\(dateString)  \(timeString)"
    }
    
    func changeDarkModeView(_ isDarkMode: Bool) {
        if isDarkMode {
            stepCountImageView.image = UIImage(named: "icPinWhite")
            stepCountLabel.textColor = .white
            bottomView.backgroundColor = .black
            dateLabel.textColor = .white
            imageLogoImageView.image = UIImage(named: "icLogoColorEn")
            backgroundView.IBborderColor = .black
        } else {
            stepCountImageView.image = UIImage(named: "icPinColor")
            stepCountLabel.textColor = .black
            imageLogoImageView.image = UIImage(named: "icLogoWhiteEn")
            dateLabel.textColor = .black
            bottomView.backgroundColor = .white
            backgroundView.IBborderColor = .white
        }
    }
}
