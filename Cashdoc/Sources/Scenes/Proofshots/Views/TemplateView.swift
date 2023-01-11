//
//  TemplateView.swift
//  Cashdoc
//
//  Created by 이아림 on 2022/07/14.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import Foundation
import UIKit

final class TemplateView: UIView {
    
    // MARK: - Properties
    
    // 탬플릿
    var typeNum: Int = 0
    
    private var imageLogoImageView: UIImageView!
    private var logoTextImageView: UIImageView!
    
    private var dateLabel: UILabel!
    private var timeLabel: UILabel!
    private var stepCountLabel: UILabel!
    private var stepIconImage: UIImageView!
     
    private var centerLineView: UIView!
    private var bottomView: UIView!
    private var backgroundView: UIView!
    private var stepCountImageView: UIImageView!
     
    private var stepTextLabel: UILabel!
    private var circleView: UIView!
    
    // MARK: - Con(De)structor
    
    convenience init(typeNum: Int) {
        self.init(frame: .zero)
        
        self.typeNum = typeNum
        self.setupView(type: typeNum)
    }
    
    func setupView(type: Int) {
        switch typeNum {
        case 1:
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
            
        case 2:
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
        case 3:
            imageLogoImageView = UIImageView().then {
                self.addSubview($0)
                $0.image = UIImage(named: "icLogoWhiteEn")
                $0.snp.makeConstraints {
                    $0.top.equalToSuperview().offset(18)
                    $0.centerX.equalToSuperview()
                }
            }
            centerLineView = UIView().then {
                self.addSubview($0)
                $0.backgroundColor = .white
                $0.snp.makeConstraints {
                    $0.bottom.equalToSuperview().offset(-36)
                    $0.height.equalTo(1)
                    $0.leading.trailing.equalToSuperview().inset(18)
                }
            }
            
            bottomView = UIView().then {
                self.addSubview($0)
                $0.backgroundColor = .white
                $0.IBcornerRadius = 19
                $0.snp.makeConstraints {
                    $0.bottom.equalToSuperview().offset(-18)
                    $0.centerX.equalToSuperview()
                    $0.height.equalTo(38)
                    $0.width.equalTo(157)
                }
            }
            
            stepCountLabel = UILabel().then {
                bottomView.addSubview($0)
                $0.font = .systemFont(ofSize: 18, weight: .bold)
                $0.textColor = .black
                $0.text = "0걸음"
                $0.snp.makeConstraints {
                    $0.centerX.equalToSuperview().offset(10)
                    $0.centerY.equalToSuperview()
                }
            }
            
            stepIconImage = UIImageView().then {
                bottomView.addSubview($0)
                $0.image = UIImage(named: "icPinColor")
                $0.snp.makeConstraints {
                    $0.centerY.equalToSuperview()
                    $0.trailing.equalTo(stepCountLabel.snp.leading).offset(-4)
                    $0.width.equalTo(16)
                    $0.height.equalTo(16)
                }
            }
            
            dateLabel = UILabel().then {
                self.addSubview($0)
                $0.font = .systemFont(ofSize: 14, weight: .medium)
                $0.textAlignment = .center
                $0.textColor = .white
                $0.text = ""
                $0.snp.makeConstraints {
                    $0.bottom.equalTo(bottomView.snp.top).offset(-8)
                    $0.centerX.equalToSuperview()
                }
            }
            
        case 4:
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
            
        case 5:
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
            
        case 6:
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
            
        case 7:
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
            
        case 8:
            logoTextImageView = UIImageView().then {
                self.addSubview($0)
                $0.image = UIImage(named: "icLogoWhiteText")
                $0.snp.makeConstraints {
                    $0.top.leading.equalToSuperview().offset(18)
                }
            }
            
            imageLogoImageView = UIImageView().then {
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
            
        case 9:
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
            
        case 10:
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
        
        stepTextLabel = UILabel().then {
            stackView.addArrangedSubview($0)
            $0.font = .systemFont(ofSize: 14, weight: .medium)
            $0.numberOfLines = 1
            $0.textColor = .black
            $0.text = "걸음"
        }
            
        case 11:
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
        default:
            break
            
        }
    }
    
    func changeStep(step: Int) {
        switch typeNum {
        case 2, 8:
            stepCountLabel.text = "\(step) 걸음"
        case 3:
            stepCountLabel.text = "\(step)걸음"
        case 5, 7, 10:
            stepCountLabel.text = "\(step)"
        case 9:
            let strStep = "\(step.commaValue)걸음"
            let range = (strStep as NSString).range(of: "걸음")
            let attributedString = NSMutableAttributedString(string: strStep)
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 44, weight: .medium), range: range)
            stepCountLabel.attributedText = attributedString
        default:
            break
        }
    }
    
    func changeDate(date: Date) {
        switch typeNum {
        case 1:
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
            
        case 2, 7, 8:
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
            
        case 3:
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy년 MM월 dd일"
            let dateString = formatter.string(from: date)
            dateLabel.text = dateString
            
        case 4:
            let dateformatter = DateFormatter()
            dateformatter.locale = Locale(identifier: "default")
            dateformatter.dateFormat = "MMM d, yyyy"
            let dateString = dateformatter.string(from: date)
            dateLabel.text = dateString
            
        case 5:
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy년 MM월 dd일"
            let dateString = formatter.string(from: date)
            
            let timeFormatter = DateFormatter()
            timeFormatter.locale = Locale(identifier: "ko_KR")
            timeFormatter.dateFormat = "hh시 mm분"
            let timeString = timeFormatter.string(from: Date())
            
            dateLabel.text = "\(dateString)  \(timeString)"
            
        case 6:
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy / MM / dd"
            let dateString = formatter.string(from: date)
            dateLabel.text = dateString
            
        case 9, 10, 11:
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
            
        default:
            break
        }
        
    }
    
    func changeDarkModeView(_ isDarkMode: Bool) {
        switch typeNum {
        case 1:
            if isDarkMode {
                imageLogoImageView.image = UIImage(named: "icLogoColorEn")
                dateLabel.textColor = .black
                timeLabel.textColor = .black
            } else {
                imageLogoImageView.image = UIImage(named: "icLogoWhiteEn")
                dateLabel.textColor = .white
                timeLabel.textColor = .white
            }
            
        case 2:
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
            
        case 3:
            if isDarkMode {
                centerLineView.backgroundColor = .black
                stepCountLabel.textColor = .white
                stepIconImage.image = UIImage(named: "icPinWhite")
                dateLabel.textColor = .black
                bottomView.backgroundColor = .black
                imageLogoImageView.image = UIImage(named: "icLogoColorEn")
                centerLineView.backgroundColor = .black
            } else {
                centerLineView.backgroundColor = .white
                stepCountLabel.textColor = .black
                stepIconImage.image = UIImage(named: "icPinColor")
                dateLabel.textColor = .white
                bottomView.backgroundColor = .white
                imageLogoImageView.image = UIImage(named: "icLogoWhiteEn")
                centerLineView.backgroundColor = .white
            }
            
        case 4, 6, 11:
            if isDarkMode {
                imageLogoImageView.image = UIImage(named: "icLogoColorEn")
                dateLabel.textColor = .black
            } else {
                imageLogoImageView.image = UIImage(named: "icLogoWhiteEn")
                dateLabel.textColor = .white
            }
            
        case 5:
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
            
        case 7:
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
            
        case 8:
            if isDarkMode {
                logoTextImageView.image = UIImage(named: "icLogoColorText")
                imageLogoImageView.image = UIImage(named: "ic24HealthWhiteCopy")
                stepCountLabel.textColor = .black
                dateLabel.textColor = .black
                timeLabel.textColor = .black
            } else {
                logoTextImageView.image = UIImage(named: "icLogoWhiteText")
                imageLogoImageView.image = UIImage(named: "icHealthWhite")
                stepCountLabel.textColor = .white
                dateLabel.textColor = .white
                timeLabel.textColor = .white
            }
            
        case 9:
            if isDarkMode {
                stepCountLabel.textColor = .black
                imageLogoImageView.image = UIImage(named: "icLogoColorEn")
                dateLabel.textColor = .black
            } else {
                stepCountLabel.textColor = .white
                imageLogoImageView.image = UIImage(named: "icLogoWhiteEn")
                dateLabel.textColor = .white
            }
            
        case 10:
            if isDarkMode {
                circleView.backgroundColor = .black
                stepCountLabel.textColor = .white
                stepTextLabel.textColor = .white
                imageLogoImageView.image = UIImage(named: "icLogoColorEn")
                dateLabel.textColor = .black
            } else {
                circleView.backgroundColor = .white
                stepCountLabel.textColor = .black
                stepTextLabel.textColor = .black
                imageLogoImageView.image = UIImage(named: "icLogoWhiteEn")
                dateLabel.textColor = .white
            }
    
        default:
            break
        }
    }
}
