//
//  EasyAuthMainViewController.swift
//  Cashdoc
//
//  Created by 이아림 on 2022/12/14.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import UIKit
import ReactorKit

class EasyAuthMainVC: CashdocViewController, View {
    
    typealias Reactor = EasyAutoMainReactor
    
    private var btnKakao: UIButton!
    private var btnPass: UIButton!
    private var btnNaver: UIButton!
    private var btnKb: UIButton!
    private var btnShinhan: UIButton!
    private var btnToss: UIButton!
    private var btnPayco: UIButton!
    private var confirmButton: UIButton!
    
    private var type: AuthType = .none
    private var authPurpose: EasyAuthPurpose = .none
       
    init(authPurpose: EasyAuthPurpose) {
        super.init(nibName: nil, bundle: nil)
        self.authPurpose = authPurpose
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProperties()  
        self.reactor = EasyAutoMainReactor()
    }
    
    private func setProperties() {
        title = "간편인증 선택"
        view.backgroundColor = .white
        self.navigationController?.navigationBar.backgroundColor = .yellowCw
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    private func setupView() {
        
        let navibarHeight = topbarHeight + StatusBarSize.HEIGHT
        
        let titleLabel = UILabel().then {
            $0.textAlignment = .left
            $0.text = "간편인증 서비스를 선택해 주세요."
            $0.numberOfLines = 0
            $0.setFontToMedium(ofSize: 22)
            $0.textColor = UIColor.blackCw
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalToSuperview().offset(navibarHeight + 48)
                m.leading.trailing.equalToSuperview().inset(16)
            }
        }
        
        let stackV = UIStackView().then {
            $0.axis = .vertical
            $0.distribution = .fill
            $0.alignment = .center
            $0.spacing = 50
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(titleLabel.snp.bottom).offset(46)
                m.centerX.equalToSuperview()
            }
        }
        
        let stackH00 = UIStackView().then {
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.alignment = .center
            $0.spacing = 8
            stackV.addArrangedSubview($0)
        }
        
