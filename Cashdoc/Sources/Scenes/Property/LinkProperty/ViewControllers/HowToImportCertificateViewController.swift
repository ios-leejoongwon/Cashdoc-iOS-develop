//
//  HowToImportCertificateViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 07/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Toast

enum HowToLinkType {
    case 하나씩연결
    case 한번에연결
}

final class HowToImportCertificateViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private var viewModel: HowToImportCertificateViewModel!
    private var linkType: HowToLinkType!
    private var fCodeName: String?
    
    // MARK: - UI Components
    
    private let descCertView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayTwoCw
        $0.clipsToBounds = true
    }
    private let descCertLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .brownishGrayCw
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = "등록된 공동인증서는 안전하게 보호되며\n캐시닥 서비스 연동에 사용됩니다."
    }
    private let certNumView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayThreeCw
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 4
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.grayCw.cgColor
    }
    private let certNumTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .blackCw
        $0.textAlignment = .center
        $0.text = "인증번호"
    }
    private let certNumLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 24)
        $0.textColor = .blackCw
        $0.textAlignment = .center
    }
    private let descLabelView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.clipsToBounds = true
    }
    private let descTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 16)
        $0.textColor = .blackCw
        $0.textAlignment = .center
        $0.text = "PC → 스마트폰"
    }
    private let descIndexLabel1 = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 9
        $0.layer.borderWidth = 1.5
        $0.layer.borderColor = UIColor.brownGrayCw.cgColor
        $0.setFontToBold(ofSize: 13)
        $0.textColor = .brownGrayCw
        $0.textAlignment = .center
        $0.clipsToBounds = true
        $0.text = "1"
    }
    private let descIndexLabel2 = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 9
        $0.layer.borderWidth = 1.5
        $0.layer.borderColor = UIColor.brownGrayCw.cgColor
        $0.setFontToBold(ofSize: 13)
        $0.textColor = .brownGrayCw
        $0.textAlignment = .center
        $0.clipsToBounds = true
        $0.text = "2"
    }
    private let descIndexLabel3 = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 9
        $0.layer.borderWidth = 1.5
        $0.layer.borderColor = UIColor.brownGrayCw.cgColor
        $0.setFontToBold(ofSize: 13)
        $0.textColor = .brownGrayCw
        $0.textAlignment = .center
        $0.clipsToBounds = true
        $0.text = "3"
    }
    private let descIndexLabel4 = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 9
        $0.layer.borderWidth = 1.5
        $0.layer.borderColor = UIColor.brownGrayCw.cgColor
        $0.setFontToBold(ofSize: 13)
        $0.textColor = .brownGrayCw
        $0.textAlignment = .center
        $0.clipsToBounds = true
        $0.text = "4"
    }
    private let descIndexLabel5 = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 9
        $0.layer.borderWidth = 1.5
        $0.layer.borderColor = UIColor.brownGrayCw.cgColor
        $0.setFontToBold(ofSize: 13)
        $0.textColor = .brownGrayCw
        $0.textAlignment = .center
        $0.clipsToBounds = true
        $0.text = "5"
    }
    private let descLabel1 = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGrayCw
        $0.numberOfLines = 0
        $0.text = "PC에서 www.cashdoc.me 홈페이지 접속"
    }
    private let descLabel2 = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGrayCw
        $0.numberOfLines = 0
        $0.text = "공동인증센터 > 공동인증서 복사 클릭"
    }
    private let descLabel3 = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGrayCw
        $0.numberOfLines = 0
        $0.text = "프로그램 설치"
    }
    private let descLabel4 = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGrayCw
        $0.numberOfLines = 0
        $0.text = "앱에 표시된 인증번호 12자리 숫자 입력"
    }
    private let descLabel5 = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGrayCw
        $0.numberOfLines = 0
        $0.text = "스마트폰 현 화면의 “입력 완료” 버튼 클릭"
    }
    private let importCertButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .yellowCw
        $0.layer.cornerRadius = 4
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.setTitleColor(.blackCw, for: .normal)
        $0.titleLabel?.textAlignment = .center
        $0.setTitle("입력 완료", for: .normal)
    }
    
    // MARK: - Con(De)structor
    
    init(viewModel: HowToImportCertificateViewModel,
         linkType: HowToLinkType,
         fCodeName: String?) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
        self.linkType = linkType
        self.fCodeName = fCodeName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        bindViewModel()
        view.addSubview(descCertView)
        view.addSubview(certNumView)
        view.addSubview(descLabelView)
        view.addSubview(importCertButton)
        descCertView.addSubview(descCertLabel)
        certNumView.addSubview(certNumTitleLabel)
        certNumView.addSubview(certNumLabel)
        setDescLabelView()
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:))).take(1).mapToVoid()
        let selection = importCertButton.rx.tap.map { (_) in
            self.certNumLabel.text
        }
        let input = type(of: self.viewModel).Input(trigger: viewWillAppear.asDriverOnErrorJustNever(),
                                              selection: selection.asDriverOnErrorJustNever())
        
        let output = viewModel.transform(input: input)
        
        output.certFetching
            .drive(onNext: { [weak self] (fetching) in
                guard let self = self else { return }
                
                switch fetching {
                case 1:
                    self.viewModel.parentViewControllerForScraping().navigationController?.view
                        .makeToastWithCenter("추가 방법 1~5의 과정을 먼저 수행하세요.")
                case 2:
                    self.viewModel.pushToLinkPropertyLoginViewController(linkType: self.linkType,
                                                                         fCodeName: self.fCodeName, completion: {
                        self.viewModel.parentViewControllerForScraping().navigationController?.view
                            .makeToastWithCenter("공동인증서가 추가되었습니다.")
                    })
                case 3:
                    self.viewModel.pushToLinkPropertyLoginViewController(linkType: self.linkType,
                                                                         fCodeName: self.fCodeName, completion: {
                        self.viewModel.parentViewControllerForScraping().navigationController?.view
                            .makeToastWithCenter("이미 동일한 공동인증서가 있습니다.")
                    })
                default:
                    self.viewModel.parentViewControllerForScraping().navigationController?.view.hideAllToasts()
                }
            })
            .disposed(by: disposeBag)
        
        output.authKey
            .drive(onNext: { [weak self] (authKey) in
                guard let self = self else { return }
                self.certNumLabel.text = authKey
            })
            .disposed(by: disposeBag)
        
        output.fetching
            .drive(onNext: { [weak self] (_) in
                guard let self = self else { return }
                self.view.makeToastWithCenter("공동인증서가 추가되었습니다.")
            })
            .disposed(by: disposeBag)
        
        output.networkErrorFetching
        .drive(onNext: { [weak self] (_) in
            guard let self = self else { return }
            self.view.makeToastWithCenter("네트워크 연결 상태를 확인해 주세요.")
        })
        .disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
        navigationItem.title = "공동인증서 추가방법"
    }
    
    private func setDescLabelView() {
        descLabelView.addSubview(descTitleLabel)
        descLabelView.addSubview(descIndexLabel1)
        descLabelView.addSubview(descIndexLabel2)
        descLabelView.addSubview(descIndexLabel3)
        descLabelView.addSubview(descIndexLabel4)
        descLabelView.addSubview(descIndexLabel5)
        descLabelView.addSubview(descLabel1)
        descLabelView.addSubview(descLabel2)
        descLabelView.addSubview(descLabel3)
        descLabelView.addSubview(descLabel4)
        descLabelView.addSubview(descLabel5)
    }
    
}

