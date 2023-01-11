//
//  LuckyCashPopupView.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/06/24.
//  Copyright © 2020 Cashwalk, Inc. All rights reserved.
//

import RxCocoa
import RxSwift
import Then
import Lottie
import AudioToolbox
import AVFoundation
import UIKit

protocol LuckyCashPopupViewDelegate: NSObjectProtocol {
    func didClickConfirmButton(_ view: LuckyCashPopupView)
    func didClickReviewButton(_ view: LuckyCashPopupView)
    func didClickGoBackButton(_ view: LuckyCashPopupView)
}

class LuckyCashPopupView: BasePopupView {
    
    enum LuckyCashPopupType {
        case winningNoraml, winningLucky, goBack, loading, chanceExhaust, todayChanceExhaust
    }
    
    // MARK: - Properties
    
    weak var delegate: LuckyCashPopupViewDelegate?
    private var audioPlayer: AVAudioPlayer?
    var popupType: LuckyCashPopupType?
    var point: Int = 0
    
    // MARK: - UI Components
    
    private let backgroundView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    
    private let topImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let subContentView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
    }
    
    private let winningLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        $0.textColor = UIColor.fromRGB(255, 171, 35)
        $0.textAlignment = .center
        $0.text = ""
    }
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        $0.textColor = .blackTwoCw
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = ""
    }
    
    private let detailLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .blackCw
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = ""
    }
    
    private let horizontalLine = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .lineGrayCw
    }
    
    private let verticalLine = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .lineGrayCw
    }
    
    private let confirmButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("", for: .normal)
        $0.setTitleColor(.blackThreeCw, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        $0.backgroundColor = .white
    }
    
    private let leftButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("", for: .normal)
        $0.setTitleColor(.blackThreeCw, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        $0.backgroundColor = .white
    }
    
    private let rightButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("", for: .normal)
        $0.setTitleColor(.blackCw, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        $0.backgroundColor = .white
    }
    
    private let closeButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setBackgroundImage(UIImage(named: "icCloseWhite"), for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .clear
    }
    
    #if CASHWALK
    private let motionNormalImageView = LOTAnimationView(name: "firecracker").then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.loopAnimation = true
        $0.contentMode = .scaleAspectFill
        $0.isHidden = true
    }
    #else
    private let motionNormalImageView = LottieAnimationView().then {
        guard let path = Bundle.main.path(forResource: "firecracker", ofType: "json") else { return }
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.contentMode = .scaleAspectFill
        $0.animation = LottieAnimation.filepath(path)
        $0.loopMode = .loop
        $0.isHidden = true
    }
    #endif
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setSelector()
        addSubview(backgroundView)
        backgroundView.addSubview(topImageView)
        backgroundView.addSubview(subContentView)
        subContentView.addSubview(winningLabel)
        subContentView.addSubview(titleLabel)
        subContentView.addSubview(detailLabel)
        backgroundView.addSubview(confirmButton)
        backgroundView.addSubview(leftButton)
        backgroundView.addSubview(rightButton)
        backgroundView.addSubview(horizontalLine)
        backgroundView.addSubview(verticalLine)
        backgroundView.addSubview(motionNormalImageView)
        addSubview(closeButton)
        layout()
         
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Overridden: BasePopupView
    
    override var isDismissEnabledBackgroundTouch: Bool {
        return false
    }
    
    // MARK: - Private methods
    
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
    
    private func setSelector() {
        confirmButton.addTarget(self, action: #selector(didClickedCloseButton), for: .touchUpInside)
        leftButton.addTarget(self, action: #selector(didClickedLeftButton), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(didClickedRightButton), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(didClickedCloseButton), for: .touchUpInside)
    }
    
    private func setProperties(dictionary: [String: String]) {
        
        containerView.backgroundColor = .clear
        
        guard let topImage = dictionary["topImage"], let title = dictionary["title"], let detail = dictionary["detail"] else { return }
        
        let winning = dictionary["winning"] ?? nil
        let confirm = dictionary["confirm"] ?? nil
        let left = dictionary["left"] ?? nil
        let right = dictionary["right"] ?? nil
        
        topImageView.image = UIImage(named: topImage)
        if winning == nil {
            winningLabel.isHidden = true
        } else {
            winningLabel.text = winning
        }
        titleLabel.text = title
        detailLabel.text = detail
        if confirm == nil {
            confirmButton.isHidden = true
            leftButton.isHidden = false
            rightButton.isHidden = false
        } else {
            verticalLine.isHidden = true
            confirmButton.isHidden = false
            leftButton.isHidden = true
            rightButton.isHidden = true
            confirmButton.setTitle(confirm, for: .normal)
        }
        if left == nil {
            verticalLine.isHidden = true
            confirmButton.isHidden = false
            leftButton.isHidden = true
            rightButton.isHidden = true
        } else {
            confirmButton.isHidden = true
            leftButton.isHidden = false
            rightButton.isHidden = false
            leftButton.setTitle(left, for: .normal)
        }
        if right == nil {
            verticalLine.isHidden = true
            confirmButton.isHidden = false
            leftButton.isHidden = true
            rightButton.isHidden = true
        } else {
            confirmButton.isHidden = true
            leftButton.isHidden = false
            rightButton.isHidden = false
            rightButton.setTitle(right, for: .normal)
        }
        
    }
    // MARK: - Private selector
    
    @objc private func didClickedCloseButton() {
        backgroundStop()
        self.delegate?.didClickConfirmButton(self)
    }
    
    @objc private func didClickedLeftButton() {
        backgroundStop()
        guard let type = popupType else {return}
        switch type {
        case .winningNoraml, .loading, .chanceExhaust, .todayChanceExhaust:
            break
        case .winningLucky:
            self.delegate?.didClickConfirmButton(self)
        case .goBack:
            self.delegate?.didClickGoBackButton(self)
        }
    }
    
    @objc private func didClickedRightButton() {
        backgroundStop()
        guard let type = popupType else {return}
        switch type {
        case .winningNoraml, .loading, .chanceExhaust, .todayChanceExhaust:
            break
        case .winningLucky:
            // 리뷰남기기
            self.delegate?.didClickReviewButton(self)
        case .goBack:
            self.delegate?.didClickConfirmButton(self)
        }
    }
    
    // MARK: - Overridden: UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let type = popupType else {return}
        switch type {
        case .winningNoraml:
            let dict: [String: String] = [
                "topImage": "imgRouletteNormal",
                "winning": "축하드려요!",
                "title": "1 캐시",
                "detail": "1캐시 당첨을 축하합니다!\n10,000캐시 행운에 다시 도전해보세요.",
                "confirm": "확인"
            ]
            setProperties(dictionary: dict)
            motionNormalImageView.isHidden = false
            self.motionNormalImageView.play()
        case .winningLucky:
            let dict: [String: String] = [
                "topImage": "imgRouletteLucky",
                "winning": "와우! 축하드려요!",
                "title": "\(String(describing: point.commaValue)) 캐시",
                "detail": "\(String(describing: point.commaValue))캐시 당첨을 축하합니다!\n좋은 리뷰 남겨주시면 더 좋은 일이 생길거예요~",
                "left": "확인",
                "right": "리뷰 남기기"
            ]
            setProperties(dictionary: dict)
            motionNormalImageView.isHidden = true
            self.playSound(name: "lottery_sound_lucky", ext: "mp3")
        case .goBack:
            let dict: [String: String] = [
                "topImage": "imgRouletteCancel",
                "title": "앗! 잠시만요!",
                "detail": "최대 1만캐시 당첨의 기회, 놓치실 건가요?\n지금 나가시면 후회하실 거에요~",
                "left": "나가기",
                "right": "머물기"
            ]
            setProperties(dictionary: dict)
            motionNormalImageView.isHidden = true
        case .loading:
            let dict: [String: String] = [
                "topImage": "imgRouletteRoading",
                "title": "룰렛을 준비하고 있어요",
                "detail": "아직 준비 중이니\n잠시후에 다시 도전해주세요",
                "confirm": "확인"
            ]
            setProperties(dictionary: dict)
            motionNormalImageView.isHidden = true
        case .chanceExhaust:
            let dict: [String: String] = [
                "topImage": "imgRouletteAgain",
                "title": "1만캐시 당첨에\n다시 도전해보세요!",
                "detail": "룰렛 기회를 모두 사용하였어요.\n룰렛 화면을 종료하고 다시 들어오면\n추가 기회를 얻을 수 있어요.",
                "confirm": "확인"
            ]
            setProperties(dictionary: dict)
            motionNormalImageView.isHidden = true
        case .todayChanceExhaust:
            let dict: [String: String] = [
                "topImage": "imgRouletteAgain",
                "title": "내일 또 만나요!\n",
                "detail": "오늘 도전 가능한 룰렛 기회를\n모두 사용하였어요.\n내일 다시 도전해주세요!",
                "confirm": "확인"
            ]
            setProperties(dictionary: dict)
            motionNormalImageView.isHidden = true
        }
    }
    
    // MARK: - Internal methods
    func backgroundStop() {
        self.audioPlayer?.stop()
        self.motionNormalImageView.isHidden = true
        self.motionNormalImageView.stop()
    }
}

