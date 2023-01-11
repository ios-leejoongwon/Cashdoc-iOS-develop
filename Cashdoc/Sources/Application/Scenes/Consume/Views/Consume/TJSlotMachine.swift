//
//  SlotMachineView.swift
//  Cashdoc
//
//  Created by Taejune Jung on 22/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import QuartzCore

let SHOW_BORDER = 1

protocol TJSlotMachineDelegate: class {
    func slotMachineWillStratSliding(_ slotMachine: TJSlotMachine)
    func slotMachineDidEndSliding(_ slotMachine: TJSlotMachine, point: String)
    func slotMachineClosed(_ slotMachine: TJSlotMachine, isSliding: Bool)
}

protocol TJSlotMachineDataSource {
    func numberOfSlots(in slotMachine: TJSlotMachine) -> Int
    func iconsForSlots(in slotMachine: TJSlotMachine) -> [UIImage]
    
    func slotWidth(in slotMachine: TJSlotMachine) -> CGFloat
    func slotSpacing(in slotMachine: TJSlotMachine) -> CGFloat
}

class TJSlotMachine: UIView {

    var backgroundImage: UIImage? {
        didSet {
            self.backgroundImageView.image = backgroundImage
        }
    }
    var coverImage: UIImage? {
        didSet {
            self.coverImageView.image = coverImage
        }
    }
    
    var slotResults: [Int]? {
        didSet {
            guard let cash = slotResults?.first else { return }
            var cashLabel = String()
            switch cash {
            case 0:
                cashLabel = "1캐시에 당첨되었습니다."
                intPoint = 1
                point = "1"
            case 1:
                cashLabel = "100캐시에 당첨되었습니다."
                intPoint = 100
                point = "100"
            case 2:
                cashLabel = 1000.commaValue + "캐시에 당첨되었습니다."
                intPoint = 1000
                point = 1000.commaValue
            case 3:
                cashLabel = 5000.commaValue + "캐시에 당첨되었습니다."
                intPoint = 5000
                point = 5000.commaValue
            case 4:
                cashLabel = "1만캐시에 당첨되었습니다."
                intPoint = 10000
                point = "1만"
            case 5:
                cashLabel = "10만캐시에 당첨되었습니다."
                intPoint = 100000
                point = "10만"
            case 6:
                cashLabel = "100만캐시에 당첨되었습니다."
                intPoint = 1000000
                point = "100만"
            default:
                intPoint = 0
                point = "0"
            }
            self.okButton.setTitle(cashLabel, for: .normal)
        }
    }
    var singleUnitDuration: CGFloat = 0
    var dataSource: TJSlotMachineDataSource?
    var point: String = "0"
    var intPoint = 0
    
