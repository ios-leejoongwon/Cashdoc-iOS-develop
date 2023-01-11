//
//  ProfileViewController.swift
//  Cashdoc
//
//  Created by Taejune Jung on 03/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Toast

final class ProfileViewController: CashdocViewController {
    
    // MARK: - Properties
    
    var viewModel: ProfileViewModel!
    private var pushShoppingAuthVC = PublishRelay<Void>()
    private var pushEditProfileVC = PublishRelay<Void>()
    
    // MARK: - UI Components

    private let profileView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
    }
    private let profileImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgPlaceholderProfile")
        $0.layer.cornerRadius = 60
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
    }
    private let nameLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .blackCw
        $0.setFontToMedium(ofSize: 16)
    }
    private let emailLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .brownishGrayCw
        $0.setFontToRegular(ofSize: 12)
    }
    private let editProfileButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setAttributedTitle(NSMutableAttributedString.attributedUnderlineTextWithoutScale(text: "프로필 수정", ofSize: 14, weight: .regular, alignment: .center), for: .normal)
    }
    private let detailView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
    }
    private let recommendTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGrayCw
        $0.text = "추천 코드"
    }
    private let recommendLabel =  UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .blackCw
    }
    private let pasteImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icCopy1Black")
    }
    private let pasteButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
    }
    private let registDateTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGrayCw
        $0.text = "가입 일시"
    }
    private let registLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .blackCw
    }
    
    private let genderTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGrayCw
        $0.text = "성별"
    }
    
    private let genderLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .blackCw
    }
    
    private let birthTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGrayCw
        $0.text = "생년월일"
    }
    
    private let birthLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .blackCw
    }
    
    private let certificationTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGrayCw
        $0.text = "본인 인증"
    }
    private let certificationButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 4
        $0.backgroundColor = .blackCw
        $0.setTitle("인증하기", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.setTitleColor(.white, for: .normal)
    }
    private let certificationLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .blueCw
        $0.text = "인증완료"
        $0.setFontToMedium(ofSize: 14)
    }
    private let logoutButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("로그아웃", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.setTitleColor(.blackCw, for: .normal)
        $0.layer.cornerRadius = 4
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.blackCw.cgColor
    }
    private let withdrawButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setAttributedTitle(NSMutableAttributedString.attributedUnderlineTextWithoutScale(text: "회원 탈퇴 ", ofSize: 14, weight: .regular, alignment: .center), for: .normal)
    }
    private let bottomWhiteView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        bindView()
        bindViewModel()
    
        view.addSubview(profileView)
        profileView.addSubview(profileImageView)
        profileView.addSubview(nameLabel)
        profileView.addSubview(emailLabel)
        profileView.addSubview(editProfileButton)
        view.addSubview(detailView)
        detailView.addSubview(recommendTitleLabel)
        detailView.addSubview(recommendLabel)
        detailView.addSubview(pasteImageView)
        detailView.addSubview(pasteButton)
        detailView.addSubview(registDateTitleLabel)
        detailView.addSubview(registLabel)
        detailView.addSubview(genderTitleLabel)
        detailView.addSubview(genderLabel)
        detailView.addSubview(birthTitleLabel)
        detailView.addSubview(birthLabel)
        detailView.addSubview(certificationTitleLabel)
        detailView.addSubview(certificationButton)
        detailView.addSubview(certificationLabel)
        detailView.addSubview(logoutButton)
        detailView.addSubview(withdrawButton)
        view.addSubview(bottomWhiteView)
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "계정 정보"
        self.navigationController?.navigationBar.isHidden = false
        
        UserManager.shared.getUser()
    }
    
    // MARK: - Binding
    
    private func bindView() {
        
        editProfileButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.pushEditProfileVC.accept(())
            })
        .disposed(by: disposeBag)
        
        pasteButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let pasteboard = UIPasteboard.general
                pasteboard.string = self.recommendLabel.text
                self.view.makeToastWithCenter("내 추천 코드가 복사되었습니다.", duration: 2.0, completion: nil)
            })
        .disposed(by: disposeBag)
        
        certificationButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                let confirmAction = UIAlertAction(title: "인증하기", style: .default) { [weak self] (_) -> Void in
                    guard let self = self else {return}
                    self.pushShoppingAuthVC.accept(())
                }
                self.alert(title: "본인인증 진행 안내", message: "유저의 캐시보호 목적으로\n적립된 캐시를 사용하기 전에\n최초 1회에 한해 본인인증을\n필수로  진행하고 있습니다. ", preferredStyle: .alert, actions: [cancelAction, confirmAction])
            })
        .disposed(by: disposeBag)
        
    }
    
    private func bindViewModel() {
        // Input
        
        let input = type(of: self.viewModel).Input(certificateTrigger: pushShoppingAuthVC.asDriverOnErrorJustNever(),
                                              logoutTrigger: logoutButton.rx.tap.asDriver(),
                                                   withdrawTrigger: withdrawButton.rx.tap.asDriver(),
                                                   editProfileTrigger: pushEditProfileVC.asDriverOnErrorJustNever())
        
        // Output
        _ = viewModel.transform(input: input)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .grayTwoCw
        
        UserManager.shared.user
            .subscribe(onNext: { [weak self] user in
                guard let self = self else { return }
                if user.nickname.trimmingCharacters(in: .whitespaces).isEmpty {
                    self.nameLabel.text = "닉네임을 입력해주세요"
                } else {
                    self.nameLabel.text = user.nickname
                }
                
                self.emailLabel.text = user.email ?? "-"
                self.recommendLabel.text = user.code
                self.registLabel.text = (user.createdAt ?? 0).toDateFormatFromTimeStamp
                
                if let urlString = user.profileUrl, let url = URL(string: urlString) {
                    self.profileImageView.kf.setImage(with: url)
                } else {
                    self.profileImageView.image = UIImage(named: "imgPlaceholderProfile")
                }
                
                switch user.gender {
                case "m":
                    self.genderLabel.text = "남자"
                case "f":
                    self.genderLabel.text = "여자"
                default:
                    self.genderLabel.text = "-"
                }
                
                if let birth = Int(user.birth ?? "0") {
                    self.birthLabel.text = birth.toYYYYmmddFormatFromTimeStamp
                } else {
                    self.birthLabel.text = "-"
                }
                
                if let isAuth = user.authPhone {
                    if isAuth {
                        self.certificationButton.isHidden = true
                        self.certificationLabel.isHidden = false
                    } else {
                        self.certificationButton.isHidden = false
                        self.certificationLabel.isHidden = true
                    }
                } else {
                    self.certificationButton.isHidden = false
                    self.certificationLabel.isHidden = true
                }
            })
        .disposed(by: disposeBag)
    }
    
}

