//
//  ImportCertificateViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 07/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class ImportCertificateViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private var viewModel: ImportCertificateViewModel!
    
    // MARK: - UI Components
    
    private let centerImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgCertificationNoneBig")
    }
    private let descLabel1 = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 16)
        $0.textColor = .blackCw
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = "저장된 공동인증서가 없어요."
    }
    private let descLabel2 = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGrayCw
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = "캐시닥에서 안전하게 PC의 공동인증서를\n핸드폰으로 가져와보세요.\n가져온 공동인증서는 핸드폰에만 안전하게 보관됩니다."
    }
    private let importCertButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .yellowCw
        $0.layer.cornerRadius = 4
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.setTitleColor(.blackCw, for: .normal)
        $0.titleLabel?.textAlignment = .center
        $0.setTitle("공동인증서 가져오기", for: .normal)
    }
    
    // MARK: - Con(De)structor
    
    init(viewModel: ImportCertificateViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        bindView()
        view.addSubview(centerImage)
        view.addSubview(descLabel1)
        view.addSubview(descLabel2)
        view.addSubview(importCertButton)
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Binding
    
    private func bindView() {
        importCertButton.rx
            .tap
            .bind { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.pushToHowToImportCertViewController()
            }
            .disposed(by: disposeBag)
        
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
        navigationItem.title = "공동인증서 로그인"
    }
    
}

// MARK: - Layout

extension ImportCertificateViewController {
    
    private func layout() {
        centerImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -150).isActive = true
        centerImage.widthAnchor.constraint(equalToConstant: 250).isActive = true
        centerImage.heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        descLabel1.topAnchor.constraint(equalTo: centerImage.bottomAnchor, constant: 8).isActive = true
        descLabel1.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        descLabel2.topAnchor.constraint(equalTo: descLabel1.bottomAnchor, constant: 8).isActive = true
        descLabel2.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        importCertButton.topAnchor.constraint(greaterThanOrEqualTo: descLabel2.bottomAnchor, constant: 20).isActive = true
        importCertButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        importCertButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        importCertButton.bottomAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true
        importCertButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
    }
    
}
