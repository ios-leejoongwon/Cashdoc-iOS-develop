//
//  TreasureButton.swift
//  Cashwalk
//
//  Created by HanSangbeom on 2017. 3. 3..
//  Copyright © 2017년 Cashwalk, Inc. All rights reserved.
//

import AudioToolbox
import AVFoundation
import Then

final class TreasureButton: UIButton {
    
    // MARK: - Properties
    private var clicked = false
    private var treasuresClosed: [UIImage] = [UIImage(named: "icTreasure1")!, UIImage(named: "icTreasure2")!, UIImage(named: "icTreasure3")!]
    private var treasuresOpened: [UIImage] = [UIImage(named: "icTreasure1_1")!, UIImage(named: "icTreasure2_1")!, UIImage(named: "icTreasure3_1")!]
    private var treasureFinished = UIImage(named: "icTreasure0")
    private var audioPlayer: AVAudioPlayer?
    var getCoinFinished: SimpleCompletion?
    
    // MARK: - UI Components
    
    private let iconImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
    }
    
    override convenience init(frame: CGRect) {
        self.init(frame: frame)
        startImage()
        addSubview(iconImageView)
        layout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        startImage()
        addSubview(iconImageView)
        layout()
    }
    
    // MARK: - Overridden: UIButton
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
    
    // MARK: - Internal methods
    
    func showCoin() {
        iconImageView.stopAnimating()
        iconImageView.image = treasuresOpened[2]
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(startImage), userInfo: nil, repeats: false)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            if #available(iOS 10.0, *) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            
            let coinImg = UIImageView()
            coinImg.image = UIImage(named: "icCashWhite")
            coinImg.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(coinImg)
            
            coinImg.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            coinImg.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -270).isActive = true
            coinImg.widthAnchor.constraint(equalToConstant: 24).isActive = true
            coinImg.heightAnchor.constraint(equalToConstant: 24).isActive = true
            UIView.animate(withDuration: 0.6, animations: {
                coinImg.alpha = 0
                coinImg.center = CGPoint(x: 0, y: -250)
            }, completion: { (_) in
                coinImg.removeFromSuperview()
                self.getCoinFinished?()
            })
        }
        playSound(name: "cash_clicked", ext: "mp3")
    }
    
    func playSound(name: String, ext: String) {
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
    
    // MARK: - Private methods
    
    private func clickFinished() {
        showFinishedImage()
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(finishAndStartImage), userInfo: nil, repeats: false)
    }
    
    private func showFinishedImage() {
        iconImageView.image = treasureFinished
    }
    
    // MARK: - Private selector
    
    @objc private func finishAndStartImage() {
        isHidden = true
        startImage()
    }
    
    @objc public func startImage() {
        clicked = false
        
        iconImageView.animationImages = treasuresClosed
        iconImageView.animationDuration = 0.6
        iconImageView.startAnimating()
    }
    
}

// MARK: - Layout

extension TreasureButton {
    
    private func layout() {
        iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        iconImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        iconImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        iconImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
}
