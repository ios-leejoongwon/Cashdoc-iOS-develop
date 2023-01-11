//
//  QuizAnswerPopupView.swift
//  Cashdoc
//
//  Created by A lim on 04/04/2022.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift
import Then
import Lottie
import AudioToolbox
import AVFoundation

protocol QuizAnswerPopupViewDelegate: NSObjectProtocol {
    func quizAnswerPopupViewDidClickedCloseButton(_ view: QuizAnswerPopupView)
}

class QuizAnswerPopupView: BasePopupView {
    
    // MARK: - Properties
    weak var delegate: QuizAnswerPopupViewDelegate?
    private var audioPlayer: AVAudioPlayer?
    var point: Int?
    var pointType: Int?

    // MARK: - UI Components
    
    private let backgroundView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    
    private let adCashboxImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgDpointbox")
    }
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .blackTwoCw
        $0.alpha = 0.87
        $0.textAlignment = .center
        $0.text = "정답입니다!"
    }
    
    private let cashBrownImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icDpointNavy")
    }
    
    let numberBackgroundLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.fromRGB(255, 210, 0)
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    
    let numberLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        $0.textColor = UIColor.fromRGB(94, 80, 80)
        $0.textAlignment = .center
        $0.text = ""
    }
    
    private let winningLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textColor = UIColor.fromRGB(94, 80, 80)
        $0.textAlignment = .center
        $0.text = "당첨"
    }
    
    private let winningInfoLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .brownishGrayCw
        $0.textAlignment = .center
        $0.text = "당첨된 포인트가 지급되었습니다."
    }
    
    private let horizontalLine = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .lineGrayCw
    }
    
    private let closeButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("확인", for: .normal)
        $0.setTitleColor(.blackTwoCw, for: .normal) //컬러 질문!!
        $0.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        $0.backgroundColor = .white
    }
    
    #if CASHWALK
    private let numberImageView = LOTAnimationView(name: "number").then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.loopAnimation = false
        $0.contentMode = .scaleAspectFit
    }
    
    private let motionLockyImageView = LOTAnimationView(name: "cpq_motion_locky").then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.loopAnimation = false
        $0.contentMode = .scaleAspectFill
        $0.isHidden = true
    }
    
    private let motionNormalImageView = LOTAnimationView(name: "cpq_motion_normal").then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.loopAnimation = false
        $0.contentMode = .scaleAspectFill
        $0.isHidden = true
    }
    #else
    private let numberImageView = LottieAnimationView(name: "number").then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.loopMode = .playOnce
        $0.contentMode = .scaleAspectFit
    }
    
    private let motionLockyImageView = LottieAnimationView(name: "cpq_motion_locky").then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.loopMode = .playOnce
        $0.contentMode = .scaleAspectFill
        $0.isHidden = true
    }
    
    private let motionNormalImageView = LottieAnimationView(name: "cpq_motion_normal").then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.loopMode = .playOnce
        $0.contentMode = .scaleAspectFill
        $0.isHidden = true
    }
    #endif
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setProperties()
        setSelector()
        addSubview(backgroundView)
        backgroundView.addSubview(adCashboxImageView)
        backgroundView.addSubview(titleLabel)
        backgroundView.addSubview(cashBrownImageView)
        backgroundView.addSubview(numberBackgroundLabel)
        numberBackgroundLabel.addSubview(numberLabel)
        backgroundView.addSubview(winningLabel)
        backgroundView.addSubview(winningInfoLabel)
        backgroundView.addSubview(horizontalLine)
        backgroundView.addSubview(closeButton)
        numberBackgroundLabel.addSubview(numberImageView)
        backgroundView.addSubview(motionLockyImageView)
        backgroundView.addSubview(motionNormalImageView)
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
    
    private func setProperties() {
        containerView.backgroundColor = .clear
    }
    
    private func setSelector() {
        closeButton.addTarget(self, action: #selector(didClickedCloseButton), for: .touchUpInside)
    }
    
    // MARK: - Private selector
    
    @objc private func didClickedCloseButton() {
        self.delegate?.quizAnswerPopupViewDidClickedCloseButton(self)
    }
    
    // MARK: - Overridden: UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.pointType == 0 {
            self.playSound(name: "cpq_sound_normal", ext: "mp3")
            numberImageView.play { _ in
                self.numberLabel.text = String(describing: self.point!)
                self.motionNormalImageView.isHidden = false
                self.motionLockyImageView.isHidden = true
                self.motionNormalImageView.play()
            }
        } else {
            self.playSound(name: "cpq_sound_spin", ext: "mp3")
            self.numberImageView.play { _ in
                self.numberLabel.text = String(describing: self.point!)
                self.motionNormalImageView.isHidden = true
                self.motionLockyImageView.isHidden = false
                self.motionLockyImageView.play()
                self.playSound(name: "cpq_sound_lucky", ext: "mp3")
            }
        }
    }
    
    // MARK: - Internal methods
    func backgroundStop() {
        self.audioPlayer?.stop()
        self.numberImageView.isHidden = true
        self.motionNormalImageView.isHidden = true
        self.motionLockyImageView.isHidden = true
        self.numberImageView.stop()
        self.motionNormalImageView.stop()
        self.motionLockyImageView.stop()
    }
}

