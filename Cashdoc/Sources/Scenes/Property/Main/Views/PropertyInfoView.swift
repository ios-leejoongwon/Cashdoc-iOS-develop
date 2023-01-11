//
//  PropertyInfoView.swift
//  Cashdoc
//
//  Created by Oh Sangho on 26/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//
import RxCocoa
import RxSwift

final class PropertyInfoView: UIView {
    
    // MARK: - Properties
    
    var addButtonTap: ControlEvent<Void> {
        return addButton.rx.tap
    }
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Componenets
    
    private let nameContentView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayTwoCw
    }
    private let propertyContentView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayTwoCw
    }
    private let defaultDescLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 18)
        $0.textAlignment = .center
        $0.textColor = .blackCw
        $0.numberOfLines = 2
    }
    private let myPropertyLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 16)
        $0.textColor = .blackCw
        $0.text = "내 자산"
    }
    private let addButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 14.4
        $0.backgroundColor = .blackCw
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14.4)
        $0.setTitle("추가", for: .normal)
    }
    private let totalAmountLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 24)
        $0.textColor = .blackCw
        $0.textAlignment = .right
        $0.text = "0원"
    }
    
    // MARK: - Con(De)structor
    
    init() {
        super.init(frame: .zero)
        
        setProperties()
        bindView()
        addSubview(nameContentView)
        addSubview(propertyContentView)
        nameContentView.addSubview(defaultDescLabel)
        propertyContentView.addSubview(myPropertyLabel)
        propertyContentView.addSubview(addButton)
        propertyContentView.addSubview(totalAmountLabel)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Binding
    
    private func bindView() {
        UserManager.shared.user
            .bind { (user) in
                self.configure(name: user.nickname)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Internal methods
    
    func configure(totalAmount: Int) {
        totalAmountLabel.text = String(format: "%@원", totalAmount.commaValue)
    }
    
    func didChangeContentView(with linkStatus: LinkStatus) {
        if linkStatus == .연동전 {
            nameContentView.isHidden = false
            propertyContentView.isHidden = true
        } else {
            nameContentView.isHidden = true
            propertyContentView.isHidden = false
        }
    }
    
    // MARK: - Private methods
    
    private func configure(name: String) {
        let descString = String(format: "%@의\n 자산을 관리하고 캐시를 쌓아보세요.", name+"님")
        let attribute = NSMutableAttributedString(string: descString)
        attribute.addAttribute(.font, value: UIFont.systemFont(ofSize: 19 * widthRatio, weight: .medium), range: (descString as NSString).range(of: name+"님"))
        defaultDescLabel.attributedText = attribute
    }
    
    private func setProperties() {
        backgroundColor = .grayTwoCw
    }
    
}

// MARK: - Layout

extension PropertyInfoView {
    
    private func layout() {
        nameContentView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        nameContentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        nameContentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        nameContentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 10).isActive = true
        
        propertyContentView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        propertyContentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        propertyContentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        propertyContentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        nameContentViewLayout()
        propertyContentViewLayout()
    }
    
    private func nameContentViewLayout() {
        defaultDescLabel.topAnchor.constraint(equalTo: nameContentView.topAnchor).isActive = true
        defaultDescLabel.centerXAnchor.constraint(equalTo: nameContentView.centerXAnchor).isActive = true
        defaultDescLabel.bottomAnchor.constraint(equalTo: nameContentView.bottomAnchor).isActive = true
    }
    
    private func propertyContentViewLayout() {
        myPropertyLabel.centerYAnchor.constraint(equalTo: propertyContentView.centerYAnchor).isActive = true
        myPropertyLabel.leadingAnchor.constraint(equalTo: propertyContentView.leadingAnchor, constant: 16).isActive = true
        
        addButton.centerYAnchor.constraint(equalTo: propertyContentView.centerYAnchor).isActive = true
        addButton.leadingAnchor.constraint(equalTo: myPropertyLabel.trailingAnchor, constant: 8).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 48).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 29).isActive = true
        
        totalAmountLabel.trailingAnchor.constraint(equalTo: propertyContentView.trailingAnchor, constant: -16).isActive = true
        totalAmountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: addButton.trailingAnchor, constant: 16).isActive = true
        totalAmountLabel.centerYAnchor.constraint(equalTo: myPropertyLabel.centerYAnchor).isActive = true
    }
    
}
