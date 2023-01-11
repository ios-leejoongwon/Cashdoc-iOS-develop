//
//  StepTemplate9View.swift
//  Cashwalk
//
//  Created by lovelycat on 2021/04/27.
//  Copyright © 2021 Cashwalk, Inc. All rights reserved.
//

import Foundation
import UIKit

final class StepTemplate9View: UIView {
    
    // MARK: - Properties
    
    // 탬플릿
    var imageLogoImageView: UIImageView!
    var stepCountLabel: UILabel!
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
        
        let centerStackView = UIStackView().then {
            self.addSubview($0)
            $0.axis = .vertical
            $0.distribution = .fill
            $0.alignment = .center
            $0.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
        }
        
        stepCountLabel = UILabel().then {
            centerStackView.addArrangedSubview($0)
            $0.font = .systemFont(ofSize: 44, weight: .bold)
            $0.textColor = .white
            let step = 0
            let strStep = "\(step)걸음"
            let range = (strStep as NSString).range(of: "걸음")
            let attributedString = NSMutableAttributedString(string: strStep)
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 44, weight: .medium), range: range)
            $0.attributedText = attributedString 
        }
          
        dateLabel = UILabel().then {
            centerStackView.addArrangedSubview($0)
            $0.font = .systemFont(ofSize: 18, weight: .medium)
            $0.textAlignment = .center
            $0.textColor = .white
            $0.text = ""
        }
         
    }
    
    func changeStep(step: Int) { 
        let strStep = "\(step.commaValue)걸음"
        let range = (strStep as NSString).range(of: "걸음")
        let attributedString = NSMutableAttributedString(string: strStep)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 44, weight: .medium), range: range)
        stepCountLabel.attributedText = attributedString
    }
    
    func changeDate(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy.MM.dd"
        dateFormatter.amSymbol = "a.m"
        dateFormatter.pmSymbol = "p.m"
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
            stepCountLabel.textColor = .black
            imageLogoImageView.image = UIImage(named: "icLogoColorEn")
            dateLabel.textColor = .black
        } else {
            stepCountLabel.textColor = .white
            imageLogoImageView.image = UIImage(named: "icLogoWhiteEn")
            dateLabel.textColor = .white 
        }
    }
}