// MARK: - Layout

extension QuizAnswerPopupView {
    
    private func layout() {
        
        backgroundView.widthAnchor.constraint(equalToConstant: 288).isActive = true
        backgroundView.heightAnchor.constraint(equalToConstant: 349).isActive = true
        backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        adCashboxImageView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 32).isActive = true
        adCashboxImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        adCashboxImageView.widthAnchor.constraint(equalToConstant: 88).isActive = true
        adCashboxImageView.heightAnchor.constraint(equalToConstant: 88).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: adCashboxImageView.bottomAnchor, constant: 4).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16).isActive = true
        
        numberBackgroundLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24).isActive = true
        numberBackgroundLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        numberBackgroundLabel.widthAnchor.constraint(equalToConstant: 134).isActive = true
        numberBackgroundLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        numberImageView.centerXAnchor.constraint(equalTo: numberBackgroundLabel.centerXAnchor).isActive = true
        numberImageView.centerYAnchor.constraint(equalTo: numberBackgroundLabel.centerYAnchor).isActive = true
        numberImageView.widthAnchor.constraint(equalTo: numberBackgroundLabel.widthAnchor, multiplier: 0.7).isActive = true
        numberImageView.heightAnchor.constraint(equalTo: numberBackgroundLabel.heightAnchor, multiplier: 0.7).isActive = true

        numberLabel.centerXAnchor.constraint(equalTo: numberBackgroundLabel.centerXAnchor).isActive = true
        numberLabel.centerYAnchor.constraint(equalTo: numberBackgroundLabel.centerYAnchor).isActive = true
        numberLabel.widthAnchor.constraint(equalTo: numberBackgroundLabel.widthAnchor).isActive = true
        numberLabel.heightAnchor.constraint(equalTo: numberBackgroundLabel.heightAnchor).isActive = true
        
        cashBrownImageView.centerYAnchor.constraint(equalTo: numberBackgroundLabel.centerYAnchor).isActive = true
        cashBrownImageView.trailingAnchor.constraint(equalTo: numberBackgroundLabel.leadingAnchor, constant: -7).isActive = true
        cashBrownImageView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        cashBrownImageView.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        winningLabel.centerYAnchor.constraint(equalTo: numberBackgroundLabel.centerYAnchor).isActive = true
        winningLabel.leadingAnchor.constraint(equalTo: numberBackgroundLabel.trailingAnchor, constant: 7).isActive = true
        
        winningInfoLabel.topAnchor.constraint(equalTo: numberBackgroundLabel.bottomAnchor, constant: 24).isActive = true
        winningInfoLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16).isActive = true
        winningInfoLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16).isActive = true
        
        horizontalLine.topAnchor.constraint(equalTo: winningInfoLabel.bottomAnchor, constant: 40).isActive = true
        horizontalLine.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        horizontalLine.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        horizontalLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: horizontalLine.bottomAnchor).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        closeButton.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        
        motionLockyImageView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        motionLockyImageView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor).isActive = true
        motionLockyImageView.widthAnchor.constraint(equalTo: backgroundView.widthAnchor).isActive = true
        motionLockyImageView.heightAnchor.constraint(equalTo: backgroundView.heightAnchor).isActive = true

        motionNormalImageView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        motionNormalImageView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor).isActive = true
        motionNormalImageView.widthAnchor.constraint(equalTo: backgroundView.widthAnchor).isActive = true
        motionNormalImageView.heightAnchor.constraint(equalTo: backgroundView.heightAnchor).isActive = true
    }
}
