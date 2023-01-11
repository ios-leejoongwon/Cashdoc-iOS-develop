//
//  EventCardView.swift
//  Cashdoc
//
//  Created by Oh Sangho on 21/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa
import RxGesture
import Kingfisher

final class EventCardView: UIView {
    
    // MARK: - Properties
    
    var containerTapGesture: TapControlEvent {
        return containerView.rx.tapGesture()
    }
    
    private let disposeBag = DisposeBag()
    private let putEventCardFetching = PublishSubject<Void>()
    
    private var viewModel = EventCardViewModel()
    private var rootViewController: UIViewController!
    private var price: Int = 0
    private var currentPrice: Int = 0
    
    private var eventCardViewHeightZero: NSLayoutConstraint!
    private var containerViewBottom: NSLayoutConstraint!
    
    // MARK: - UI Components
    private let containerView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let contentView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 14)
        $0.numberOfLines = 0
    }
    private let closeButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(UIImage(named: "icClose20Gray"), for: .normal)
    }
    private let itemImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
    }
    private let gaugeBackgroundView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .veryLightPinkTwoCw
        $0.layer.cornerRadius = 5
    }
    private let earnedItemPointGauge = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .blueCw
        $0.layer.cornerRadius = 5
    }
    private let earnItemPointLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 12)
        $0.textColor = .brownishGrayCw
    }
    
    // MARK: - Con(De)structor
    
    init(rootViewController: UIViewController) {
        super.init(frame: .zero)
        
        self.rootViewController = rootViewController
        
        setProperties()
        bindView()
        bindViewModel()
        addSubview(containerView)
        containerView.addSubview(contentView)
        containerView.addSubview(itemImageView)
        containerView.addSubview(closeButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(gaugeBackgroundView)
        contentView.addSubview(earnItemPointLabel)
        gaugeBackgroundView.addSubview(earnedItemPointGauge)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Binding
    
    private func bindView() {
        closeButton
            .rx.tap
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] _ in
                guard let self = self else { return }
                
                self.getAlertController(vc: self.rootViewController)
                    .observe(on: MainScheduler.asyncInstance)
                    .bind { [weak self] (isOk) in
                        guard let self = self, isOk else { return }
                        
                        self.putEventCardFetching.onNext(())
                }
                .disposed(by: self.disposeBag)
        }
        .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let putEventCardTrigger = putEventCardFetching.asDriverOnErrorJustNever()
        
        let input = type(of: self.viewModel).Input(putEventCardTrigger: putEventCardTrigger)
        
        let output = viewModel.transform(input: input)
        
        output.hiddenFetchingWithClose
            .drive(onNext: { [weak self] (_) in
                guard let self = self else { return }
                self.animatedHiddenEventCard()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Internal methods
    
    func configure(with eventItem: EventItem) {
        guard eventItem.imageUrl != "0" else {
            animatedHiddenEventCard()
            return
        }
        showEventCard()
        price = eventItem.price
        currentPrice = price - eventItem.neededPrice
        
        titleLabel.text = String(format: "%@%@", eventItem.neededPrice.commaValue, eventItem.description)
        let earnedCashString = String(format: "%@ / %@캐시", currentPrice.commaValue+"캐시", price.commaValue)
        let attribute = NSMutableAttributedString(string: earnedCashString)
        attribute.addAttribute(.foregroundColor, value: UIColor.blueCw, range: (earnedCashString as NSString).range(of: currentPrice.commaValue+"캐시"))
        earnItemPointLabel.attributedText = attribute
        
        itemImageView.kf.setImage(with: URL(string: eventItem.imageUrl), options: [.callbackQueue(.mainAsync)])
        
        gaugeBackgroundViewLayout()
    }
    
    // MARK: - private methods
    
    private func setProperties() {
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 4
        containerView.layer.shadowColor = UIColor.blackTwoCw.cgColor
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowRadius = 6
        containerView.layer.shadowOffset = CGSize(width: -1, height: 1)
    }
    
    private func animatedHiddenEventCard() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.eventCardViewHeightZero.isActive = false
                self.eventCardViewHeightZero = self.containerView.heightAnchor.constraint(equalToConstant: 0)
                self.eventCardViewHeightZero.isActive = true
                self.containerViewBottom.constant = 0
                self.rootViewController.view.layoutIfNeeded()
            }, completion: { (_) in
                self.rootViewController.view.setNeedsLayout()
                self.rootViewController.view.layoutIfNeeded()
                self.isHidden = true
            })
        }
    }
    
    private func showEventCard() {
        self.isHidden = false
        self.eventCardViewHeightZero.isActive = false
        self.eventCardViewHeightZero = containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        self.eventCardViewHeightZero.isActive = true
        containerViewBottom.constant = -8
    }
    
    private func getAlertController(vc: UIViewController) -> Observable<Bool> {
        var actions = [RxAlertAction<Bool>]()
        actions.append(RxAlertAction<Bool>.init(title: "아니요", style: .cancel, result: false))
        actions.append(RxAlertAction<Bool>.init(title: "예", style: .default, result: true))
        
        return UIAlertController.rx_presentAlert(viewController: vc,
                                                 title: "",
                                                 message: "스타벅스 카드를\n다시 보지 않으시겠습니까?",
                                                 preferredStyle: .alert,
                                                 animated: true,
                                                 actions: actions)
    }
    
}

// MARK: - Layout

extension EventCardView {
    
    private func layout() {
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        containerViewBottom = containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        containerViewBottom.isActive = true
        
        eventCardViewHeightZero = containerView.heightAnchor.constraint(equalToConstant: 0)
        eventCardViewHeightZero.priority = .defaultLow
        eventCardViewHeightZero.isActive = true
        
        itemImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24).isActive = true
        itemImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24).isActive = true
        itemImageView.widthAnchor.constraint(equalToConstant: 88).isActive = true
        itemImageView.heightAnchor.constraint(equalToConstant: 88).isActive = true
        
        contentView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: itemImageView.leadingAnchor, constant: -27.5).isActive = true
        contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        contentViewLayout()
    }
    
    private func contentViewLayout() {
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 27).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        gaugeBackgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.equalTo(titleLabel)
            make.width.equalTo(titleLabel).inset(10)
            make.height.equalTo(6).priority(.high)
        }
        earnItemPointLabel.topAnchor.constraint(equalTo: gaugeBackgroundView.bottomAnchor, constant: 8).isActive = true
        earnItemPointLabel.leadingAnchor.constraint(equalTo: gaugeBackgroundView.leadingAnchor).isActive = true
        earnItemPointLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -25).isActive = true
    }
    
    private func gaugeBackgroundViewLayout() {
        earnedItemPointGauge.topAnchor.constraint(equalTo: gaugeBackgroundView.topAnchor).isActive = true
        earnedItemPointGauge.leadingAnchor.constraint(equalTo: gaugeBackgroundView.leadingAnchor).isActive = true
        earnedItemPointGauge.bottomAnchor.constraint(equalTo: gaugeBackgroundView.bottomAnchor).isActive = true
        var multiplier: CGFloat = CGFloat(currentPrice) / CGFloat(price)
        if multiplier > 1 {
            multiplier = 1
        }
        earnedItemPointGauge.widthAnchor.constraint(equalTo: gaugeBackgroundView.widthAnchor, multiplier: multiplier).isActive = true
    }
    
}