// MARK: - Layout

extension ProfileViewController {
    
    private func layout() {
//        422 261 8 ==691
        let profileViewHeight = ScreenSize.HEIGHT * 0.36
        profileView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        profileView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        profileView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        profileView.heightAnchor.constraint(equalToConstant: profileViewHeight).isActive = true
        
        profileImageView.topAnchor.constraint(equalTo: profileView.topAnchor, constant: profileViewHeight * 0.075).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: profileView.centerXAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 12).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: profileView.centerXAnchor).isActive = true
        
        emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2).isActive = true
        emailLabel.centerXAnchor.constraint(equalTo: profileView.centerXAnchor).isActive = true
        
        editProfileButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 10).isActive = true
        editProfileButton.centerXAnchor.constraint(equalTo: profileView.centerXAnchor).isActive = true
        
        detailView.topAnchor.constraint(equalTo: profileView.bottomAnchor, constant: 8).isActive = true
        detailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        detailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        detailView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        recommendTitleLabel.topAnchor.constraint(equalTo: detailView.topAnchor, constant: 32).isActive = true
        recommendTitleLabel.leadingAnchor.constraint(equalTo: detailView.leadingAnchor, constant: 24).isActive = true
        recommendTitleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        recommendLabel.topAnchor.constraint(equalTo: recommendTitleLabel.topAnchor).isActive = true
        recommendLabel.leadingAnchor.constraint(equalTo: recommendTitleLabel.trailingAnchor, constant: 45).isActive = true
        recommendLabel.centerYAnchor.constraint(equalTo: recommendTitleLabel.centerYAnchor).isActive = true
        
        pasteImageView.centerYAnchor.constraint(equalTo: recommendLabel.centerYAnchor).isActive = true
        pasteImageView.leadingAnchor.constraint(equalTo: recommendLabel.trailingAnchor, constant: 8).isActive = true
        pasteImageView.widthAnchor.constraint(equalTo: pasteImageView.heightAnchor).isActive = true
        pasteImageView.widthAnchor.constraint(equalToConstant: 18).isActive = true
        
        pasteButton.topAnchor.constraint(equalTo: recommendLabel.topAnchor).isActive = true
        pasteButton.leadingAnchor.constraint(equalTo: recommendLabel.leadingAnchor, constant: 0).isActive = true
        pasteButton.trailingAnchor.constraint(equalTo: pasteImageView.trailingAnchor).isActive = true
        pasteButton.bottomAnchor.constraint(equalTo: recommendLabel.bottomAnchor).isActive = true
        
        registDateTitleLabel.topAnchor.constraint(equalTo: recommendTitleLabel.bottomAnchor, constant: 24).isActive = true
        registDateTitleLabel.leadingAnchor.constraint(equalTo: recommendTitleLabel.leadingAnchor).isActive = true
        registDateTitleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        registLabel.topAnchor.constraint(equalTo: registDateTitleLabel.topAnchor).isActive = true
        registLabel.leadingAnchor.constraint(equalTo: recommendLabel.leadingAnchor).isActive = true
         
        genderTitleLabel.topAnchor.constraint(equalTo: registDateTitleLabel.bottomAnchor, constant: 24).isActive = true
        genderTitleLabel.leadingAnchor.constraint(equalTo: registDateTitleLabel.leadingAnchor).isActive = true
        genderTitleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        genderLabel.topAnchor.constraint(equalTo: genderTitleLabel.topAnchor).isActive = true
        genderLabel.leadingAnchor.constraint(equalTo: recommendLabel.leadingAnchor).isActive = true
        
        birthTitleLabel.topAnchor.constraint(equalTo: genderTitleLabel.bottomAnchor, constant: 24).isActive = true
        birthTitleLabel.leadingAnchor.constraint(equalTo: genderTitleLabel.leadingAnchor).isActive = true
        birthTitleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        birthLabel.topAnchor.constraint(equalTo: birthTitleLabel.topAnchor).isActive = true
        birthLabel.leadingAnchor.constraint(equalTo: recommendLabel.leadingAnchor).isActive = true
        
        certificationTitleLabel.topAnchor.constraint(equalTo: birthTitleLabel.bottomAnchor, constant: 24).isActive = true
        certificationTitleLabel.leadingAnchor.constraint(equalTo: recommendTitleLabel.leadingAnchor).isActive = true
        certificationTitleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        certificationButton.centerYAnchor.constraint(equalTo: certificationTitleLabel.centerYAnchor).isActive = true
        certificationButton.leadingAnchor.constraint(equalTo: recommendLabel.leadingAnchor).isActive = true
        certificationButton.widthAnchor.constraint(equalToConstant: 96).isActive = true
        certificationButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        certificationLabel.centerYAnchor.constraint(equalTo: certificationTitleLabel.centerYAnchor).isActive = true
        certificationLabel.leadingAnchor.constraint(equalTo: birthLabel.leadingAnchor).isActive = true
        
        logoutButton.centerXAnchor.constraint(equalTo: detailView.centerXAnchor).isActive = true
        logoutButton.leadingAnchor.constraint(equalTo: detailView.leadingAnchor, constant: 16).isActive = true
        logoutButton.trailingAnchor.constraint(equalTo: detailView.trailingAnchor, constant: -16).isActive = true
        logoutButton.bottomAnchor.constraint(equalTo: withdrawButton.topAnchor, constant: -20).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        withdrawButton.centerXAnchor.constraint(equalTo: detailView.centerXAnchor).isActive = true
        withdrawButton.bottomAnchor.constraint(equalTo: detailView.bottomAnchor, constant: -24).isActive = true
        withdrawButton.widthAnchor.constraint(equalToConstant: 56).isActive = true
        withdrawButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        bottomWhiteView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        bottomWhiteView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomWhiteView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomWhiteView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
}
