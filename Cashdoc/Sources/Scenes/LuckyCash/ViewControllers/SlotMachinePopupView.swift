//
//  SMSlotMachine.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/06/24.
//  Copyright © 2020 Cashwalk, Inc. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import QuartzCore
import AudioToolbox
import AVFoundation

protocol SlotMachinePopupViewDelegate: AnyObject {
    func didEndSliding(_ slotMachine: SlotMachinePopupView, point: Int)
    func didClickCloseButton(_ slotMachine: SlotMachinePopupView)
    func TouchRouletteStop(_ slotMachine: SlotMachinePopupView)
}

class SlotMachinePopupView: BasePopupView {
    
    var slotResults: [Int]? {
        didSet {
            guard let cash1 = slotResults?.first else { return }
            guard let cash2 = slotResults?[safe: 1] else { return }
            guard let cash3 = slotResults?[safe: 2] else { return }
            
            var cash = 0
            if cash1 == cash2 && cash2 == cash3 {
                cash = cash1 + 1
            }
            
            switch cash {
            case 0:
                intPoint = 1
                point = "1"
            case 1:
                intPoint = 100
                point = "100"
            case 2:
                intPoint = 1000
                point = 1000.commaValue
            case 3:
                intPoint = 5000
                point = 5000.commaValue
            case 4:
                intPoint = 10000
                point = "1만"
            default:
                intPoint = 0
                point = "0"
            }
        }
    }
    var point: String = "0"
    var intPoint = 0
    var isNetworkError: Bool = true
    var isStopScrollFirst = false
    var isStopScrollSecond = false
    var isStopScrollThird = false
    let scrollIndexCount = 2
    let stopScrollIndexCount = 4
    let autoScrollDuration = 0.5
    let autoScrollFirstDuration = 1.5
    
    weak var delegate: SlotMachinePopupViewDelegate?
    
    // MARK: - Properties
    
    private weak var scrollTimer: Timer?
    private weak var scrollStopTimer: Timer?
    
