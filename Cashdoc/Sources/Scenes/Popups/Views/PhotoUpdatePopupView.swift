//
//  PhotoUpdatePopupView.swift
//  Cashdoc
//
//  Created by Cashwalk on 2022/04/27.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import Foundation

final class PhotoUpdatePopupView: BasePopupView {
    private var importPhotoButton: UIButton!
    private var changeBasicImageButton: UIButton!
    private var cancelButton: UIButton!
    private var photoPopupViewModel = PhotoUpdatePopupViewModel()
    private let picker = UIImagePickerController()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        bindView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
        let containerView = UIView().then {
            addSubview($0)
            $0.snp.makeConstraints { m in
                m.leading.trailing.equalToSuperview().inset(80)
                m.height.equalTo(100)
                m.centerY.centerX.equalToSuperview()
            }
        }
        
        _ = UIView().then {
            $0.backgroundColor = .grayCw
            containerView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.leading.top.bottom.trailing.equalTo(containerView)
            }
        }
        
        importPhotoButton = UIButton().then {
            $0.setTitle("사진첩에서 가져오기", for: .normal)
            $0.setTitleColor(.blackCw, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            $0.backgroundColor = .white
            containerView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.leading.top.trailing.equalTo(containerView)
            }
        }
        
        changeBasicImageButton = UIButton().then {
            $0.setTitle("기본 이미지로 변경", for: .normal)
            $0.setTitleColor(.blackCw, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            $0.backgroundColor = .white
            containerView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.leading.trailing.equalTo(containerView)
                m.top.equalTo(importPhotoButton.snp.bottom).offset(1)
            }
        }
        
        cancelButton = UIButton().then {
            $0.setTitle("닫기", for: .normal)
            $0.setTitleColor(.redCw, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            $0.backgroundColor = .white
            containerView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.leading.bottom.trailing.equalTo(containerView)
                m.top.equalTo(changeBasicImageButton.snp.bottom).offset(1)
            }
        }
    }
    
    private func bindView() {
        importPhotoButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.dismissView()
                GlobalFunction.presentVC(PhotoUpdateViewController(), animated: true)
            })
            .disposed(by: disposeBag)
        
        changeBasicImageButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.photoPopupViewModel.changeBasicImage()
                self.dismissView()
            })
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.dismissView()
            })
            .disposed(by: disposeBag)
    }
}
