//
//  CouponViewController.swift
//  Cashdoc
//
//  Created by Taejune Jung on 03/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class CurrentCashViewController: CashdocViewController {
    
    // MARK: - Properties
    
    var viewModel: CurrentCashViewModel!
    
    // MARK: - UI Components
    
    private let infoView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .grayTwoCw
        return view
    }()
    private let infoTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "캐시 지급일 기준으로 1년 이내 미 사용 시 자동 소멸 됩니다."
        label.setFontToRegular(ofSize: 12)
        label.textColor = .brownishGrayCw
        label.textAlignment = .center
        return label
    }()
    
    private let currentCashView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    private let currentCashTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "현재 보유한 캐시"
        label.setFontToMedium(ofSize: 14)
        label.textColor = .blackCw
        return label
    }()
    private let cashImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "icSpendYellow")
        return imageView
    }()
    private let currentCashLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFontToMedium(ofSize: 24)
        label.textColor = .blackCw
        return label
    }()
    private let passingCashView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    private let expiredCaseTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFontToRegular(ofSize: 14)
        label.textColor = .brownishGrayCw
        return label
    }()
    private let expiredCashLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0캐시"
        label.setFontToRegular(ofSize: 14)
        label.textColor = .blackCw
        return label
    }()
    private let expiringingCashTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFontToRegular(ofSize: 14)
        label.textColor = .brownishGrayCw
        return label
    }()
    private let expiringCashLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0캐시"
        label.setFontToRegular(ofSize: 14)
        label.textColor = .blackCw
        return label
    }()
    private let bottomWhiteView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    // MARK: - Con(De)structor
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        bindViewModel()
        view.addSubview(infoView)
        infoView.addSubview(infoTitleLabel)
        view.addSubview(currentCashView)
        currentCashView.addSubview(currentCashTitleLabel)
        currentCashView.addSubview(cashImageView)
        currentCashView.addSubview(currentCashLabel)
        view.addSubview(passingCashView)
        passingCashView.addSubview(expiredCaseTitleLabel)
        passingCashView.addSubview(expiredCashLabel)
        passingCashView.addSubview(expiringingCashTitleLabel)
        passingCashView.addSubview(expiringCashLabel)
        view.addSubview(bottomWhiteView)
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    // MARK: - Binding
    
    private func bindViewModel() {
        // Input
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:))).mapToVoid()
        
        let input = type(of: self.viewModel).Input(trigger: viewWillAppear.asDriverOnErrorJustNever())
        
        // Output
        let output = viewModel.transform(input: input)
        
        output.point
            .drive(onNext: { [weak self] point in
                guard let self = self else { return }
                self.currentCashLabel.text = String(point.result.currentPoint).convertToDecimal("캐시")
                self.expiredCashLabel.text = String(point.result.expiredPoint).convertToDecimal("캐시")
                self.expiringCashLabel.text = String(point.result.expiredAtNextMonth).convertToDecimal("캐시")
                if var updateUser = UserManager.shared.userModel {
                    updateUser.point = point.result.currentPoint
                    UserManager.shared.user.onNext(updateUser)
                }
            })
        .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { [weak self] error in
                guard self != nil else { return }
                Log.e("Fail to Get Cash in CurrentCashVC : \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .grayTwoCw
        navigationItem.title = "캐시 내역"
        self.expiredCaseTitleLabel.text = self.prevMonth() + " 소멸된 캐시"
        self.expiringingCashTitleLabel.text = self.currentMonth() + " 소멸 예정 캐시"
    }

    private func prevMonth() -> String {
        let formatter = DateFormatter()
        guard let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date()) else { return formatter.string(from: Date()) }
        formatter.dateFormat = "M월"
        return formatter.string(from: previousMonth)
    }

    private func currentMonth() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월"
        return formatter.string(from: Date())
    }
    
}

// MARK: - Layout

extension CurrentCashViewController {
    
    private func layout() {
        infoView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        infoView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        infoView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        infoView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        infoTitleLabel.centerXAnchor.constraint(equalTo: infoView.centerXAnchor).isActive = true
        infoTitleLabel.centerYAnchor.constraint(equalTo: infoView.centerYAnchor).isActive = true
        
        currentCashView.topAnchor.constraint(equalTo: infoView.bottomAnchor).isActive = true
        currentCashView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        currentCashView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        currentCashView.heightAnchor.constraint(equalToConstant: 130).isActive = true
        
        currentCashTitleLabel.topAnchor.constraint(equalTo: currentCashView.topAnchor, constant: 24).isActive = true
        currentCashTitleLabel.leadingAnchor.constraint(equalTo: currentCashView.leadingAnchor, constant: 25).isActive = true
        
        currentCashLabel.bottomAnchor.constraint(equalTo: currentCashView.bottomAnchor, constant: -23.2).isActive = true
        currentCashLabel.trailingAnchor.constraint(equalTo: currentCashView.trailingAnchor, constant: -24).isActive = true
        
        cashImageView.trailingAnchor.constraint(equalTo: currentCashLabel.leadingAnchor, constant: -4).isActive = true
        cashImageView.widthAnchor.constraint(equalTo: cashImageView.heightAnchor).isActive = true
        cashImageView.centerYAnchor.constraint(equalTo: currentCashLabel.centerYAnchor).isActive = true
        cashImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        passingCashView.topAnchor.constraint(equalTo: currentCashView.bottomAnchor, constant: 8).isActive = true
        passingCashView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        passingCashView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        passingCashView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        expiredCaseTitleLabel.topAnchor.constraint(equalTo: passingCashView.topAnchor, constant: 32).isActive = true
        expiredCaseTitleLabel.leadingAnchor.constraint(equalTo: passingCashView.leadingAnchor, constant: 24).isActive = true
        
        expiredCashLabel.centerYAnchor.constraint(equalTo: expiredCaseTitleLabel.centerYAnchor).isActive = true
        expiredCashLabel.trailingAnchor.constraint(equalTo: currentCashView.trailingAnchor, constant: -24).isActive = true
        
        expiringingCashTitleLabel.topAnchor.constraint(equalTo: expiredCaseTitleLabel.bottomAnchor, constant: 24).isActive = true
        expiringingCashTitleLabel.leadingAnchor.constraint(equalTo: expiredCaseTitleLabel.leadingAnchor).isActive = true
        
        expiringCashLabel.centerYAnchor.constraint(equalTo: expiringingCashTitleLabel.centerYAnchor).isActive = true
        expiringCashLabel.trailingAnchor.constraint(equalTo: currentCashView.trailingAnchor, constant: -24).isActive = true
        
        bottomWhiteView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        bottomWhiteView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomWhiteView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomWhiteView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
}
