//
//  InsuranceTermVC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/13.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

final class InsuranceTermVC: CashdocViewController {
    
    // MARK: - Properties
    private let menuTapped = PublishRelay<Int>.init()
    private var viewModel: TermsOfServiceViewModel?
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = 24
        paragraph.alignment = .center
        let attributedString = NSMutableAttributedString(string: "보험 모아보기를 진행하기 위해\n이용약관을 동의해주세요.", attributes: [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.blackCw,
            .kern: 0.0
            ])
        attributedString.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: attributedString.length))
        $0.attributedText = attributedString
    }
    private let separateLineView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.fromRGB(216, 216, 216)
    }
    private let agreeView: AgreeView = {
        let view = AgreeView(buttons: [("이용약관 동의 (필수)", .necessary),
                                       ("개인(신용)정보 수집 및 이용 동의 (필수)", .necessary)])
        return view
    }()
    private let okButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("다음", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setBackgroundColor(.whiteCw, forState: .disabled)
        button.setBackgroundColor(.yellowCw, forState: .normal)
        button.setTitleColor(.veryLightPinkCw, for: .disabled)
        button.setTitleColor(.blackCw, for: .normal)
        button.isEnabled = false
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        return button
    }()
    
    // MARK: - Overridden: CashdocViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        view.addSubview(titleLabel)
        view.addSubview(separateLineView)
        view.addSubview(agreeView)
        view.addSubview(okButton)
        layout()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        viewModel = TermsOfServiceViewModel.init(navigator: .init(parentViewController: self))
        // Input
        let okTrigger = okButton.rx.tap.asDriver()
        let menuTapTrigger = self.menuTapped.asDriverOnErrorJustNever()
        let input = TermsOfServiceViewModel.Input(okTrigger: okTrigger,
                                              menuTapTrigger: menuTapTrigger)
        
        // Output
        viewModel?.currentTerm = .insurance
        _ = viewModel?.transform(input: input)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
        agreeView.delegate = self
    }
    
}

// MARK: - Layout

extension InsuranceTermVC {
    
    private func layout() {
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 53).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
                
        separateLineView.topAnchor.constraint(equalTo: view.topAnchor, constant: 176).isActive = true
        separateLineView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        separateLineView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
        separateLineView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24).isActive = true
        separateLineView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        agreeView.topAnchor.constraint(equalTo: separateLineView.bottomAnchor, constant: 20.5).isActive = true
        agreeView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        agreeView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        okButton.topAnchor.constraint(greaterThanOrEqualTo: agreeView.bottomAnchor, constant: 16).isActive = true
        okButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        okButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        okButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        okButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
    }
    
}

// MARK: - AgreeViewDelegate

extension InsuranceTermVC: AgreeViewDelegate {
    func optionalAgreeBtnTapped(tag: Int, isCheck: Bool) {
        
    }
    
    func agreeBtnTapped(tag: Int) {
        self.menuTapped.accept(tag)
    }

    func okButtonEnabled(_ enabled: Bool) {
        okButton.isEnabled = enabled
    }
}
