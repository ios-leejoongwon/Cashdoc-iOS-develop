//
//  WithdrawViewController.swift
//  Cashdoc
//
//  Created by Taejune Jung on 05/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class WithdrawViewController: CashdocViewController {
    
    // MARK: - Properties
    
    var viewModel: WithdrawViewModel!
    
    // MARK: - UI Components
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "imgCautionBig")
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        var makeText = "캐시닥을 탈퇴하시면\n자산 내역과 모으신 캐시가 삭제되어\n복구하실 수 없습니다."
        if UserDefaults.standard.bool(forKey: UserDefaultKey.kIsShowRecommend.rawValue) {
            makeText = "캐시닥을 탈퇴하시면\n자산 내역과 모으신 캐시가 삭제되며\n신청하신 현금 인출과 배송은 취소되어\n복구하실 수 없습니다."
        }
        label.attributedText = NSMutableAttributedString.attributedText(text: makeText, ofSize: 16 * widthRatio, weight: .medium, alignment: .center)
        return label
    }()
    private let currentCashTitleLabel: UILabel = {
        let label  = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFontToRegular(ofSize: 14)
        label.text = "삭제되는 현재 보유 캐시"
        label.textColor = .brownGrayCw
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
        label.textColor = .blackCw
        label.setFontToMedium(ofSize: 14)
        return label
    }()
    private let separateLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .grayCw
        return view
    }()
    private let withdrawButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("캐시닥 탈퇴하기", for: .normal)
        button.layer.cornerRadius = 4
        button.layer.borderColor = UIColor.blackCw.cgColor
        button.layer.borderWidth = 1
        button.setTitleColor(.blackCw, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
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
        bindView()
        bindViewModel()
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(currentCashTitleLabel)
        view.addSubview(cashImageView)
        view.addSubview(currentCashLabel)
        view.addSubview(separateLineView)
        view.addSubview(withdrawButton)
        
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "회원 탈퇴"
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    // MARK: - Binding
    
    private func bindView() {

    }
    
    private func bindViewModel() {
        // Input
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:))).mapToVoid()
        
        let input = type(of: self.viewModel).Input(trigger: viewWillAppear.asDriverOnErrorJustNever(),
                                              withdrawTrigger: withdrawButton.rx.tap.asDriver())

        // Output
        let output = viewModel.transform(input: input)
        
        output.point
            .drive(onNext: { [weak self] point in
                guard let self = self else { return }
                self.currentCashLabel.text = String(point.result.currentPoint).convertToDecimal("캐시")
            })
            .disposed(by: disposeBag)
        output.error
            .drive(onNext: { [weak self] error in
                guard self != nil else { return }
                print(error)
            })
        .disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
    }

}

// MARK: - Layout

extension WithdrawViewController {
    
    private func layout() {
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 250).isActive = true
        
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        
        currentCashTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 36).isActive = true
        currentCashTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        currentCashTitleLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        cashImageView.centerYAnchor.constraint(equalTo: currentCashTitleLabel.centerYAnchor).isActive = true
        cashImageView.widthAnchor.constraint(equalTo: cashImageView.heightAnchor).isActive = true
        cashImageView.widthAnchor.constraint(equalToConstant: 18).isActive = true
        cashImageView.trailingAnchor.constraint(equalTo: currentCashLabel.leadingAnchor, constant: -4).isActive = true
        
        currentCashLabel.centerYAnchor.constraint(equalTo: currentCashTitleLabel.centerYAnchor).isActive = true
        currentCashLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -34).isActive = true
        currentCashLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        separateLineView.topAnchor.constraint(equalTo: currentCashTitleLabel.bottomAnchor, constant: 14).isActive = true
        separateLineView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
        separateLineView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24).isActive = true
        separateLineView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        withdrawButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        withdrawButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        withdrawButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        withdrawButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
    }
    
}
