//
//  AgreeButton.swift
//  Cashdoc
//
//  Created by Taejune Jung on 20/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

protocol CheckButtonDelegate: AnyObject {
    func totalBtnTapped()
    func checkBtnTapped()
}

final class AgreeButton: UIButton {
    
    // MARK: - Properties
    
    weak var delegate: CheckButtonDelegate?
    var agreeButtonType: AgreeType!
    private let disposeBag = DisposeBag()
    
    // MARK: - UIComponents
    
    private let checkButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(UIImage(named: "icCheckBoxEnabled"), for: .selected)
        $0.setImage(UIImage(named: "icCheckBoxDefault"), for: .normal)
    }
    private let descLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    let arrowImageButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(UIImage(named: "icArrow01StyleRightGray"), for: .normal)
    }
    
    // MARK: - Con(De)structor
    
    init(title: String, tag: Int, type: AgreeType) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        setProperties(title: title, tag: tag, type: type)
        bindView()
        self.addSubview(checkButton)
        self.addSubview(descLabel)
        self.addSubview(arrowImageButton)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private methods
    
    private func setProperties(title: String, tag: Int, type: AgreeType) {
        self.tag = tag
        checkButton.tag = tag
        arrowImageButton.tag = tag
        descLabel.text = title
        self.agreeButtonType = type
        switch type {
        case .total:
            descLabel.setFontToMedium(ofSize: 14)
            descLabel.textColor = .blackCw
            arrowImageButton.isHidden = true
        case .necessary, .optional:
            descLabel.setFontToMedium(ofSize: 14)
            descLabel.textColor = .brownishGrayCw
            arrowImageButton.isHidden = false
        }
        
    }
    
    private func bindView() {
        Observable.merge(checkButton.rx.tapGesture().skip(1).asObservable(),
                         descLabel.rx.tapGesture().skip(1).asObservable())
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.checkButton.isSelected = !self.checkButton.isSelected
                if self.tag == 0 {
                    self.delegate?.totalBtnTapped()
                } else {
                    self.delegate?.checkBtnTapped()
                }
            })
        .disposed(by: disposeBag)
    }
    
    // MARK: - Public methods
    
    public func unCheck() {
        self.checkButton.isSelected = false
    }
    
    public func check() {
        self.checkButton.isSelected = true
    }
    
    public func isChecked() -> Bool {
//        if self.agreeButtonType != .optional {
        return self.checkButton.isSelected
//        } else {
//            return false
//        }
    }
}

extension AgreeButton {
    
    private func layout() {
        checkButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        checkButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24).isActive = true
        checkButton.widthAnchor.constraint(equalTo: checkButton.heightAnchor).isActive = true
        checkButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        descLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        descLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        descLabel.leadingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: 8).isActive = true
        descLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        arrowImageButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        arrowImageButton.leadingAnchor.constraint(equalTo: descLabel.trailingAnchor, constant: 4).isActive = true
        arrowImageButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24).isActive = true
        arrowImageButton.widthAnchor.constraint(equalTo: arrowImageButton.heightAnchor).isActive = true
        arrowImageButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
    }
    
}
