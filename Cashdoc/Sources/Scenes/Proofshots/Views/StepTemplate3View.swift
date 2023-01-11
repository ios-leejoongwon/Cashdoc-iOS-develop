//
//  StepTemplate3View.swift
//  Cashwalk
//
//  Created by lovelycat on 2021/04/27.
//  Copyright © 2021 Cashwalk, Inc. All rights reserved.
//

import Foundation

final class StepTemplate3View: UIView {
    
    // MARK: - Properties
    
    // 탬플릿
    var stepCountLabel: UILabel!
    var stepIconImage: UIImageView!
    var imageLogoImageView: UIImageView!
    
    var dateLabel: UILabel!
    private var centerLineView: UIView!
    private var bottomView: UIView!
    
    // MARK: - Con(De)structor
    
    convenience init() {
        self.init(frame: .zero)
        
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
        
    }
    
    func changeStep(step: Int) {
        stepCountLabel.text = "\(step)걸음"
    }
    
    func changeDate(date: Date) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월 dd일"
        let dateString = formatter.string(from: date)
        dateLabel.text = dateString
    }
    
    func changeDarkModeView(_ isDarkMode: Bool) {
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
    }
}