    weak var delegate: TJSlotMachineDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFontToMedium(ofSize: 16)
        label.textColor = .black
        label.text = "행운캐시 등장!"
        label.textAlignment = .center
        return label
    }()
    private let closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "icCloseBlack"), for: .normal)
        return button
    }()
    private var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    private var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        #if SHOW_BORDER
        view.layer.borderColor = UIColor.blue.cgColor
        view.layer.borderWidth = 1
        #endif
        return view
    }()
    private let slotContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let noticeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.fromRGBA(105, 100, 86, 0.1)
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        return view
    }()
    private let firstNoticeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFontToRegular(ofSize: 13)
        label.textColor = .blackTwoCw
        label.textAlignment = .center
        label.text = "최대 100만캐시 당첨에 도전하세요!"
        return label
    }()
    private let secondNoticeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFontToRegular(ofSize: 13)
        label.textColor = .blackTwoCw
        label.textAlignment = .center
        label.text = "최대 100만캐시 당첨에 도전하세요!"
        label.isHidden = true
        return label
    }()
    private let okButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .blackCw
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.isHidden = true
        return button
    }()
    private var firstSlotScrollLayerArray: [CALayer]
    private var secondSlotScrollLayerArray: [CALayer]
    private var firstViewTop: NSLayoutConstraint!
    private var secondViewTop: NSLayoutConstraint!
    private let pointProvider = CashdocProvider<RewardPointService>()
    private var timer: Timer?
    private var winners = [WinnerList]() {
        didSet {
            guard winners.count > 1 else {
                firstNoticeLabel.text = "최대 100만캐시 당첨에 도전하세요!"
                secondNoticeLabel.text = "최대 100만캐시 당첨에 도전하세요!"
                isScroll = false
                return
            }
            guard winners.count - 1 > noticeIndex else {
                return
            }
            firstNoticeLabel.text = convertWinnerLabel(winner: winners[noticeIndex])
            secondNoticeLabel.text = convertWinnerLabel(winner: winners[noticeIndex+1])
            noticeIndex += 2
            isScroll = true
            startScroll()
        }
    }
    
    private var noticeIndex = 0
    private var isScroll = false
    var isSliding: Bool = false
    var kMinTurn = 18
    let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        firstSlotScrollLayerArray = [CALayer]()
        secondSlotScrollLayerArray = [CALayer]()
        singleUnitDuration = 0.14
        
        super.init(frame: frame)
        self.clipsToBounds = true
        self.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        
        bindView()
        self.addSubview(backgroundImageView)
        self.addSubview(coverImageView)
        self.addSubview(contentView)
        self.addSubview(slotContentView)
        self.addSubview(titleLabel)
        self.addSubview(closeButton)
        self.addSubview(noticeView)
        noticeView.addSubview(firstNoticeLabel)
        noticeView.addSubview(secondNoticeLabel)
        noticeView.addSubview(okButton)
        
        layout()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        timer?.invalidate()
        timer = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    private func bindView() {
        closeButton.addTarget(self, action: #selector(closeButtonAction(_:)), for: .touchUpInside)
        okButton.addTarget(self, action: #selector(closeButtonAction(_:)), for: .touchUpInside)
    }
    
    func closedMachine() {
        self.delegate?.slotMachineClosed(self, isSliding: self.isSliding)
        self.okButton.isHidden = true
        self.isSliding = false
        for containerLayer in slotContentView.layer.sublayers ?? [] {
            self.firstSlotScrollLayerArray = []
            self.secondSlotScrollLayerArray = []
            containerLayer.removeFromSuperlayer()
        }
    }
    
    func reloadData() {
        guard let dataSource = self.dataSource else { return }
        point = "0"
        intPoint = 0
        self.winners = []
        
        if !firstSlotScrollLayerArray.isEmpty && !secondSlotScrollLayerArray.isEmpty ||
            firstSlotScrollLayerArray.isEmpty && secondSlotScrollLayerArray.isEmpty {
            for containerLayer in slotContentView.layer.sublayers ?? [] {
                containerLayer.removeFromSuperlayer()
            }
            self.firstSlotScrollLayerArray = []
            self.secondSlotScrollLayerArray = []
            
            let numberOfSlot = dataSource.numberOfSlots(in: self)
            var slotSpacing: CGFloat = 0
            var slotWidth: CGFloat = 0
            if let spacing = self.dataSource?.slotSpacing(in: self), let width = self.dataSource?.slotWidth(in: self) {
                slotSpacing = spacing
                slotWidth = width
            }
            
            for index in 0 ..< numberOfSlot {
                let slotContainerLayer = CALayer()
                slotContainerLayer.frame = CGRect(x: CGFloat(index) * (slotWidth + slotSpacing), y: 0, width: slotWidth, height: slotContentView.frame.size.height)
                slotContainerLayer.masksToBounds = true
                let slotScrollLayer = CALayer()
                slotScrollLayer.frame = CGRect(x: 0, y: 0, width: slotWidth, height: slotContentView.frame.size.height)
                #if SHOW_BORDER
                slotScrollLayer.borderColor = UIColor.green.cgColor
                slotScrollLayer.borderWidth = 1
                #endif
                slotContainerLayer.addSublayer(slotScrollLayer)
                slotContentView.layer.addSublayer(slotContainerLayer)
                firstSlotScrollLayerArray.append(slotScrollLayer)
            }
            
            let singleUnitHeight = slotContentView.frame.size.height
            
            guard let slotIcons = self.dataSource?.iconsForSlots(in: self) else { return }
            let iconCount = slotIcons.count
            
            for index in 0 ..< numberOfSlot {
                guard let slotScrollLayer = firstSlotScrollLayerArray[safe: index] else {return}
                let scrollLayerTopIndex = -(index + kMinTurn + 3) * iconCount
                
                for reverseIndex in (scrollLayerTopIndex ... 0).reversed() {
                    let makeIndex = abs(reverseIndex) % iconCount
                    guard let iconImage = slotIcons[safe: makeIndex] else {return}
                    let iconImageLayer = CALayer()
                    let offsetYUnit: CGFloat = CGFloat(reverseIndex + iconCount)
                    iconImageLayer.frame = CGRect(x: 0, y: offsetYUnit * singleUnitHeight, width: slotScrollLayer.frame.size.width, height: singleUnitHeight)
                    
                    iconImageLayer.contents = iconImage.cgImage
                    iconImageLayer.contentsScale = iconImage.scale
                    iconImageLayer.contentsGravity = .resizeAspect
                    #if SHOW_BORDER
                    iconImageLayer.borderColor = UIColor.red.cgColor
                    iconImageLayer.borderWidth = 1
                    #endif
                    slotScrollLayer.addSublayer(iconImageLayer)
                }
                
            }
        } else {
            self.secondSlotScrollLayerArray = []
            
            let numberOfSlot = dataSource.numberOfSlots(in: self)
            var slotSpacing: CGFloat = 0
            var slotWidth: CGFloat = 0
            if let spacing = self.dataSource?.slotSpacing(in: self), let width = self.dataSource?.slotWidth(in: self) {
                slotSpacing = spacing
                slotWidth = width
            }
            
            for index in 0 ..< numberOfSlot {
                let slotContainerLayer = CALayer()
                slotContainerLayer.frame = CGRect(x: CGFloat(index) * (slotWidth + slotSpacing), y: 0, width: slotWidth, height: slotContentView.frame.size.height)
                slotContainerLayer.masksToBounds = true
                let slotScrollLayer = CALayer()
                slotScrollLayer.frame = CGRect(x: 0, y: 0, width: slotWidth, height: slotContentView.frame.size.height)
                #if SHOW_BORDER
                slotScrollLayer.borderColor = UIColor.green.cgColor
                slotScrollLayer.borderWidth = 1
                #endif
                slotContainerLayer.addSublayer(slotScrollLayer)
                slotContentView.layer.addSublayer(slotContainerLayer)
                secondSlotScrollLayerArray.append(slotScrollLayer)
            }
            
            let singleUnitHeight = slotContentView.frame.size.height
            
            guard let slotIcons = self.dataSource?.iconsForSlots(in: self) else { return }
            let iconCount = slotIcons.count
            
            for index in 0 ..< numberOfSlot {
                guard let slotScrollLayer = secondSlotScrollLayerArray[safe: index] else {return}
                let scrollLayerTopIndex = -(index + kMinTurn + 3) * iconCount
                
                for reverseIndex in (scrollLayerTopIndex ... 0).reversed() {
                    let makeIndex = abs(reverseIndex) % iconCount
                    guard let iconImage = slotIcons[safe: makeIndex] else {return}
                    let iconImageLayer = CALayer()
                    let offsetYUnit: CGFloat = CGFloat(reverseIndex + iconCount)
                    iconImageLayer.frame = CGRect(x: 0, y: offsetYUnit * singleUnitHeight, width: slotScrollLayer.frame.size.width, height: singleUnitHeight)
                    
                    iconImageLayer.contents = iconImage.cgImage
                    iconImageLayer.contentsScale = iconImage.scale
                    iconImageLayer.contentsGravity = .resizeAspect
                    #if SHOW_BORDER
                    iconImageLayer.borderColor = UIColor.red.cgColor
                    iconImageLayer.borderWidth = 1
                    #endif
                    slotScrollLayer.addSublayer(iconImageLayer)
                }
                
            }
        }
    }
    
    func startSliding() {
        self.okButton.isHidden = true
        if isSliding {
            isSliding = true
            
            self.delegate?.slotMachineWillStratSliding(self)
            self.titleLabel.text = "행운캐시 등장!"
            guard let slotIcons = self.dataSource?.iconsForSlots(in: self) else { return }
            let slotIconsCount = slotIcons.count
            
            var completePositionArray: [CGFloat] = []
            
            for containerLayer in firstSlotScrollLayerArray {
                containerLayer.removeFromSuperlayer()
            }
            
            CATransaction.begin()
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeOut))
            CATransaction.setDisableActions(false)
            CATransaction.setCompletionBlock { [weak self] in
                guard let self = self else { return }
                self.isSliding = false
                self.okButton.isHidden = false
                self.delegate?.slotMachineDidEndSliding(self, point: self.point)
                self.titleLabel.text = "행운캐시 당첨!"
                for index in 0 ..< self.secondSlotScrollLayerArray.count {
                    let slotScrollLayer = self .secondSlotScrollLayerArray[index]
                    
                    slotScrollLayer.position = CGPoint(x: slotScrollLayer.position.x, y: CGFloat(completePositionArray[index]))
                    var toBeDeletedLayerArray = [CALayer]()
                    
                    guard let slotResults = self.slotResults else { return }
                    let resultIndex = Int((slotResults[index] as NSNumber).uintValue)
                    
                    for j in 0 ..< slotIconsCount * (self.kMinTurn + index) + resultIndex {
                        
                        if let iconLayer = slotScrollLayer.sublayers?[j] {
                            toBeDeletedLayerArray.append(iconLayer)
                        }
                    }
                    
                    for toBeDeletedLayer in toBeDeletedLayerArray {
                        let toBeAddedLayer = CALayer()
                        toBeAddedLayer.frame = toBeDeletedLayer.frame
                        toBeAddedLayer.contents = toBeDeletedLayer.contents
                        toBeAddedLayer.contentsScale = toBeDeletedLayer.contentsScale
                        toBeAddedLayer.contentsGravity = toBeDeletedLayer.contentsGravity
                        let shiftY = CGFloat(slotIconsCount) * toBeAddedLayer.frame.size.height * CGFloat((self.kMinTurn + index + 3))
                        toBeAddedLayer.position = CGPoint(x: toBeAddedLayer.position.x, y: toBeAddedLayer.position.y - shiftY)
                        
                        slotScrollLayer.addSublayer(toBeAddedLayer)
                    }
                    toBeDeletedLayerArray = []
                }
                completePositionArray = []
            }
            
            let keyPath = "position.y"
            
            for index in 0 ..< secondSlotScrollLayerArray.count {
                let slotScrollLayer = secondSlotScrollLayerArray[index]
                guard let slotResults = self.slotResults else { return }
               
                let resultIndex = Int((slotResults[index] as NSNumber).uintValue)
               
                let howManyUnit = (index + self.kMinTurn) * slotIconsCount + resultIndex
                let slideY = CGFloat(howManyUnit) * (self.slotContentView.frame.size.height )
               
                let slideAnimation = CABasicAnimation(keyPath: keyPath)
                slideAnimation.fillMode = .forwards
                slideAnimation.duration = CFTimeInterval(CGFloat(howManyUnit) * self.singleUnitDuration)
                slideAnimation.toValue = slotScrollLayer.position.y + slideY
                slideAnimation.isRemovedOnCompletion = false
                slotScrollLayer.add(slideAnimation, forKey: "slideAnimation")
                if let makeValue = slideAnimation.toValue as? CGFloat {
                    completePositionArray.append(makeValue)
                }
            }
            
            CATransaction.commit()
        } else {
            isSliding = true
            self.delegate?.slotMachineWillStratSliding(self)
            self.titleLabel.text = "행운캐시 등장!"
            guard let slotIcons = self.dataSource?.iconsForSlots(in: self) else { return }
            let slotIconsCount = slotIcons.count
            
            var completePositionArray: [CGFloat] = []
            
            requestWinner()
            
            CATransaction.begin()
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeOut))
            CATransaction.setDisableActions(false)
            CATransaction.setCompletionBlock { [weak self] in
                guard let self = self else { return }
                for index in 0 ..< self.firstSlotScrollLayerArray.count {
                    let slotScrollLayer = self .firstSlotScrollLayerArray[index]
                    
                    slotScrollLayer.position = CGPoint(x: slotScrollLayer.position.x, y: CGFloat(completePositionArray[index]))
                    var toBeDeletedLayerArray = [CALayer]()
                    
                    guard let slotResults = self.slotResults else { return }
                    let resultIndex = Int((slotResults[index] as NSNumber).uintValue)
                    
                    for j in 0 ..< slotIconsCount * (self.kMinTurn + index) + resultIndex {
                        
                        if let iconLayer = slotScrollLayer.sublayers?[j] {
                            toBeDeletedLayerArray.append(iconLayer)
                        }
                    }
                    
                    for toBeDeletedLayer in toBeDeletedLayerArray {
                        let toBeAddedLayer = CALayer()
                        toBeAddedLayer.frame = toBeDeletedLayer.frame
                        toBeAddedLayer.contents = toBeDeletedLayer.contents
                        toBeAddedLayer.contentsScale = toBeDeletedLayer.contentsScale
                        toBeAddedLayer.contentsGravity = toBeDeletedLayer.contentsGravity
                        let shiftY = CGFloat(slotIconsCount) * toBeAddedLayer.frame.size.height * CGFloat((self.kMinTurn + index + 3))
                        toBeAddedLayer.position = CGPoint(x: toBeAddedLayer.position.x, y: toBeAddedLayer.position.y - shiftY)
                        
                        toBeDeletedLayer.removeFromSuperlayer()
                        slotScrollLayer.addSublayer(toBeAddedLayer)
                    }
                    toBeDeletedLayerArray = []
                }
                completePositionArray = []
            }
            
            let keyPath = "position.y"
            
            for index in 0 ..< firstSlotScrollLayerArray.count {
                let slotScrollLayer = firstSlotScrollLayerArray[index]
                guard let slotResults = self.slotResults else { return }
               
                let resultIndex = Int((slotResults[index] as NSNumber).uintValue)
               
                let howManyUnit = (index + self.kMinTurn) * slotIconsCount + resultIndex
                let slideY = CGFloat(howManyUnit) * (self.slotContentView.frame.size.height )
               
                let slideAnimation = CABasicAnimation(keyPath: keyPath)
                slideAnimation.fillMode = .forwards
                slideAnimation.duration = CFTimeInterval(CGFloat(howManyUnit) * self.singleUnitDuration)
                slideAnimation.toValue = slotScrollLayer.position.y + slideY
                slideAnimation.isRemovedOnCompletion = false
                slotScrollLayer.add(slideAnimation, forKey: "slideAnimation")
                if let makeValue = slideAnimation.toValue as? CGFloat {
                    completePositionArray.append(makeValue)
                }
            }
            CATransaction.commit()
        }
    }
    
    @objc private func closeButtonAction(_ sender: UIButton) {
        self.delegate?.slotMachineClosed(self, isSliding: self.isSliding)
        self.okButton.isHidden = true
        self.isSliding = false
        for containerLayer in slotContentView.layer.sublayers ?? [] {
            self.firstSlotScrollLayerArray = []
            self.secondSlotScrollLayerArray = []
            containerLayer.removeFromSuperlayer()
        }
    }
    
    private func startScroll() {
        guard timer == nil, winners.count > 1, isScroll else {return}
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(startAutoScroll), userInfo: nil, repeats: true)
    }
    
    @objc private func startAutoScroll() {
        if !isScroll || self.winners.count < 1 {
            return
        }
        noticeIndex = noticeIndex >= winners.count-1 ? 0 : noticeIndex+1
        
        if firstNoticeLabel.isHidden {
            firstNoticeLabel.isHidden = false
            
            UIView.animate(withDuration: 0.4, animations: {
                self.secondViewTop.constant = -50
                self.firstViewTop.constant = 0
                self.layoutIfNeeded()
            }, completion: { (_) in
                self.secondNoticeLabel.isHidden = true
                self.secondViewTop.constant = 50
                if self.winners.count - 1 < self.noticeIndex {
                    return
                }
                self.secondNoticeLabel.text = self.convertWinnerLabel(winner: self.winners[self.noticeIndex])
            })
        } else {
            secondNoticeLabel.isHidden = false
            
            UIView.animate(withDuration: 0.4, animations: {
                self.firstViewTop.constant = -50
                self.secondViewTop.constant = 0
                self.layoutIfNeeded()
            }, completion: { (_) in
                self.firstNoticeLabel.isHidden = true
                self.firstViewTop.constant = 50
                if self.winners.count - 1 < self.noticeIndex {
                    return
                }
                self.firstNoticeLabel.text = self.convertWinnerLabel(winner: self.winners[self.noticeIndex])
            })
        }
    }
    
    func stopSlotmachine() {
        self.delegate?.slotMachineClosed(self, isSliding: self.isSliding)
        self.okButton.isHidden = true
        self.isSliding = false
        for containerLayer in slotContentView.layer.sublayers ?? [] {
            self.firstSlotScrollLayerArray = []
            self.secondSlotScrollLayerArray = []
            containerLayer.removeFromSuperlayer()
        }
    }
    
    private func requestWinner() {
        self.noticeIndex = 0
        self.pointProvider.request(WinnerModel.self, token: .winner)
            .subscribe(onSuccess: { [weak self] (model) in
                guard let self = self, model.result.winners.count > 0 else { return }
                self.winners = []
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.winners = model.result.winners
                }
            }, onError: { (_) in
                self.winners = []
        })
        .disposed(by: disposeBag)
    }
    
    private func convertWinnerLabel(winner: WinnerList) -> String {
        let winnerDate = Date(timeIntervalSince1970: TimeInterval(winner.id / 1000))
        let time = "\(Date.sinceNowKor(date: winnerDate)) "
        let name = "\(winner.nickname)님이 "
        var cash = String()
        if winner.point < 10000 {
            cash = winner.point.commaValue + "캐시에 당첨되었습니다."
        } else {
            cash = "\(winner.point / 10000)만" + "캐시에 당첨되었습니다."
        }
        return time + name + cash
    }
}

