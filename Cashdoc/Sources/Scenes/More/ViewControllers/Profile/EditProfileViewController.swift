//
//  EditViewController.swift
//  Cashdoc
//
//  Created by Cashwalk on 2022/04/25.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class EditProfileViewController: CashdocViewController {
    
    private var profileImageView: UIImageView!
    private var nameTextField: UITextField!
    private var editPhotoButton: UIButton!
    private var countNameLabel: UILabel!
    private var guideLabel: UILabel!
    private var amendButton: UIButton!
    private var editViewModel = EditProfileViewModel()
    private var isBaseProfileView: Bool?
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        bind()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "프로필 수정"
        navigationController?.navigationBar.isHidden = false
    }
    
    func bind() {
        UserManager.shared.user
            .subscribe(onNext: { [weak self] user in
                guard let self = self else { return }
                self.nameTextField.text = user.nickname
                if let urlString = user.profileUrl, let url = URL(string: urlString) {
                    self.profileImageView.kf.setImage(with: url)
                } else {
                    self.profileImageView.image = UIImage(named: "imgPlaceholderProfile")
                }
            }).disposed(by: disposeBag)
        
        nameTextField.maxLength = 20

        amendButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                if let name = self.nameTextField.text?.trimmingCharacters(in: .whitespaces), name.isEmpty {
                    self.guideLabel.text = "이름은 빈칸(공백)으로 수정할 수 없습니다."
                    return
                }
                
                let service = CashdocProvider<ProfileUpdateService>()
                let profile = (self.profileImageView.image, self.nameTextField.text, self.isBaseProfileView)
                
                service.request(PutAccountModel.self, token: .putProfile(with: profile))
                    .subscribe(onSuccess: { [weak self] _ in
                        guard let self = self else { return }
                        self.navigationController?.popViewController(animated: true)
                    }, onFailure: { error in
                        print("error", error)
                    }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
        
        let input = EditProfileViewModel.Input(name: nameTextField.rx.text.orEmpty.asObservable(),
                                               editPhotoTrigger: editPhotoButton.rx.tap.asDriver())
        
        let output = editViewModel.transform(input: input)
        
        output.nameCount
            .bind(to: countNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.guide
            .bind(to: guideLabel.rx.text)
            .disposed(by: disposeBag)
    
        output.imageName
            .bind(to: profileImageView.rx.image)
            .disposed(by: disposeBag)
        
        output.isChangeBaseImg
            .bind { [weak self] isChange in
                Log.al("isChange = \(isChange)")
                guard let self = self else { return }
                self.isBaseProfileView = isChange
            }
            .disposed(by: disposeBag)
        
        output.amendButton
            .bind(to: amendButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    func setupView() {
        
        profileImageView = UIImageView().then {
            $0.image = UIImage(named: "imgPlaceholderProfile")
            $0.layer.cornerRadius = 60
            $0.clipsToBounds = true
            $0.contentMode = .scaleAspectFill
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(view.snp.top).offset(40)
                m.centerX.equalTo(view.snp.centerX)
                m.size.equalTo(120)
            }
        }
        
        editPhotoButton = UIButton().then {
            $0.backgroundColor = .yellowCw
            $0.layer.cornerRadius = 18
            $0.setImage(UIImage(named: "icEditBlack"), for: .normal)
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.trailing.equalTo(profileImageView.snp.trailing)
                m.bottom.equalTo(profileImageView.snp.bottom)
                m.width.equalTo(36)
                m.height.equalTo(36)
            }
        }
        
        let profileLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 16)
            $0.textColor = .brownGrayCw
            $0.text = "프로필 사진"
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(editPhotoButton.snp.bottom).offset(10)
                m.centerX.equalTo(view.snp.centerX)
            }
        }
        
        let nameLabel = UILabel().then {
            $0.setFontToBold(ofSize: 16)
            $0.textColor = .blackCw
            $0.text = "이름"
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(profileLabel).offset(38)
                m.leading.equalTo(view.snp.leading).offset(16)
            }
        }
        
        countNameLabel = UILabel().then {
            $0.textColor = .brownGrayCw
            $0.setFontToRegular(ofSize: 14)
            $0.text = "2/20"
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.centerY.equalTo(nameLabel.snp.centerY)
                m.trailing.equalTo(view.snp.trailing).offset(-16)
            }
        }
        
        nameTextField = UITextField().then {
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.lineGrayCw.cgColor
            $0.layer.cornerRadius = 4
            $0.clearButtonMode = .whileEditing
            $0.tintColor = .blackCw
            $0.addLeftPadding(width: 16)
            $0.tag = 0
            $0.font = .systemFont(ofSize: 14 * widthRatio)
            $0.placeholder = "2자에서 20자까지 입력 가능합니다."
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(nameLabel.snp.bottom).offset(10)
                m.leading.equalTo(nameLabel.snp.leading)
                m.trailing.equalTo(countNameLabel.snp.trailing)
                m.height.equalTo(48)
            }
        }
        
        guideLabel = UILabel().then {
            $0.textColor = .redCw
            $0.text = ""
            $0.setFontToRegular(ofSize: 12)
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(nameTextField.snp.bottom).offset(8)
                m.leading.equalTo(nameTextField.snp.leading)
            }
        }
        
        amendButton = UIButton().then {
            $0.layer.cornerRadius = 4
            $0.clipsToBounds = true
            $0.backgroundColor = .white
            $0.setBackgroundColor(.whiteCw, forState: .disabled)
            $0.setBackgroundColor(.yellowCw, forState: .normal)
            $0.setTitleColor(.veryLightPinkCw, for: .disabled)
            $0.setTitleColor(.blackCw, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            $0.titleLabel?.textAlignment = .center
            $0.setTitle("수정하기", for: .normal)
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.leading.trailing.equalTo(nameTextField)
                m.bottom.equalTo(view.snp.bottomMargin).offset(-16)
                m.height.equalTo(56)
            }
        }
        
        _ = UILabel().then {
            $0.textColor = .brownishGrayCw
            $0.numberOfLines = 0
            $0.setFontToRegular(ofSize: 12)
            $0.text = "타인에게 불쾌감을 주는 이름은 관리자가\n안내없이 임의로 변경할 수 있습니다."
            self.view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.centerX.equalTo(self.view.snp.centerX)
                m.bottom.equalTo(amendButton.snp.top).offset(-8)
            }
        }
    }
}