        let vKakao = UIView().then {
            $0.backgroundColor = .clear
            stackH00.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.width.equalTo(102)
            }
        }
        btnKakao = UIButton().then {
            $0.setImage(UIImage(named: "ic60KakaoSelect"), for: .selected)
            $0.setImage(UIImage(named: "ic60KakaoDefault"), for: .normal)
            vKakao.addSubview($0)
            $0.snp.makeConstraints { m in
                m.size.equalTo(60)
                m.top.centerX.equalToSuperview()
            }
        }
        
        _ = UILabel().then {
            $0.text = "카카오톡"
            $0.setFontToMedium(ofSize: 14)
            $0.textColor = UIColor.brownishGray
            vKakao.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(btnKakao.snp.bottom).offset(8)
                m.centerX.equalToSuperview()
            }
        }
        let vPass = UIView().then {
            $0.backgroundColor = .clear
            stackH00.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.width.equalTo(102)
            }
        }
        btnPass = UIButton().then {
            $0.setImage(UIImage(named: "ic60PassSelect"), for: .selected)
            $0.setImage(UIImage(named: "ic60PassDefault"), for: .normal)
            vPass.addSubview($0)
            $0.snp.makeConstraints { m in
                m.size.equalTo(60)
                m.top.centerX.equalToSuperview()
            }
        }
        
        let lbPass = UILabel().then {
            $0.text = "통신사패스"
            $0.setFontToMedium(ofSize: 14)
            $0.textColor = UIColor.brownishGray
            $0.numberOfLines = 0
            vPass.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(btnPass.snp.bottom).offset(8)
                m.centerX.equalToSuperview()
            }
        }
        
        _ = UILabel().then {
            $0.text = "(SKT, KT, LG U+)"
            $0.setFontToMedium(ofSize: 14)
            $0.textColor = UIColor.brownishGray
            $0.textAlignment = .center
            $0.numberOfLines = 0
            vPass.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(lbPass.snp.bottom)
                m.centerX.equalToSuperview()
            }
        }
        
        let vNaver = UIView().then {
            $0.backgroundColor = .clear
            stackH00.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.width.equalTo(102)
            }
        }
        btnNaver = UIButton().then {
            $0.setImage(UIImage(named: "ic60NaverSelect"), for: .selected)
            $0.setImage(UIImage(named: "ic60NaverDefault"), for: .normal)
            vNaver.addSubview($0)
            $0.snp.makeConstraints { m in
                m.size.equalTo(60)
                m.top.centerX.equalToSuperview()
            }
        }
        
        _ = UILabel().then {
            $0.text = "네이버"
            $0.setFontToMedium(ofSize: 14)
            $0.textColor = UIColor.brownishGray
            $0.numberOfLines = 0
            vNaver.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(btnNaver.snp.bottom).offset(8)
                m.centerX.equalToSuperview()
            }
        }
        
        let stackH01 = UIStackView().then {
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.alignment = .center
            $0.spacing = 8
            stackV.addArrangedSubview($0)
        }
        
        let vKb = UIView().then {
            $0.backgroundColor = .clear
            stackH01.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.width.equalTo(102)
            }
        }
        btnKb = UIButton().then {
            $0.setImage(UIImage(named: "ic60KbSelect"), for: .selected)
            $0.setImage(UIImage(named: "ic60KbDefault"), for: .normal)
            vKb.addSubview($0)
            $0.snp.makeConstraints { m in
                m.size.equalTo(60)
                m.top.centerX.equalToSuperview()
            }
        }
        
        let lbKb = UILabel().then {
            $0.text = "KB모바일"
            $0.setFontToMedium(ofSize: 14)
            $0.textColor = UIColor.brownishGray
            $0.numberOfLines = 0
            vKb.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(btnKb.snp.bottom).offset(8)
                m.centerX.equalToSuperview()
            }
        }
        _ = UILabel().then {
            $0.text = "인증서"
            $0.setFontToMedium(ofSize: 14)
            $0.textColor = UIColor.brownishGray
            $0.textAlignment = .center
            $0.numberOfLines = 0
            vKb.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(lbKb.snp.bottom)
                m.centerX.equalToSuperview()
            }
        }
        let vShinhan = UIView().then {
            $0.backgroundColor = .clear
            stackH01.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.width.equalTo(102)
            }
        }
        btnShinhan = UIButton().then {
            $0.setImage(UIImage(named: "ic60SinhanSelect"), for: .selected)
            $0.setImage(UIImage(named: "ic60SinhanDefault"), for: .normal)
            vShinhan.addSubview($0)
            $0.snp.makeConstraints { m in
                m.size.equalTo(60)
                m.top.centerX.equalToSuperview()
            }
        }
        
        _ = UILabel().then {
            $0.text = "신한은행"
            $0.setFontToMedium(ofSize: 14)
            $0.textColor = UIColor.brownishGray
            $0.numberOfLines = 0
            vShinhan.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(btnShinhan.snp.bottom).offset(8)
                m.centerX.equalToSuperview()
            }
        }
        
        let vToss = UIView().then {
            $0.backgroundColor = .clear
            stackH01.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.width.equalTo(102)
            }
        }
        btnToss = UIButton().then {
            $0.setImage(UIImage(named: "ic60TossSelect"), for: .selected)
            $0.setImage(UIImage(named: "ic60TossDefault"), for: .normal)
            vToss.addSubview($0)
            $0.snp.makeConstraints { m in
                m.size.equalTo(60)
                m.top.centerX.equalToSuperview()
            }
        }
        
        _ = UILabel().then {
            $0.text = "토스"
            $0.setFontToMedium(ofSize: 14)
            $0.textColor = UIColor.brownishGray
            $0.numberOfLines = 0
            vToss.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(btnToss.snp.bottom).offset(8)
                m.centerX.equalToSuperview()
            }
        }
        
        let stackH02 = UIStackView().then {
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.alignment = .center
            $0.spacing = 8
            stackV.addArrangedSubview($0)
        }
        
        let vPayco = UIView().then {
            $0.backgroundColor = .clear
            stackH02.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.width.equalTo(102)
            }
        }
        btnPayco = UIButton().then {
            $0.setImage(UIImage(named: "ic60PaycoSelect"), for: .selected)
            $0.setImage(UIImage(named: "ic60PaycoDefault"), for: .normal)
            vPayco.addSubview($0)
            $0.snp.makeConstraints { m in
                m.size.equalTo(60)
                m.top.centerX.equalToSuperview()
            }
        }
        
        _ = UILabel().then {
            $0.text = "페이코"
            $0.setFontToMedium(ofSize: 14)
            $0.textColor = UIColor.brownishGray
            $0.numberOfLines = 0
            vPayco.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(btnPayco.snp.bottom).offset(8)
                m.centerX.equalToSuperview()
            }
        }
        
        confirmButton = UIButton().then {
            $0.clipsToBounds = true
            $0.setBackgroundColor(.yellowCw, forState: .normal)
            $0.setBackgroundColor(.whiteCw, forState: .disabled)
            $0.setTitleColor(.black, for: .normal)
            $0.setTitleColor(.veryLightPinkCw, for: .disabled)
            $0.setTitle("다음", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            $0.layer.cornerRadius = 4
            $0.isEnabled = false
            $0.addTarget(self, action: #selector(clickConfirm), for: .touchUpInside)
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.height.equalTo(56)
                m.right.left.equalToSuperview().inset(16)
                m.bottom.equalTo(view.snp.bottomMargin).inset(16)
            }
        }
    }
    
    func bind(reactor: EasyAutoMainReactor) {
        btnKakao.rx.tap
            .map { Reactor.Action.clickKakao }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        btnPass.rx.tap
            .map { Reactor.Action.clickPass }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        btnNaver.rx.tap
            .map { Reactor.Action.clickNaver }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        btnKb.rx.tap
            .map { Reactor.Action.clickKB }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        btnShinhan.rx.tap
            .map { Reactor.Action.clickShinhan }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        btnToss.rx.tap
            .map { Reactor.Action.clickToss }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        btnPayco.rx.tap
            .map { Reactor.Action.clickPayco }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map(\.selectAuth)
            .distinctUntilChanged()
            .bind(onNext: { [weak self] type in
                guard let self = self else { return }
                self.setAuthButtons(type: type)
                
            }).disposed(by: disposeBag)
          
    }
     
    private func setAuthButtons(type: AuthType) {
        self.type = type
        switch type {
        case .kakao:
            btnKakao.isSelected = true
            btnPass.isSelected = false
            btnNaver.isSelected = false
            btnKb.isSelected = false
            btnShinhan.isSelected = false
            btnToss.isSelected = false
            btnPayco.isSelected = false
            confirmButton.isEnabled = true
            
        case .pass:
            btnKakao.isSelected = false
            btnPass.isSelected = true
            btnNaver.isSelected = false
            btnKb.isSelected = false
            btnShinhan.isSelected = false
            btnToss.isSelected = false
            btnPayco.isSelected = false
            confirmButton.isEnabled = true
            
        case .naver:
            btnKakao.isSelected = false
            btnPass.isSelected = false
            btnNaver.isSelected = true
            btnKb.isSelected = false
            btnShinhan.isSelected = false
            btnToss.isSelected = false
            btnPayco.isSelected = false
            confirmButton.isEnabled = true
            
        case .kb:
            btnKakao.isSelected = false
            btnPass.isSelected = false
            btnNaver.isSelected = false
            btnKb.isSelected = true
            btnShinhan.isSelected = false
            btnToss.isSelected = false
            btnPayco.isSelected = false
            confirmButton.isEnabled = true
            
        case .shinhan:
            btnKakao.isSelected = false
            btnPass.isSelected = false
            btnNaver.isSelected = false
            btnKb.isSelected = false
            btnShinhan.isSelected = true
            btnToss.isSelected = false
            btnPayco.isSelected = false
            confirmButton.isEnabled = true
            
        case .toss:
            btnKakao.isSelected = false
            btnPass.isSelected = false
            btnNaver.isSelected = false
            btnKb.isSelected = false
            btnShinhan.isSelected = false
            btnToss.isSelected = true
            btnPayco.isSelected = false
            confirmButton.isEnabled = true
            
        case .payco:
            btnKakao.isSelected = false
            btnPass.isSelected = false
            btnNaver.isSelected = false
            btnKb.isSelected = false
            btnShinhan.isSelected = false
            btnToss.isSelected = false
            btnPayco.isSelected = true
            confirmButton.isEnabled = true
            
        case .none:
            btnKakao.isSelected = false
            btnPass.isSelected = false
            btnNaver.isSelected = false
            btnKb.isSelected = false
            btnShinhan.isSelected = false
            btnToss.isSelected = false
            btnPayco.isSelected = false
            confirmButton.isEnabled = false
        }
    }
    
    @objc func clickConfirm() {
        GlobalFunction.FirLog(string: "간편인증1단계_\(self.type.name())_다음_클릭_iOS")
        let easyAuthInput = EasyAuthInputVC(authPurpose: self.authPurpose, type: self.type)
        GlobalFunction.pushVC(easyAuthInput, animated: true)
    }
}
 
