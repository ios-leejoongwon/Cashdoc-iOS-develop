//
//  LottoMachinButton.swift
//  Cashdoc
//
//  Created by 이아림 on 2022/09/19.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import Foundation
import Lottie
import AudioToolbox
import AVFoundation
import Then

final class LottoMachinButton: UIButton {
    
    // MARK: - Properties
    
    var count: Int = 0 {
        didSet {
            badgeLabel.text = "\(count)"
            badgeLabel.isHidden = count <= 0 ? true : false
        }
    }
    
    private var clicked = false
    private var lottoMachinAniName: String = "Main_Lotto_machine_ative"
    
    // MARK: - UI Components
    
    private var lottoAniamtionView: LottieAnimationView!
    var badgeLabel: UILabel!
    
    // MARK: - Con(De)structor
    
    convenience init() {
        self.init(frame: .zero)
        setupView()
        startImage()
    }
    
    // MARK: - Overridden: UIButton
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if !clicked {
            Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(startImage), userInfo: nil, repeats: false)
        }
    }
    
    @objc public func startImage() {
        clicked = false
    }
    
    // MARK: - Internal methods
    private func setupView() {
        lottoAniamtionView = LottieAnimationView().then {
            $0.loopMode = .playOnce
            $0.animationSpeed = 4
            $0.animation = LottieAnimation.filepath(Bundle.main.path(forResource: lottoMachinAniName, ofType: "json")!)
            $0.clipsToBounds = true
            $0.isUserInteractionEnabled = false
            addSubview($0)
            $0.snp.makeConstraints { m in
                m.edges.equalToSuperview()
            }
        }
        badgeLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.clipsToBounds = true
            $0.textColor = UIColor.white
            $0.backgroundColor = .redCw
            $0.clipsToBounds = true
            $0.font = .systemFont(ofSize: 13, weight: .medium)
            $0.IBcornerRadius = 11
            $0.textAlignment = .center
            $0.isHidden = true
            addSubview($0)
            $0.snp.makeConstraints { m in
                m.width.height.equalTo(24)
                m.trailing.equalToSuperview()
                m.top.equalTo(lottoAniamtionView.snp.top).offset(111 * 0.28)
            }
        }
    }
    
    func showCoin() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.lottoAniamtionView.play()
        }
        GlobalFunction.playSound(name: "lottoMachin_sound", ext: "mp3")
    }
    
    // MARK: - Private methods 
    
    private func clickFinished() {
        Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(finishAndStartImage), userInfo: nil, repeats: false)
    }
    
    private func showFinishedImage() {
//        iconImageView.image = treasureFinished
    }
    
    // MARK: - Private selector
    
    @objc private func finishAndStartImage() {
        isHidden = true
        startImage()
    }
     
}
 
