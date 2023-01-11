//
//  AgreeView.swift
//  Cashdoc
//
//  Created by Taejune Jung on 21/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

protocol AgreeViewDelegate: AnyObject {
    func agreeBtnTapped(tag: Int)
    func optionalAgreeBtnTapped(tag: Int, isCheck: Bool)
    func okButtonEnabled(_ enabled: Bool)
}

final class AgreeView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: AgreeViewDelegate?
    
    var buttonSpacing: CGFloat = 0 {
        didSet {
            subStackView.spacing = buttonSpacing
        }
    }
    
    private var necessaryCount: Int
    
    // MARK: - UIComponents
    
    private let totalAgreeButton: AgreeButton = {
        let button = AgreeButton(title: "모두 동의하기", tag: 0, type: .total)
        return button
    }()
    let subStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = UIStackView.Distribution.fillEqually
        stackView.spacing = 0
        return stackView
    }()
    
    // MARK: - Con(De)structor
    
    init(buttons: [(String, AgreeType)]) {
        self.necessaryCount = 0
        for button in buttons where  button.1 == .necessary {
            self.necessaryCount += 1
        }
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(totalAgreeButton)
        self.addSubview(subStackView)
        setProperties(buttons)
        layout(CGFloat(buttons.count))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private methods
    
    private func setProperties(_ buttons: [(String, AgreeType)]) {
        totalAgreeButton.delegate = self
        for index in 0 ..< buttons.count {
            let subAgreeButton = AgreeButton(title: buttons[index].0, tag: index + 1, type: buttons[index].1)
            subAgreeButton.arrowImageButton.addTarget(self, action: #selector(agreeButtonTapped(_:)), for: .touchUpInside)
            subAgreeButton.delegate = self
            
            if buttons[index].1 == .optional {
                subAgreeButton.arrowImageButton.isHidden = true
            }
            subStackView.addArrangedSubview(subAgreeButton)
        }
        self.subStackView.subviews.forEach { (view) in
            guard let button = view as? AgreeButton,
                button.agreeButtonType == .optional else { return }
            if button.tag == 3 {
                button.arrowImageButton.isHidden = false
            } else {
                button.arrowImageButton.isHidden = true
            }
            
        }
    }
    
    @objc private func agreeButtonTapped(_ sender: UIButton) {
        delegate?.agreeBtnTapped(tag: sender.tag)
    }
}

extension AgreeView {
    
    private func layout(_ buttonCount: CGFloat) {
        totalAgreeButton.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        totalAgreeButton.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        totalAgreeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        totalAgreeButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        subStackView.topAnchor.constraint(equalTo: totalAgreeButton.bottomAnchor, constant: 8).isActive = true
        subStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        subStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        subStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        subStackView.heightAnchor.constraint(equalToConstant: 45 * buttonCount).isActive = true
    }
    
}

// MARK: - CheckButtonDelegate

extension AgreeView: CheckButtonDelegate {
    func totalBtnTapped() {
        if totalAgreeButton.isChecked() {
            if let getArrangeSubviews = subStackView.arrangedSubviews as? [AgreeButton] {
                for button in getArrangeSubviews {
                    button.check()
                    if button.tag == 3 {
                        delegate?.optionalAgreeBtnTapped(tag: button.tag, isCheck: button.isChecked())
                    }
                }
            }
            delegate?.okButtonEnabled(true)
        } else {
            if let getArrangeSubviews = subStackView.arrangedSubviews as? [AgreeButton] {
                for button in getArrangeSubviews {
                    button.unCheck()
                }
            }
            delegate?.okButtonEnabled(false)
        }
    }
    
    func checkBtnTapped() {
        var selectedCount = 0
        var selectedNecessary = 0
        guard let agreeButtons = subStackView.arrangedSubviews as? [AgreeButton] else { return }
        for button in agreeButtons {
            Log.al("button = \(button.tag), button.isChecked() = \(button.isChecked())")
            
            if button.isChecked() {
                selectedCount += 1
                if button.agreeButtonType == .necessary {
                    selectedNecessary += 1
                }
            }
             
            if button.tag == 3 { // 개인정보 수집 및 이용 동의(선택) 일시
                delegate?.optionalAgreeBtnTapped(tag: button.tag, isCheck: button.isChecked())
            }
        }
        Log.al("necessaryCount = \(necessaryCount) selectedNecessary = \(selectedNecessary)")
        if selectedNecessary >= necessaryCount {
            delegate?.okButtonEnabled(true)
        } else {
            delegate?.okButtonEnabled(false)
        }
        
        if selectedCount >= agreeButtons.count {
            totalAgreeButton.check()
        } else {
            totalAgreeButton.unCheck()
        }
    }
}
