//
//  AppPermissionViewController.swift
//  Cashdoc
//
//  Created by DongHeeKang on 24/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit

final class AppPermissionViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private lazy var viewModel: AppPermissionViewModel = .init(navigator: .init(parentViewController: self))
    
    // MARK: - UI Components
    
    private let okButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("확인했습니다.", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setBackgroundColor(.whiteCw, forState: .disabled)
        button.setBackgroundColor(.yellowCw, forState: .normal)
        button.setTitleColor(.veryLightPinkCw, for: .disabled)
        button.setTitleColor(.blackCw, for: .normal)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        return button
    }()
    
    // MARK: - Con(De)structor
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: CashdocViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProperties()
        bindViewModel()
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        // Input
        let okTrigger = okButton.rx.tap.asDriver()
        let input = type(of: self.viewModel).Input(okTrigger: okTrigger)
        
        // Output
        _ = viewModel.transform(input: input)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
    }
    
    private func setupView() {
         
        let titleLabel = UILabel().then {
            $0.numberOfLines = 0
            $0.text = "앱 접근권한 안내"
            $0.textAlignment = .center
            $0.setFontToMedium(ofSize: 18)
            $0.textColor = .blackCw
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.centerX.equalToSuperview()
                m.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(44)
            }
        }
        
        let subTitleLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.numberOfLines = 0
            $0.text = "캐시닥 사용을 위해서는 접근 권한 허용이 필요합니다."
            $0.textAlignment = .center
            $0.setFontToRegular(ofSize: 12)
            $0.textColor = .brownishGrayCw
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.centerX.equalToSuperview()
                m.top.equalTo(titleLabel.snp.bottom).offset(8)
                m.height.equalTo(24)
                
            }
        }
          
        let separateView = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = UIColor.fromRGB(236, 236, 236)
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.lessThanOrEqualTo(subTitleLabel.snp.bottom).offset(32)
                m.centerX.equalToSuperview()
                m.left.right.equalToSuperview().inset(40)
                m.height.equalTo(0.5)
            }
        }
         
        let savePermissionView = PermissionView(title: "알림접근 (선택)", subTitle: "캐시닥의 푸시메시지를 수신", imageName: "icAlarmBlack").then {
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.lessThanOrEqualTo(separateView.snp.bottom).offset(40)
                m.right.left.equalToSuperview().inset(40)
            }
        }
        
        let phonePermissionView = PermissionView(title: "동작 및 피트니스 (선택)", subTitle: "사용자의 걸음수 확인", imageName: "icSalaryBlack").then {
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(savePermissionView.snp.bottom).offset(4)
                m.right.left.equalToSuperview().inset(40)
            }
        }
        let locationPermissionView = PermissionView(title: "위치정보 (선택)", subTitle: "날씨 및 서비스 위치 확인", imageName: "icPlaceBlack").then {
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(phonePermissionView.snp.bottom).offset(4)
                m.right.left.equalToSuperview().inset(40)
            }
        }
        
        let cameraPermissionView = PermissionView(title: "카메라 (선택)", subTitle: "실비보험청구, 인증샷 촬영 시 사진촬영", imageName: "icCameraBlack").then {
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(locationPermissionView.snp.bottom).offset(4)
                m.left.right.equalToSuperview().inset(40)
            }
        }
        
        _ = PermissionView(title: "앨범 (선택)", subTitle: "실비보험청구, 인증샷 촬영 시 사진첨부", imageName: "icFileBlack").then {
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(cameraPermissionView.snp.bottom).offset(4)
                m.left.right.equalToSuperview().inset(40)
            }
        }
          
        _ = okButton.then {
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                okButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
                m.left.right.equalToSuperview().inset(16)
                m.height.equalTo(56)
                m.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            }
        }
    }
    
}
  