    private var audioPlayer: AVAudioPlayer?
    private let slotImages: [String] = [
        "100cash",
        "1000cash",
        "5000cash",
        "10000cash"
    ]
    private var titleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        #if CASHWALK
        imageView.image = UIImage(named: "imgRouletteTitleWalk")
        #else
        imageView.image = UIImage(named: "imgRouletteTitle")
        #endif
        return imageView
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
        imageView.image = UIImage(named: "imgRouletteBody1")
        return imageView
    }()
    private var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let slotContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let flowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = 0
        $0.minimumInteritemSpacing = 0
        $0.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    private var slotScrollView1 = UIScrollView(frame: .zero).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.bounces = false
        $0.isPagingEnabled = true
        $0.isScrollEnabled = false
        $0.backgroundColor = .clear
    }
    private var slotScrollView2 = UIScrollView(frame: .zero).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.bounces = false
        $0.isPagingEnabled = true
        $0.isScrollEnabled = false
        $0.backgroundColor = .clear
    }
    private var slotScrollView3 = UIScrollView(frame: .zero).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.bounces = false
        $0.isPagingEnabled = true
        $0.isScrollEnabled = false
        $0.backgroundColor = .clear
    }
    private var touchSlotImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.isHidden = true
        return imageView
    }()
    private let touchSlotButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    private let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "icCloseWhite"), for: .normal)
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        bindView()
        
        addSubview(coverImageView)
        addSubview(contentView)
        addSubview(slotScrollView1)
        addSubview(slotScrollView2)
        addSubview(slotScrollView3)
        addSubview(touchSlotImageView)
        addSubview(touchSlotButton)
        addSubview(closeButton)
        
        layout()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else {return}
            self.setContentScrollView()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    // MARK: - Private methods
    
    private func bindView() {
        touchSlotButton.addTarget(self, action: #selector(touchRouletteButtonAction(_:)), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonAction(_:)), for: .touchUpInside)
    }
    
    private func playSound(name: String, ext: String) {
        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.volume = AVAudioSession.sharedInstance().outputVolume > 0.5 ? 0.5 : 1
                audioPlayer?.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
    }
    
    private func setTimer() {
        endTimer()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.autoScrollFirst()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + (autoScrollFirstDuration - autoScrollDuration - 0.1)) { [weak self] in
            guard let self = self else {return}
            self.scrollTimer = Timer.scheduledTimer(timeInterval: self.autoScrollDuration, target: self, selector: #selector(self.autoScroll), userInfo: nil, repeats: true)
        }
        self.scrollStopTimer = Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(self.stopScroll), userInfo: nil, repeats: false)
    }
    
    private func setContentScrollView() {
        slotScrollView1.contentSize = CGSize(width: slotScrollView1.frame.width, height: slotScrollView1.frame.height * CGFloat(slotImages.count * stopScrollIndexCount))
        slotScrollView2.contentSize = CGSize(width: slotScrollView2.frame.width, height: slotScrollView2.frame.height * CGFloat(slotImages.count * stopScrollIndexCount))
        slotScrollView3.contentSize = CGSize(width: slotScrollView3.frame.width, height: slotScrollView3.frame.height * CGFloat(slotImages.count * stopScrollIndexCount))
        
        // 당첨 이후 마지막 당첨 값으로 초기 셋팅
        guard let cash1 = slotResults?.first else { return }
        guard let cash2 = slotResults?[safe: 1] else { return }
        guard let cash3 = slotResults?[safe: 2] else { return }
        Log.bz("당첨 값으로 초기 셋팅 : \(cash1),\(cash2),\(cash3)")
        
        self.slotScrollView1.setContentOffset(CGPoint(x: 0, y: (self.slotImages.count * self.stopScrollIndexCount - 4 + cash1) * 92), animated: false)
        self.slotScrollView2.setContentOffset(CGPoint(x: 0, y: (self.slotImages.count * self.stopScrollIndexCount - 4 + cash2) * 92), animated: false)
        self.slotScrollView3.setContentOffset(CGPoint(x: 0, y: (self.slotImages.count * self.stopScrollIndexCount - 4 + cash3) * 92), animated: false)
        
        for i in 0..<(slotImages.count * stopScrollIndexCount) {
            if let image = slotImages[safe: (i%4)] {
                var frame = CGRect()
                frame.origin.x = 0
                frame.origin.y = slotScrollView1.frame.size.height * CGFloat(i)
                frame.size = slotScrollView1.frame.size
                
                let imageView1 = UIImageView(frame: frame)
                slotScrollView1.addSubview(imageView1)
                imageView1.image = UIImage(named: image)
                
                let imageView2 = UIImageView(frame: frame)
                slotScrollView2.addSubview(imageView2)
                imageView2.image = UIImage(named: image)
                
                let imageView3 = UIImageView(frame: frame)
                slotScrollView3.addSubview(imageView3)
                imageView3.image = UIImage(named: image)
            }
        }
    }
    
    // MARK: - Internal methods
    func backgroundStop() {
        self.audioPlayer?.stop()
        self.touchSlotImageView.isHidden = true
        self.touchSlotButton.isEnabled = false
    }
    
    func endTimer() {
        scrollTimer?.invalidate()
        scrollTimer = nil
        scrollStopTimer?.invalidate()
        scrollStopTimer = nil
    }
    
    func stopSliding() {
        scrollStopTimer?.invalidate()
        scrollStopTimer = nil
        stopSlotMachine()
    }
    
    func startSliding() {
        coverImageView.animationImages = [
            UIImage(named: "imgRouletteBody2")!,
            UIImage(named: "imgRouletteBody3")!,
            UIImage(named: "imgRouletteBody4")!,
            UIImage(named: "imgRouletteBody1")!
        ]
        coverImageView.animationDuration = 2
        coverImageView.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.touchSlotImageView.isHidden = false
            self?.touchSlotImageView.animationImages = [
                UIImage(named: "imgRouletteTouch1")!,
                UIImage(named: "imgRouletteTouch2")!
            ]
            self?.touchSlotImageView.animationDuration = 1
            self?.touchSlotImageView.startAnimating()
            self?.touchSlotButton.isEnabled = true
        }
        
        playSound(name: "wheel_sound", ext: "mp3")
        
        setTimer()
    }
    
    func stopSlotMachine() {
        self.touchSlotImageView.isHidden = true
        self.touchSlotButton.isEnabled = false
        
        let shuffledNumbers = [0, 1, 2].shuffled()
        print(shuffledNumbers)
        
        let deadlineSeconds = [0, 1.5, 3.0]
        
        let shuffledImages = [0, 1, 2].shuffled()
        print(shuffledImages)
        
        if intPoint <= 1 {
            if shuffledNumbers[safe: 0] == 2 {
                slotResults?[0] = shuffledImages[safe: 1] ?? 1
                slotResults?[1] = shuffledImages[safe: 0] ?? 0
                slotResults?[2] = shuffledImages[safe: 0] ?? 0
            } else if shuffledNumbers[safe: 1] == 2 {
                slotResults?[0] = shuffledImages[safe: 0] ?? 0
                slotResults?[1] = shuffledImages[safe: 1] ?? 1
                slotResults?[2] = shuffledImages[safe: 0] ?? 0
            } else {
                slotResults?[0] = shuffledImages[safe: 0] ?? 0
                slotResults?[1] = shuffledImages[safe: 0] ?? 0
                slotResults?[2] = shuffledImages[safe: 1] ?? 1
            }
        }
        
        guard let cash1 = slotResults?.first else { return }
        guard let cash2 = slotResults?[safe: 1] else { return }
        guard let cash3 = slotResults?[safe: 2] else { return }
        
        self.delegate?.TouchRouletteStop(self)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + deadlineSeconds[shuffledNumbers[safe: 0] ?? 0]) { [weak self] in
            guard let self = self else {return}
            self.isStopScrollFirst = true
            UIView.animate(withDuration: 2.0, delay: 0.0, options: .curveEaseOut, animations: {
                self.slotScrollView1.setContentOffset(CGPoint(x: 0, y: cash1 * 92), animated: false)
            }, completion: nil)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + deadlineSeconds[shuffledNumbers[safe: 1] ?? 1]) { [weak self] in
            guard let self = self else {return}
            self.isStopScrollSecond = true
            UIView.animate(withDuration: 2.0, delay: 0.0, options: .curveEaseOut, animations: {
                self.slotScrollView2.setContentOffset(CGPoint(x: 0, y: cash2 * 92), animated: false)
            }, completion: nil)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + deadlineSeconds[shuffledNumbers[safe: 2] ?? 2]) { [weak self] in
            guard let self = self else {return}
            self.isStopScrollThird = true
            UIView.animate(withDuration: 2.0, delay: 0.0, options: .curveEaseOut, animations: {
                self.slotScrollView3.setContentOffset(CGPoint(x: 0, y: cash3 * 92), animated: false)
            }, completion: nil)
        }
    }
    func autoScrollFirst() {
        
        if !isStopScrollFirst {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                UIView.animate(withDuration: self.autoScrollFirstDuration, delay: 0.0, options: .curveEaseIn, animations: { [weak self] in
                    guard let self = self else {return}
                    self.slotScrollView1.setContentOffset(CGPoint(x: 0, y: 92), animated: false)
                })
            }
        }
        
        if !isStopScrollSecond {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                UIView.animate(withDuration: self.autoScrollFirstDuration - 0.1, delay: 0.1, options: .curveEaseIn, animations: { [weak self] in
                    guard let self = self else {return}
                    self.slotScrollView2.setContentOffset(CGPoint(x: 0, y: 92), animated: false)
                })
            }
        }
        
        if !isStopScrollThird {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                UIView.animate(withDuration: self.autoScrollFirstDuration - 0.2, delay: 0.2, options: .curveEaseIn, animations: { [weak self] in
                    guard let self = self else {return}
                    self.slotScrollView3.setContentOffset(CGPoint(x: 0, y: 92), animated: false)
                })
            }
        }
    }
    
    // create auto scroll
    @objc func autoScroll() {
        if !isStopScrollFirst {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                self.slotScrollView1.setContentOffset(CGPoint(x: 0, y: self.slotImages.count * self.stopScrollIndexCount * 92), animated: false)
                UIView.animate(withDuration: self.autoScrollDuration, delay: 0.0, options: .curveLinear, animations: { [weak self] in
                    guard let self = self else {return}
                    self.slotScrollView1.setContentOffset(CGPoint(x: 0, y: self.slotImages.count * self.scrollIndexCount * 92), animated: false)
                })
            }
        }
        
        if !isStopScrollSecond {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                self.slotScrollView2.setContentOffset(CGPoint(x: 0, y: self.slotImages.count * self.stopScrollIndexCount * 92), animated: false)
                UIView.animate(withDuration: self.autoScrollDuration, delay: 0.0, options: .curveLinear, animations: { [weak self] in
                    guard let self = self else {return}
                    self.slotScrollView2.setContentOffset(CGPoint(x: 0, y: self.slotImages.count * self.scrollIndexCount * 92), animated: false)
                })
            }
        }
        
        if !isStopScrollThird {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                self.slotScrollView3.setContentOffset(CGPoint(x: 0, y: self.slotImages.count * self.stopScrollIndexCount * 92), animated: false)
                UIView.animate(withDuration: self.autoScrollDuration, delay: 0.0, options: .curveLinear, animations: { [weak self] in
                    guard let self = self else {return}
                    self.slotScrollView3.setContentOffset(CGPoint(x: 0, y: self.slotImages.count * self.scrollIndexCount * 92), animated: false)
                })
            }
        }
        if isStopScrollFirst == true && isStopScrollSecond == true && isStopScrollThird == true {
            endTimer()
            isStopScrollFirst = false
            isStopScrollSecond = false
            isStopScrollThird = false
            coverImageView.stopAnimating()
            self.audioPlayer?.stop()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self else { return }
                self.delegate?.didEndSliding(self, point: self.intPoint)
            }
        }
    }
    
    @objc private func closeButtonAction(_ sender: UIButton) {
        self.delegate?.didClickCloseButton(self)
    }
    
    @objc private func touchRouletteButtonAction(_ sender: UIButton) {
        scrollStopTimer?.invalidate()
        scrollStopTimer = nil
        stopSlotMachine()
        
    }
    
    @objc func stopScroll() {
        stopSlotMachine()
    }
    
}