extension TJSlotMachine {
    private func layout() {
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 14).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).isActive = true
        closeButton.widthAnchor.constraint(equalTo: self.closeButton.heightAnchor).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        backgroundImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        backgroundImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        contentView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12).isActive = true
        contentView.widthAnchor.constraint(equalToConstant: 282.5).isActive = true
        contentView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: noticeView.topAnchor, constant: -12).isActive = true
        
        slotContentView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12).isActive = true
        slotContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.5).isActive = true
        slotContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10.5).isActive = true
        slotContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12).isActive = true
        
        coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        coverImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        coverImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        noticeView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        noticeView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 17).isActive = true
        noticeView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -17).isActive = true
        noticeView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12).isActive = true
        noticeView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        firstViewTop = firstNoticeLabel.topAnchor.constraint(equalTo: noticeView.topAnchor, constant: 0)
        firstViewTop.isActive = true
        firstNoticeLabel.leadingAnchor.constraint(equalTo: noticeView.leadingAnchor, constant: 8).isActive = true
        firstNoticeLabel.trailingAnchor.constraint(equalTo: noticeView.trailingAnchor, constant: -8).isActive = true
        firstNoticeLabel.heightAnchor.constraint(equalTo: noticeView.heightAnchor).isActive = true
        
        secondViewTop = secondNoticeLabel.topAnchor.constraint(equalTo: noticeView.topAnchor, constant: 50)
        secondViewTop.isActive = true
        secondNoticeLabel.leadingAnchor.constraint(equalTo: noticeView.leadingAnchor, constant: 8).isActive = true
        secondNoticeLabel.trailingAnchor.constraint(equalTo: noticeView.trailingAnchor, constant: -8).isActive = true
        secondNoticeLabel.heightAnchor.constraint(equalTo: noticeView.heightAnchor).isActive = true
        
        okButton.topAnchor.constraint(equalTo: noticeView.topAnchor).isActive = true
        okButton.leadingAnchor.constraint(equalTo: noticeView.leadingAnchor).isActive = true
        okButton.trailingAnchor.constraint(equalTo: noticeView.trailingAnchor).isActive = true
        okButton.bottomAnchor.constraint(equalTo: noticeView.bottomAnchor).isActive = true
    }
}