// MARK: - Layout

extension HowToImportCertificateViewController {
    
    private func layout() {
        descCertView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        descCertView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        descCertView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        descCertView.heightAnchor.constraint(equalToConstant: 68).isActive = true
        
        certNumView.topAnchor.constraint(equalTo: descCertView.bottomAnchor, constant: 36).isActive = true
        certNumView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        certNumView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        certNumView.heightAnchor.constraint(equalToConstant: 88).isActive = true
        
        descLabelView.topAnchor.constraint(equalTo: certNumView.bottomAnchor, constant: 24).isActive = true
        descLabelView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        descLabelView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        importCertButton.topAnchor.constraint(greaterThanOrEqualTo: descLabelView.bottomAnchor, constant: 20).isActive = true
        importCertButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        importCertButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        importCertButton.bottomAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true
        importCertButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        descCertViewLayout()
        certNumViewLayout()
        descLabelViewLayout()
    }
    
    private func descCertViewLayout() {
        descCertLabel.topAnchor.constraint(equalTo: descCertView.topAnchor, constant: 16).isActive = true
        descCertLabel.centerXAnchor.constraint(equalTo: descCertView.centerXAnchor).isActive = true
        descCertLabel.bottomAnchor.constraint(equalTo: descCertView.bottomAnchor, constant: -16).isActive = true
    }
    
