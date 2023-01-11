//
//  ConsumeHeaderView.swift
//  Cashdoc
//
//  Created by Taejune Jung on 09/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//
import Lottie
import RxSwift
import RxCocoa

final class ConsumeHeaderView: UIView {
    
    // MARK: - Properties
    
    let disposeBag = DisposeBag()
    let incomeButtonTrigger = PublishRelay<Void>()
    let outgoingButtonTrigger = PublishRelay<Void>()
    let etcButtonTrigger = PublishRelay<Void>()
    
    private var path = Bundle.main.path(forResource: "coin_jump", ofType: "json")
    
    // MARK: - UI Components
    private let incomeTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "수입"
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .brownishGrayCw
    }
    private let outgoingTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "지출"
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .brownishGrayCw
    }
    private let separateView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayCw
    }
    private let incomeLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 18)
        $0.text = "0원"
        $0.textColor = .blueCw
    }
    private let incomeButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let outgoingLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 18)
        $0.text = "0원"
        $0.textColor = .blueCw
    }
    private let outgoingButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let etcView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.fromRGB(244, 244, 244)
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    private let etcTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "기타"
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .brownGrayCw
    }
    private let etcLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .brownGrayCw
    }
    private let etcButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setProperties()
        bindView()
        self.addSubview(incomeTitleLabel)
        self.addSubview(incomeLabel)
        self.addSubview(incomeButton)
        self.addSubview(outgoingTitleLabel)
        self.addSubview(outgoingLabel)
        self.addSubview(outgoingButton)
        self.addSubview(separateView)
        self.addSubview(etcView)
        etcView.addSubview(etcTitleLabel)
        etcView.addSubview(etcLabel)
        etcView.addSubview(etcButton)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Binding
    private func bindView() {
        incomeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.incomeButtonTrigger.accept(())
            })
        .disposed(by: disposeBag)
        
        outgoingButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.outgoingButtonTrigger.accept(())
            })
        .disposed(by: disposeBag)
        
        etcButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.etcButtonTrigger.accept(())
            })
        .disposed(by: disposeBag)
    }
    
    // MARK: - Internal methods
    // swiftlint:disable:next large_tuple
    func configure(_ item: (String, String, String)) {
        self.incomeLabel.attributedText = NSMutableAttributedString.attributedUnderlineText(text: item.0.convertToDecimal("원"), ofSize: 18, weight: .medium, color: .blueCw, alignment: .right)
        self.outgoingLabel.attributedText = NSMutableAttributedString.attributedUnderlineText(text: item.1.convertToDecimal("원"), ofSize: 18, weight: .medium, color: .blueCw, alignment: .right)
        self.etcLabel.attributedText = NSMutableAttributedString.attributedUnderlineText(text: item.2 + "건", ofSize: 12, weight: .regular, color: .brownGrayCw, alignment: .right)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        self.backgroundColor = .grayTwoCw
    }
}

extension ConsumeHeaderView {
    private func layout() {
        self.heightAnchor.constraint(equalToConstant: 157).isActive = true
        
        separateView.topAnchor.constraint(equalTo: self.topAnchor, constant: 28.5).isActive = true
        separateView.widthAnchor.constraint(equalToConstant: 1).isActive = true
        separateView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        separateView.heightAnchor.constraint(equalToConstant: 62).isActive = true
        
        etcView.topAnchor.constraint(equalTo: separateView.bottomAnchor, constant: 18).isActive = true
        etcView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16).isActive = true
        etcView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true
        etcView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        etcView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        incomeTitleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 24.5).isActive = true
        incomeTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32).isActive = true
        incomeTitleLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        outgoingTitleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 24.5).isActive = true
        outgoingTitleLabel.leadingAnchor.constraint(equalTo: separateView.trailingAnchor, constant: 19).isActive = true
        outgoingTitleLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        incomeLabel.topAnchor.constraint(equalTo: incomeTitleLabel.bottomAnchor, constant: 24).isActive = true
        incomeLabel.trailingAnchor.constraint(equalTo: separateView.leadingAnchor, constant: -23).isActive = true
        incomeLabel.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        incomeButton.topAnchor.constraint(equalTo: incomeLabel.topAnchor).isActive = true
        incomeButton.leadingAnchor.constraint(equalTo: incomeLabel.leadingAnchor).isActive = true
        incomeButton.trailingAnchor.constraint(equalTo: incomeLabel.trailingAnchor).isActive = true
        incomeButton.bottomAnchor.constraint(equalTo: incomeLabel.bottomAnchor).isActive = true
        
        outgoingLabel.topAnchor.constraint(equalTo: outgoingTitleLabel.bottomAnchor, constant: 24).isActive = true
        outgoingLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -25).isActive = true
        outgoingLabel.heightAnchor.constraint(equalToConstant: 26).isActive = true
        
        outgoingButton.topAnchor.constraint(equalTo: outgoingLabel.topAnchor).isActive = true
        outgoingButton.leadingAnchor.constraint(equalTo: outgoingLabel.leadingAnchor).isActive = true
        outgoingButton.trailingAnchor.constraint(equalTo: outgoingLabel.trailingAnchor).isActive = true
        outgoingButton.bottomAnchor.constraint(equalTo: outgoingLabel.bottomAnchor).isActive = true
        
        etcTitleLabel.centerYAnchor.constraint(equalTo: etcView.centerYAnchor).isActive = true
        etcTitleLabel.leadingAnchor.constraint(equalTo: etcView.leadingAnchor, constant: 16).isActive = true
        
        etcLabel.centerYAnchor.constraint(equalTo: etcView.centerYAnchor).isActive = true
        etcLabel.trailingAnchor.constraint(equalTo: etcView.trailingAnchor, constant: -16).isActive = true
        
        etcButton.topAnchor.constraint(equalTo: etcLabel.topAnchor).isActive = true
        etcButton.leadingAnchor.constraint(equalTo: etcLabel.leadingAnchor).isActive = true
        etcButton.trailingAnchor.constraint(equalTo: etcLabel.trailingAnchor).isActive = true
        etcButton.bottomAnchor.constraint(equalTo: etcLabel.bottomAnchor).isActive = true
    }
}