extension SlotMachinePopupView {
    private func layout() {
        // for test
        let naviHeight = GlobalDefine.shared.curNav?.navigationBar.frame.height ?? 0
        contentView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        contentView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: naviHeight).isActive = true
        contentView.widthAnchor.constraint(equalToConstant: 290).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: 123).isActive = true
        
        slotScrollView1.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        slotScrollView1.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 2-88).isActive = true
        slotScrollView1.widthAnchor.constraint(equalToConstant: 84).isActive = true
        slotScrollView1.heightAnchor.constraint(equalToConstant: 92).isActive = true
        
        slotScrollView2.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        slotScrollView2.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 2).isActive = true
        slotScrollView2.widthAnchor.constraint(equalToConstant: 84).isActive = true
        slotScrollView2.heightAnchor.constraint(equalToConstant: 92).isActive = true
        
        slotScrollView3.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        slotScrollView3.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 2+88).isActive = true
        slotScrollView3.widthAnchor.constraint(equalToConstant: 84).isActive = true
        slotScrollView3.heightAnchor.constraint(equalToConstant: 92).isActive = true
        
        touchSlotButton.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        touchSlotButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        touchSlotButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        touchSlotButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        touchSlotImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        touchSlotImageView.centerYAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        touchSlotImageView.widthAnchor.constraint(equalToConstant: 59).isActive = true
        touchSlotImageView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        
        coverImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        coverImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        coverImageView.widthAnchor.constraint(equalToConstant: 290).isActive = true
        coverImageView.heightAnchor.constraint(equalToConstant: 123).isActive = true
        
        closeButton.snp.makeConstraints { (m) in
            m.top.equalToSuperview().inset(UIApplication.shared.statusBarFrame.height+8)
            m.leading.equalToSuperview().inset(10)
            m.size.equalTo(24)
        }
    }
}