    private func certNumViewLayout() {
        certNumTitleLabel.centerXAnchor.constraint(equalTo: certNumView.centerXAnchor).isActive = true
        certNumTitleLabel.topAnchor.constraint(equalTo: certNumView.topAnchor, constant: 16).isActive = true
        
        certNumLabel.centerXAnchor.constraint(equalTo: certNumTitleLabel.centerXAnchor).isActive = true
        certNumLabel.topAnchor.constraint(equalTo: certNumTitleLabel.bottomAnchor).isActive = true
        certNumLabel.bottomAnchor.constraint(equalTo: certNumView.bottomAnchor, constant: -16).isActive = true
    }
    
    private func descLabelViewLayout() {
        descTitleLabel.topAnchor.constraint(equalTo: descLabelView.topAnchor).isActive = true
        descTitleLabel.leadingAnchor.constraint(equalTo: descLabelView.leadingAnchor, constant: 24).isActive = true
        
        descIndexLabel1.topAnchor.constraint(equalTo: descTitleLabel.bottomAnchor, constant: 13).isActive = true
        descIndexLabel1.leadingAnchor.constraint(equalTo: descTitleLabel.leadingAnchor).isActive = true
        descIndexLabel1.widthAnchor.constraint(equalToConstant: 18).isActive = true
        descIndexLabel1.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        descLabel1.centerYAnchor.constraint(equalTo: descIndexLabel1.centerYAnchor).isActive = true
        descLabel1.leadingAnchor.constraint(equalTo: descIndexLabel1.trailingAnchor, constant: 8).isActive = true
        
        descIndexLabel2.topAnchor.constraint(equalTo: descIndexLabel1.bottomAnchor, constant: 13).isActive = true
        descIndexLabel2.leadingAnchor.constraint(equalTo: descIndexLabel1.leadingAnchor).isActive = true
        descIndexLabel2.widthAnchor.constraint(equalToConstant: 18).isActive = true
        descIndexLabel2.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        descLabel2.centerYAnchor.constraint(equalTo: descIndexLabel2.centerYAnchor).isActive = true
        descLabel2.leadingAnchor.constraint(equalTo: descIndexLabel2.trailingAnchor, constant: 8).isActive = true
        
        descIndexLabel3.topAnchor.constraint(equalTo: descIndexLabel2.bottomAnchor, constant: 13).isActive = true
        descIndexLabel3.leadingAnchor.constraint(equalTo: descIndexLabel2.leadingAnchor).isActive = true
        descIndexLabel3.widthAnchor.constraint(equalToConstant: 18).isActive = true
        descIndexLabel3.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        descLabel3.centerYAnchor.constraint(equalTo: descIndexLabel3.centerYAnchor).isActive = true
        descLabel3.leadingAnchor.constraint(equalTo: descIndexLabel3.trailingAnchor, constant: 8).isActive = true
        
        descIndexLabel4.topAnchor.constraint(equalTo: descIndexLabel3.bottomAnchor, constant: 13).isActive = true
        descIndexLabel4.leadingAnchor.constraint(equalTo: descIndexLabel3.leadingAnchor).isActive = true
        descIndexLabel4.widthAnchor.constraint(equalToConstant: 18).isActive = true
        descIndexLabel4.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        descLabel4.centerYAnchor.constraint(equalTo: descIndexLabel4.centerYAnchor).isActive = true
        descLabel4.leadingAnchor.constraint(equalTo: descIndexLabel4.trailingAnchor, constant: 8).isActive = true
        
        descIndexLabel5.topAnchor.constraint(equalTo: descIndexLabel4.bottomAnchor, constant: 13).isActive = true
        descIndexLabel5.leadingAnchor.constraint(equalTo: descIndexLabel4.leadingAnchor).isActive = true
        descIndexLabel5.widthAnchor.constraint(equalToConstant: 18).isActive = true
        descIndexLabel5.heightAnchor.constraint(equalToConstant: 18).isActive = true
        descIndexLabel5.bottomAnchor.constraint(equalTo: descLabelView.bottomAnchor).isActive = true
        
        descLabel5.centerYAnchor.constraint(equalTo: descIndexLabel5.centerYAnchor).isActive = true
        descLabel5.leadingAnchor.constraint(equalTo: descIndexLabel5.trailingAnchor, constant: 8).isActive = true
    }
    
}
