//
//  ConsumeLinkBeforeViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 05/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class ConsumeLinkBeforeViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private var viewModel: ConsumeLinkBeforeViewModel!
    private var beforeCardImageWidth: NSLayoutConstraint!
    private var beforeCoffeeImageWidth: NSLayoutConstraint!
    private var fakeSlotViewHeight: NSLayoutConstraint!
    private var beforeCardBottom: NSLayoutConstraint!
    private var beforeCoffeeBottom: NSLayoutConstraint!
    private var scrollViewTimer: Timer?
    
    // MARK: - UI Components
    
    private let beforeCardView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
    }
    private let beforeCardImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgCardBig")
    }
    private let beforeCardTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 16)
        $0.textColor = .blackCw
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = "보유하신 계좌와 카드가 많아서\n금융사 앱을 여러개 쓰고 계신가요?"
        $0.setLineHeightMultiple(lineHeight: 1.2)
    }
    private let beforeCardDescLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGrayCw
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = "캐시닥 연결 한번으로\n모든 거래내역을 확인해보세요."
        $0.setLineHeightMultiple(lineHeight: 1.2)
    }
    private let beforeCoffeeView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.alpha = 0.0
    }
    private let beforeCoffeeImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgStarbuckcashBig")
    }
    private let beforeCoffeeTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 16)
        $0.textColor = .blackCw
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = "계좌/신용카드 연결하고\n매일매일 100캐시 더 받으세요."
        $0.setLineHeightMultiple(lineHeight: 1.2)
    }
    private let beforeCoffeeDescLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGrayCw
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = "처음으로 연결하시면\n1,000캐시도 즉시 지급됩니다."
        $0.setLineHeightMultiple(lineHeight: 1.2)
    }
    private let fakeSlotView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let getListButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 4
        $0.backgroundColor = .yellowCw
        $0.setTitleColor(.blackCw, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.titleLabel?.textAlignment = .center
        $0.setTitle("연결하고 편해지기", for: .normal)
    }
    
    // MARK: - Con(De)structor
    
    init(viewModel: ConsumeLinkBeforeViewModel) {
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
        bindViewModel()
        view.addSubview(fakeSlotView)
        view.addSubview(beforeCardView)
        beforeCardView.addSubview(beforeCardImageView)
        beforeCardView.addSubview(beforeCardTitleLabel)
        beforeCardView.addSubview(beforeCardDescLabel)
        view.addSubview(beforeCoffeeView)
        beforeCoffeeView.addSubview(beforeCoffeeImageView)
        beforeCoffeeView.addSubview(beforeCoffeeTitleLabel)
        beforeCoffeeView.addSubview(beforeCoffeeDescLabel)
        view.addSubview(getListButton)
        
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.changeAnimationView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.setAnimationsEnabled(false)
        self.beforeCardView.alpha = 1
        self.beforeCoffeeView.alpha = 0
        UIView.setAnimationsEnabled(true)
    }
    
    // MARK: - BInding
    
    private func bindView() {
        //        self.mainTabViewController.isSlotmachineAppeared
        //            .subscribe(onNext: { [weak self] isSliding in
        //                guard let self = self, let height = self.fakeSlotViewHeight else { return }
        //                if isSliding {
        //                    height.constant = self.mainTabViewController.slotMachine.frame.size.height
        //                    self.beforeCardBottom.isActive = true
        //                    self.beforeCoffeeBottom.isActive = true
        //                } else {
        //                    height.constant = 0
        //                    self.beforeCardBottom.isActive = false
        //                    self.beforeCoffeeBottom.isActive = false
        //                }
        //            })
        //        .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let clickedGetListButton = getListButton.rx.tap.asDriverOnErrorJustNever()
        
        let input = type(of: self.viewModel).Input(clickedGetListButton: clickedGetListButton)
        
        let output = viewModel.transform(input: input)
        
        output.isScrapingTotalCert
            .drive(onNext: {
                UIAlertController.presentAlertController(target: self, title: "", massage: "자산 데이터를 가져오고 있습니다.\n잠시만 기다려 주세요.", okBtnTitle: "확인", cancelBtn: false, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc private func changeAnimationView() {
        UIView.animate(withDuration: 0.5, delay: 4.0, options: .curveEaseInOut, animations: {
            self.beforeCardView.alpha = (self.beforeCardView.alpha == 1.0) ? 0.0 : 1.0
            self.beforeCoffeeView.alpha = (self.beforeCoffeeView.alpha == 1.0) ? 0.0 : 1.0
        }, completion: { finished in
            if finished {
                self.changeAnimationView()
            }
        })
    }
}

// MARK: - Layout

extension ConsumeLinkBeforeViewController {
    private func layout() {
        self.fakeSlotViewHeight = fakeSlotView.heightAnchor.constraint(equalToConstant: 0)
        fakeSlotViewHeight.isActive = true
        fakeSlotView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        fakeSlotView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        fakeSlotView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        beforeCarViewLayout()
        beforeCoffeeViewLayout()
        
        getListButton.topAnchor.constraint(greaterThanOrEqualTo: beforeCardDescLabel.bottomAnchor, constant: 16).isActive = true
        getListButton.topAnchor.constraint(greaterThanOrEqualTo: beforeCoffeeDescLabel.bottomAnchor, constant: 16).isActive = true
        getListButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        getListButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        getListButton.bottomAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        getListButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
    }
    
    private func beforeCarViewLayout() {
        beforeCardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
        beforeCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        beforeCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        beforeCardView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.beforeCardBottom = beforeCardView.bottomAnchor.constraint(lessThanOrEqualTo: fakeSlotView.topAnchor, constant: -16)
        
        beforeCardImageView.topAnchor.constraint(equalTo: beforeCardView.topAnchor).isActive = true
        beforeCardImageView.centerXAnchor.constraint(equalTo: beforeCardView.centerXAnchor).isActive = true
        beforeCardImageWidth = beforeCardImageView.widthAnchor.constraint(equalToConstant: 250)
        beforeCardImageWidth.priority = .init(998)
        beforeCardImageWidth.isActive = true
        beforeCardImageView.heightAnchor.constraint(equalTo: beforeCardImageView.widthAnchor, multiplier: 1).isActive = true
        
        beforeCardTitleLabel.topAnchor.constraint(equalTo: beforeCardImageView.bottomAnchor, constant: 8).isActive = true
        beforeCardTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        beforeCardTitleLabel.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        beforeCardDescLabel.topAnchor.constraint(equalTo: beforeCardTitleLabel.bottomAnchor, constant: 8).isActive = true
        beforeCardDescLabel.centerXAnchor.constraint(equalTo: beforeCardView.centerXAnchor).isActive = true
        beforeCardDescLabel.bottomAnchor.constraint(equalTo: beforeCardView.bottomAnchor).isActive = true
        beforeCardDescLabel.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    private func beforeCoffeeViewLayout() {
        beforeCoffeeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
        beforeCoffeeView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        beforeCoffeeView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        beforeCoffeeView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.beforeCoffeeBottom = beforeCoffeeView.bottomAnchor.constraint(lessThanOrEqualTo: fakeSlotView.topAnchor, constant: -16)
        
        beforeCoffeeImageView.topAnchor.constraint(equalTo: beforeCoffeeView.topAnchor).isActive = true
        beforeCoffeeImageView.centerXAnchor.constraint(equalTo: beforeCoffeeView.centerXAnchor).isActive = true
        beforeCoffeeImageWidth = beforeCoffeeImageView.widthAnchor.constraint(equalToConstant: 250)
        beforeCoffeeImageWidth.priority = .init(998)
        beforeCoffeeImageWidth.isActive = true
        beforeCoffeeImageView.heightAnchor.constraint(equalTo: beforeCoffeeImageView.widthAnchor, multiplier: 1).isActive = true
        
        beforeCoffeeTitleLabel.topAnchor.constraint(equalTo: beforeCoffeeImageView.bottomAnchor, constant: 8).isActive = true
        beforeCoffeeTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        beforeCoffeeTitleLabel.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        beforeCoffeeDescLabel.topAnchor.constraint(equalTo: beforeCoffeeTitleLabel.bottomAnchor, constant: 8).isActive = true
        beforeCoffeeDescLabel.centerXAnchor.constraint(equalTo: beforeCoffeeView.centerXAnchor).isActive = true
        beforeCoffeeDescLabel.bottomAnchor.constraint(equalTo: beforeCoffeeView.bottomAnchor).isActive = true
        beforeCoffeeDescLabel.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
}
