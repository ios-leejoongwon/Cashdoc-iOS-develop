//
//  ShopBuyPopupView.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 06/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Then

protocol ShopBuyPopupViewDelegate: NSObjectProtocol {
    func shopBuyPopupViewDidClickedBuyButton(_ view: ShopBuyPopupView)
}

final class ShopBuyPopupView: BasePopupView {
    
    // MARK: - Properties
    
    weak var delegate: ShopBuyPopupViewDelegate?
    var item: ShopItemModel? {
        didSet {
            guard let item = item else {return}
            
            affiliateLabel.text = item.affiliate ?? ""
            itemTitleLabel.text = item.title ?? ""
            
            if let price = item.price {
                UserManager.shared.user.bind(onNext: { [weak self] user in
                    guard let self = self else { return }
                    let point = user.point ?? 0
                    DispatchQueue.main.async {
                        self.priceCashLabel.text = "\(price.commaValue)캐시"
                        self.currentCashLabel.text = "\(point.commaValue)캐시"
                        let resultPoint = point - price
                        self.resultCashLabel.text = "\(resultPoint.commaValue)캐시"
                    }
                }).disposed(by: disposeBag)
            }
        }
    }
    
    // MARK: - UI Components
    
    private let backgroundView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    private let affiliateLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 13)
        $0.textColor = .warmGray
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    private let itemTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 16)
        $0.textColor = .blackCw
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    private let horizontalMiddleLine = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .lineGray
    }
    private let priceTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 14)
        $0.textColor = .blackTwoCw
        $0.textAlignment = .left
        $0.text = "가격"
    }
    private let priceCashLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 16)
        $0.textColor = .azureBlue
        $0.textAlignment = .right
    }
    private let currentTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 14)
        $0.textColor = .blackTwo
        $0.textAlignment = .left
        $0.text = "현재"
    }
    private let currentCashLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 14)
        $0.textColor = .brownishGray
        $0.textAlignment = .right
    }
    private let resultTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 14)
        $0.textColor = .blackTwo
        $0.textAlignment = .left
        $0.text = "잔여"
    }
    private let resultCashLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGray
        $0.textAlignment = .right
    }
    private let horizontalLine = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .lineGray
    }
    private let verticalLine = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .lineGray
    }
    private let cancelButton = UIButton(type: .system).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        $0.contentHorizontalAlignment = .center
        $0.setTitleColor(.blackTwoCw, for: .normal)
        $0.setTitle("취소", for: .normal)
    }
    private let buyButton = UIButton(type: .system).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        $0.contentHorizontalAlignment = .center
        $0.setTitleColor(.azureBlue, for: .normal)
        $0.setTitle("구매", for: .normal)
    }
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setSelector()
        addSubview(backgroundView)
        backgroundView.addSubview(affiliateLabel)
        backgroundView.addSubview(itemTitleLabel)
        backgroundView.addSubview(priceTitleLabel)
        backgroundView.addSubview(priceCashLabel)
        backgroundView.addSubview(horizontalMiddleLine)
        backgroundView.addSubview(currentTitleLabel)
        backgroundView.addSubview(currentCashLabel)
        backgroundView.addSubview(resultTitleLabel)
        backgroundView.addSubview(resultCashLabel)
        backgroundView.addSubview(horizontalLine)
        backgroundView.addSubview(verticalLine)
        backgroundView.addSubview(cancelButton)
        backgroundView.addSubview(buyButton)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    private func setSelector() {
        cancelButton.addTarget(self, action: #selector(didClickedCancelButton), for: .touchUpInside)
        buyButton.addTarget(self, action: #selector(didClickedBuyButton), for: .touchUpInside)
    }
    
    // MARK: - Private selector
    
    @objc private func didClickedCancelButton() {
        dismissView()
    }
    
    @objc private func didClickedBuyButton() {
        dismissView()
        delegate?.shopBuyPopupViewDidClickedBuyButton(self)
    }
    
}

// MARK: - Layout

extension ShopBuyPopupView {
    
    private func layout() {
        backgroundView.widthAnchor.constraint(equalToConstant: 288).isActive = true
        backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: verticalLine.bottomAnchor).isActive = true
        
        affiliateLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 27).isActive = true
        affiliateLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 24).isActive = true
        affiliateLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -24).isActive = true
        
        itemTitleLabel.topAnchor.constraint(equalTo: affiliateLabel.bottomAnchor, constant: 2).isActive = true
        itemTitleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 24).isActive = true
        itemTitleLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -24).isActive = true
        
        horizontalMiddleLine.topAnchor.constraint(equalTo: itemTitleLabel.bottomAnchor, constant: 26).isActive = true
        horizontalMiddleLine.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        horizontalMiddleLine.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        horizontalMiddleLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        horizontalLine.topAnchor.constraint(equalTo: resultTitleLabel.bottomAnchor, constant: 16).isActive = true
        horizontalLine.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        horizontalLine.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        horizontalLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        verticalLine.topAnchor.constraint(equalTo: horizontalLine.bottomAnchor).isActive = true
        verticalLine.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        verticalLine.widthAnchor.constraint(equalToConstant: 1).isActive = true
        verticalLine.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        cancelButton.topAnchor.constraint(equalTo: horizontalLine.bottomAnchor).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: verticalLine.leadingAnchor).isActive = true
        cancelButton.heightAnchor.constraint(equalTo: verticalLine.heightAnchor).isActive = true
        
        buyButton.topAnchor.constraint(equalTo: horizontalLine.bottomAnchor).isActive = true
        buyButton.leadingAnchor.constraint(equalTo: verticalLine.trailingAnchor).isActive = true
        buyButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        buyButton.heightAnchor.constraint(equalTo: verticalLine.heightAnchor).isActive = true
        
        priceLayout()
        currentLayout()
        resultLayout()
    }
    
    private func priceLayout() {
        priceTitleLabel.topAnchor.constraint(equalTo: horizontalMiddleLine.bottomAnchor, constant: 17).isActive = true
        priceTitleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 24).isActive = true
        
        priceCashLabel.setContentHuggingPriority(.required, for: .vertical)
        priceCashLabel.leadingAnchor.constraint(equalTo: priceTitleLabel.trailingAnchor, constant: 10).isActive = true
        priceCashLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -24).isActive = true
        priceCashLabel.centerYAnchor.constraint(equalTo: priceTitleLabel.centerYAnchor).isActive = true
    }
    
    private func currentLayout() {
        currentTitleLabel.topAnchor.constraint(equalTo: priceTitleLabel.bottomAnchor, constant: 10).isActive = true
        currentTitleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 24).isActive = true
        
        currentCashLabel.setContentHuggingPriority(.required, for: .vertical)
        currentCashLabel.leadingAnchor.constraint(equalTo: currentTitleLabel.trailingAnchor, constant: 10).isActive = true
        currentCashLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -24).isActive = true
        currentCashLabel.centerYAnchor.constraint(equalTo: currentTitleLabel.centerYAnchor).isActive = true
    }
    
    private func resultLayout() {
        resultTitleLabel.topAnchor.constraint(equalTo: currentTitleLabel.bottomAnchor, constant: 10).isActive = true
        resultTitleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 24).isActive = true
        
        resultCashLabel.setContentHuggingPriority(.required, for: .vertical)
        resultCashLabel.leadingAnchor.constraint(equalTo: resultTitleLabel.trailingAnchor, constant: 10).isActive = true
        resultCashLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -24).isActive = true
        resultCashLabel.centerYAnchor.constraint(equalTo: resultTitleLabel.centerYAnchor).isActive = true
    }
}
