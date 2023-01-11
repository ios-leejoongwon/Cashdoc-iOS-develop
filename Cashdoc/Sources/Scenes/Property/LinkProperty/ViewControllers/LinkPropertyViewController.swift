//
//  LinkPropertyViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 17/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class LinkPropertyViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private var viewModel: LinkPropertyViewModel!
    
    // MARK: - UI Components
    
    private let centerImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgPropertyBig")
    }
    private let descLabel1 = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 16)
        $0.textColor = .blackCw
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = "공동인증서 연결 한 번으로\n흩어져있는 내 돈을 모아보세요."
    }
    private let descLabel2 = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGrayCw
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = "공동인증서(구 공인인증서)는\n절대 외부로 전송되지 않으며\n본인의 핸드폰에 안전하게 보관됩니다."
    }
    private let linkAtOnceButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .yellowCw
        $0.layer.cornerRadius = 4
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        $0.setTitleColor(.blackCw, for: .normal)
        $0.titleLabel?.textAlignment = .center
        $0.setTitle("한 번에 연결하기", for: .normal)
    }
    private let linkOneByOneButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        $0.setTitleColor(.blackCw, for: .normal)
        $0.titleLabel?.textAlignment = .center
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let buttonString = NSAttributedString(string: "하나씩 골라서 연결하기", attributes: underlineAttribute)
        $0.setAttributedTitle(buttonString, for: .normal)
    }
    
    // MARK: - Con(De)structor
    
    init(viewModel: LinkPropertyViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        bindViewModel()
        view.addSubview(centerImage)
        view.addSubview(descLabel1)
        view.addSubview(descLabel2)
        view.addSubview(linkAtOnceButton)
        view.addSubview(linkOneByOneButton)
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    // MARK: - Binding
    
    private func bindViewModel() {
        let atOnceSelection = linkAtOnceButton.rx.tap.asObservable()
        let oneByOneSelection = linkOneByOneButton.rx.tap.asObservable()
        
        let input = type(of: self.viewModel).Input(atOnceSelection: atOnceSelection.asDriverOnErrorJustNever(),
                                              oneByOneSelection: oneByOneSelection.asDriverOnErrorJustNever())
        
        _ = viewModel.transform(input: input)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
        navigationItem.title = "자산 추가하기"
    }
    
}

// MARK: - Layout

extension LinkPropertyViewController {
    
    private func layout() {
        centerImage.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -142.5).isActive = true
        centerImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerImage.widthAnchor.constraint(equalToConstant: 250).isActive = true
        centerImage.heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        descLabel1.topAnchor.constraint(equalTo: centerImage.bottomAnchor, constant: 8).isActive = true
        descLabel1.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        descLabel2.topAnchor.constraint(equalTo: descLabel1.bottomAnchor, constant: 8).isActive = true
        descLabel2.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        linkAtOnceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 23).isActive = true
        linkAtOnceButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -23).isActive = true
        linkAtOnceButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        linkOneByOneButton.topAnchor.constraint(equalTo: linkAtOnceButton.bottomAnchor, constant: 24).isActive = true
        linkOneByOneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        linkOneByOneButton.bottomAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.bottomAnchor, constant: -24).isActive = true
        linkOneByOneButton.heightAnchor.constraint(equalToConstant: 14).isActive = true
    }
    
}
