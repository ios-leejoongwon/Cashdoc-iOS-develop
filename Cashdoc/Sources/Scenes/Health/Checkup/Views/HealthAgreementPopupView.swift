//
//  HealthAgreementPopupView.swift
//  Cashdoc
//
//  Created by 이아림 on 2022/12/13.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol HealthAgreementPopupViewDelegate: NSObjectProtocol {
    func confirmClick(_ view: HealthAgreementPopupView)
}

class HealthAgreementPopupView: CashdocViewController {
    
    var backButton: UIButton!
    var confirmButton: UIButton!
    var check01: UIButton!
    var check02: UIButton!
    var arrow01: UIButton!
    var arrow02: UIButton!
    
    private let obvCheck01 = BehaviorRelay<Bool>(value: false)
    private let obvCheck02 = BehaviorRelay<Bool>(value: false)
    
    weak var delegate: HealthAgreementPopupViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindView()
    }
    
    private func setupView() {
        
        view.backgroundColor = .black.withAlphaComponent(0.5)
        let backgroundView = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 4
            $0.clipsToBounds = true
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.width.equalTo(300)
                m.height.equalTo(485)
                m.center.equalToSuperview()
            }
        }
        
        backButton = UIButton().then {
            $0.setImage(UIImage(named: "icCloseBlack"), for: .normal)
            backgroundView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.width.height.equalTo(24)
                m.trailing.top.equalToSuperview().inset(16)
            }
        }
        
        let titleLabel = UILabel().then {
            $0.textAlignment = .center
            $0.text = "건강서비스 이용을 위해\n동의해 주세요!"
            $0.numberOfLines = 2
            $0.setFontToMedium(ofSize: 24)
            $0.textColor = UIColor.blackCw
            $0.translatesAutoresizingMaskIntoConstraints = false
            backgroundView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(backgroundView.snp.top).offset(48)
                m.leading.trailing.equalToSuperview().inset(16)
            }
        }
        
        let contentLabel = UILabel().then {
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.setFontToMedium(ofSize: 14)
            $0.textColor = UIColor.brownishGrayCw
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = "미동의 하시면 이용이 어려워요.😭"
            backgroundView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(titleLabel.snp.bottom).offset(14)
                m.centerX.equalToSuperview()
            }
        }
        
        let centerImg = UIImageView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.image = UIImage(named: "imgBigLottoPopUp")
            $0.backgroundColor = UIColor.clear
            backgroundView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.centerX.equalToSuperview()
                m.top.equalTo(contentLabel.snp.bottom).offset(12)
            }
        }
        
        let stackV = UIStackView().then {
            $0.axis = .vertical
            $0.distribution = .fill
            $0.alignment = .center
            $0.spacing = 8
            backgroundView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.left.right.equalToSuperview().inset(24)
                m.height.equalTo(90)
                m.top.equalTo(centerImg.snp.bottom).offset(13)
            }
        }
        
        let stackH00 = UIStackView().then {
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.alignment = .center
            $0.spacing = 8
            stackV.addArrangedSubview($0)
        }
        
        check01 = UIButton().then {
            $0.setImage(UIImage(named: "icCheckBoxEnabled"), for: .selected)
            $0.setImage(UIImage(named: "icCheckBoxDefault"), for: .normal)
            stackH00.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.width.equalTo(24)
            }
        }
        
        _ = UILabel().then {
            $0.text = "개인정보 수집·이용 동의(필수)"
            $0.textColor = .brownishGray
            $0.setFontToMedium(ofSize: 14)
            stackH00.addArrangedSubview($0)
        }
        
        arrow01 = UIButton().then {
            $0.setImage(UIImage(named: "icArrow01StyleRightGray"), for: .normal)
            stackH00.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.equalTo(20)
            }
        }
        
        let stackH01 = UIStackView().then {
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.alignment = .center
            $0.spacing = 8
            stackV.addArrangedSubview($0)
        }
        
        check02 = UIButton().then {
            $0.setImage(UIImage(named: "icCheckBoxEnabled"), for: .selected)
            $0.setImage(UIImage(named: "icCheckBoxDefault"), for: .normal)
            stackH01.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.width.equalTo(24)
            }
        }
        
        _ = UILabel().then {
            $0.text = "민감정보 수집·이용 동의(필수)"
            $0.textColor = .brownishGray
            $0.setFontToMedium(ofSize: 14)
            stackH01.addArrangedSubview($0)
        }
        
        arrow02 = UIButton().then {
            $0.setImage(UIImage(named: "icArrow01StyleRightGray"), for: .normal)
            stackH01.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.equalTo(20)
            }
        }
        
        confirmButton = UIButton().then {
            $0.clipsToBounds = true
            $0.setBackgroundColor(.yellowCw, forState: .normal)
            $0.setBackgroundColor(.whiteCw, forState: .disabled)
            $0.setTitleColor(.black, for: .normal)
            $0.setTitleColor(.veryLightPinkCw, for: .disabled)
            $0.setTitle("확인", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            $0.layer.cornerRadius = 4
            $0.isEnabled = false
            backgroundView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.height.equalTo(56)
                m.bottom.equalTo(backgroundView.snp.bottom).offset(-16)
                m.leading.equalTo(backgroundView.snp.leading).offset(16)
                m.trailing.equalTo(backgroundView.snp.trailing).offset(-16)
            }
        }
        
    }
    
    private func bindView() {
        backButton.rx.tap.bind { [weak self] (_) in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }.disposed(by: disposeBag)
        
        check01.rx.tap.bind { [weak self] (_) in
            guard let self = self else { return }
            self.check01.isSelected = !self.check01.isSelected
            self.obvCheck01.accept(self.check01.isSelected)
        }.disposed(by: disposeBag)
        
        check02.rx.tap.bind { [weak self] (_) in
            guard let self = self else { return }
            self.check02.isSelected = !self.check02.isSelected
            self.obvCheck02.accept(self.check02.isSelected)
        }.disposed(by: disposeBag)
        
        arrow01.rx.tap.bind { [weak self] (_) in
            guard let self = self else { return }
            self.dismiss(animated: false)
            GlobalFunction.pushToWebViewController(title: "건강 개인정보 수집 및 이용", url: API.SENSITIVE_ESSENTIAL_URL, webType: .terms)
            
        }.disposed(by: disposeBag)
        
        arrow02.rx.tap.bind { [weak self] (_) in
            guard let self = self else { return }
            self.dismiss(animated: false)
            GlobalFunction.pushToWebViewController(title: "건강 민감정보 수집 및 이용", url: API.SENSITIVE_URL, webType: .terms)
            
        }.disposed(by: disposeBag)
        
        Observable.combineLatest(obvCheck01, obvCheck02).subscribe { [weak self] (isCheck01, isCheck02) in
            guard let self = self else { return }
            let isValid = isCheck01 && isCheck02
            if isValid {
                self.confirmButton.isEnabled = true
            } else {
                self.confirmButton.isEnabled = false
            }
        }.disposed(by: disposeBag)
        
        confirmButton.rx.tap.bind { [weak self] (_) in
            guard let self = self else { return }
            self.delegate?.confirmClick(self)
        }.disposed(by: disposeBag)
    }
}
