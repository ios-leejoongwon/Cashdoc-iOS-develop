//
//  TutorialGetCashViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 28/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import AudioToolbox
import AVFoundation

import RxSwift
import RxCocoa
import Lottie

final class TutorialGetCashViewController: CashdocViewController {
    
    // MARK: - Properties
    
    let dismissFetching = PublishSubject<Void>()
    
    private var audioPlayer: AVAudioPlayer?
    private var remainTapCount: Int = 20
    
    // MARK: - UI Components
    
    private let topBackgroundView = ResizableImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgTutorialTop")
    }
    private let bottomBackgroundView = ResizableImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgTutorialBottom")
    }
    private let bottomBackgroundView02 = ResizableImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgTutorialBottom")
    }
    private let closeButton = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icCloseWhite")
    }
    private let containerView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
    }
    private let tapView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.borderColor = UIColor.yellowCw.cgColor
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 6
    }
    private let cashImage = ResizableImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icCashColor")
    }
    private let cashLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToBold(ofSize: 12)
        $0.textColor = .yellowCw
        $0.text = "20캐시"
    }
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .blackCw
        $0.text = "편의점"
    }
    private let subTitle = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .brownGrayCw
        $0.text = "캐시닥 테스트"
    }
    private let amountLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 14)
        $0.textColor = .blackCw
        $0.textAlignment = .center
        $0.text = "-1,000원"
    }
    private let touchDotAnimView = LottieAnimationView().then {
        guard let path = Bundle.main.path(forResource: "reddot", ofType: "json") else { return }
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.animation = LottieAnimation.filepath(path)
        $0.loopMode = .loop
        $0.play()
    }
    
    // MARK: - Con(De)structor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindView()
        view.addSubview(topBackgroundView)
        view.addSubview(containerView)
        view.addSubview(bottomBackgroundView)
        view.addSubview(bottomBackgroundView02)
        view.addSubview(closeButton)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subTitle)
        containerView.addSubview(amountLabel)
        containerView.addSubview(touchDotAnimView)
        containerView.addSubview(tapView)
        tapView.addSubview(cashImage)
        tapView.addSubview(cashLabel)
        
        layout()
    }
    
    // MARK: - Binding
    
    private func bindView() {
        closeButton
            .rx.tapGesture()
            .skip(1)
            .asDriverOnErrorJustNever()
            .drive(onNext: { (_) in
                
                self.dismiss()
            })
            .disposed(by: disposeBag)
        
        tapView
            .rx.tapGesture()
            .skip(1)
            .map({ (_) in
                self.remainTapCount
            })
            .do(onNext: { (_) in
                self.remainTapCount -= 1
            })
            .map({ (_) in
                self.remainTapCount
            })
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] (count) in
                guard let self = self,
                count >= 0 else { return }
                
                self.cashLabel.text = String(format: "%ld캐시", count)
                self.didTapAnimationCash(count)
        }
        .disposed(by: disposeBag)
    }
    
    private func didTapAnimationCash(_ count: Int) {
        let clickedCoinAnimView = LottieAnimationView().then {
            guard let path = Bundle.main.path(forResource: "coin_jump", ofType: "json") else { return }
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.animation = LottieAnimation.filepath(path)
            $0.loopMode = .playOnce
            $0.animationSpeed = 4.0
        }
        let cashImage = ResizableImageView().then {
            $0.image = UIImage(named: "icCashColor")
        }
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator.lightVibrate()
            
            self.containerView.addSubview(clickedCoinAnimView)
            self.containerView.addSubview(cashImage)
    
            clickedCoinAnimView.snp.makeConstraints {
                $0.centerX.equalTo(self.cashImage)
                $0.leading.equalTo(self.cashImage).offset(-25)
                $0.trailing.equalTo(self.cashImage).offset(25)
                $0.bottom.equalTo(self.cashImage.snp.top)
                $0.height.equalTo(80)
            }
            
            cashImage.snp.makeConstraints {
                $0.top.bottom.leading.trailing.equalTo(self.cashImage)
            }
            
            clickedCoinAnimView.play { (_) in
                clickedCoinAnimView.removeFromSuperview()
                cashImage.removeFromSuperview()
                if count == 0 {
                    self.dismiss()
                }
            }
            
            self.playSound(name: "cash_clicked", ext: "mp3")
        }
        
    }
    
    private func playSound(name: String, ext: String) {
        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.volume = AVAudioSession.sharedInstance().outputVolume > 0.5 ? 0.5 : 1
                audioPlayer?.play()
            } catch let error as NSError {
                Log.e(error.description)
            }
        }
    }
    
    private func dismiss() {
        dismiss(animated: true, completion: nil)
        dismissFetching.onNext(())
    }
    
}

// MARK: - Layout

extension TutorialGetCashViewController {
    private func layout() {
        topBackgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        closeButton.topAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.topAnchor, constant: 24).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: topBackgroundView.leadingAnchor, constant: 24).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor).isActive = true
        
        containerView.topAnchor.constraint(equalTo: topBackgroundView.bottomAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: topBackgroundView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: topBackgroundView.trailingAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 85).isActive = true
        
        bottomBackgroundView.topAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        bottomBackgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        bottomBackgroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        
        bottomBackgroundView02.topAnchor.constraint(equalTo: bottomBackgroundView.bottomAnchor).isActive = true
        bottomBackgroundView02.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        bottomBackgroundView02.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        
        touchDotAnimView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        touchDotAnimView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        touchDotAnimView.widthAnchor.constraint(equalTo: touchDotAnimView.heightAnchor).isActive = true
        touchDotAnimView.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        containerViewLayout()
    }
    
    private func containerViewLayout() {
        tapView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 6).isActive = true
        tapView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -7).isActive = true
        tapView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
        tapView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        
        cashImage.topAnchor.constraint(equalTo: tapView.topAnchor, constant: 12).isActive = true
        cashImage.leadingAnchor.constraint(equalTo: tapView.leadingAnchor, constant: 24).isActive = true
        cashImage.widthAnchor.constraint(equalTo: cashImage.heightAnchor).isActive = true
        cashImage.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        cashLabel.topAnchor.constraint(equalTo: cashImage.bottomAnchor).isActive = true
        cashLabel.bottomAnchor.constraint(equalTo: tapView.bottomAnchor, constant: -8).isActive = true
        cashLabel.centerXAnchor.constraint(equalTo: cashImage.centerXAnchor).isActive = true
        cashLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        titleLabel.topAnchor.constraint(equalTo: tapView.topAnchor, constant: 16).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: cashImage.trailingAnchor, constant: 16).isActive = true
        
        subTitle.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2).isActive = true
        subTitle.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 3.5).isActive = true
        
        amountLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor).isActive = true
        amountLabel.trailingAnchor.constraint(equalTo: tapView.trailingAnchor, constant: -24).isActive = true
    }
}