// MARK: - Layout

extension LuckyCashPopupView {
    
    private func layout() {
        
        backgroundView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        backgroundView.heightAnchor.constraint(equalToConstant: 321).isActive = true
        backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        topImageView.topAnchor.constraint(equalTo: backgroundView.topAnchor).isActive = true
        topImageView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        topImageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        topImageView.heightAnchor.constraint(equalToConstant: 128).isActive = true
        topImageView.contentMode = .scaleAspectFill
        
        subContentView.topAnchor.constraint(equalTo: topImageView.bottomAnchor).isActive = true
        subContentView.bottomAnchor.constraint(equalTo: horizontalLine.topAnchor).isActive = true
        subContentView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        subContentView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        
        winningLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -5).isActive = true
        winningLabel.centerXAnchor.constraint(equalTo: subContentView.centerXAnchor).isActive = true
        
        titleLabel.bottomAnchor.constraint(equalTo: subContentView.centerYAnchor, constant: -13).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: subContentView.centerXAnchor).isActive = true
        
        detailLabel.topAnchor.constraint(equalTo: subContentView.centerYAnchor, constant: -5).isActive = true
        detailLabel.centerXAnchor.constraint(equalTo: subContentView.centerXAnchor).isActive = true
    
        horizontalLine.bottomAnchor.constraint(equalTo: confirmButton.topAnchor).isActive = true
        horizontalLine.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        horizontalLine.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        horizontalLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        verticalLine.topAnchor.constraint(equalTo: horizontalLine.bottomAnchor).isActive = true
        verticalLine.centerXAnchor.constraint(equalTo: horizontalLine.centerXAnchor).isActive = true
        verticalLine.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        verticalLine.widthAnchor.constraint(equalToConstant: 1).isActive = true
        
        confirmButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        confirmButton.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        confirmButton.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        leftButton.trailingAnchor.constraint(equalTo: verticalLine.leadingAnchor).isActive = true
        leftButton.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        leftButton.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        leftButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        rightButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        rightButton.leadingAnchor.constraint(equalTo: verticalLine.trailingAnchor).isActive = true
        rightButton.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        rightButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        motionNormalImageView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        motionNormalImageView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor).isActive = true
        motionNormalImageView.widthAnchor.constraint(equalTo: backgroundView.widthAnchor).isActive = true
        motionNormalImageView.heightAnchor.constraint(equalTo: backgroundView.heightAnchor).isActive = true
 
        closeButton.snp.makeConstraints { (m) in
            m.top.equalToSuperview().inset(UIApplication.shared.statusBarFrame.height+8)
            m.leading.equalToSuperview().inset(10)
            m.size.equalTo(24)
        }
    }
}
