//
//  TapToGetCashView.swift
//  Cashdoc
//
//  Created by Oh Sangho on 13/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import AudioToolbox
import AVFoundation

import RxCocoa
import RxSwift
import Lottie

final class TapToGetCashView: UIView {
    
    // MARK: - Properties
    private var audioPlayer: AVAudioPlayer?
    private var prevAnimationiew = [LottieAnimationView]()
    private var path = Bundle.main.path(forResource: "coin_jump", ofType: "json")
    private let disposeBag = DisposeBag()
    private var tapTimer: Timer?
    
    var tapCount: Int = 0 {
        didSet {
            self.cashLabel.text = "\(20 - tapCount)캐시"
        }
    }
    var isAnimating: Bool {
        return prevAnimationiew.last?.isAnimationPlaying ?? false
    }
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 6
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor.yellowCw.cgColor
    }
    private let cashBackgroundView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
    }
    private let cashImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icCashColor")
    }
    
    private let cashLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToBold(ofSize: 12)
        $0.textColor = .yellowCw
    }
    
    // MARK: - Con(De)structor
    
    init() {
        super.init(frame: .zero)
        
        addSubview(containerView)
        containerView.addSubview(cashBackgroundView)
        cashBackgroundView.addSubview(cashImage)
        cashBackgroundView.addSubview(cashLabel)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal methods
    
    func didPerformWithTapCount(for item: ConsumeContentsItem, at cell: UITableViewCell) -> Disposable {
        return didTapCount(item)
            .bind(onNext: { [weak self] (count) in
                guard let self = self else { return }
                guard let cell = self.superview as? ConsumeListTableViewCell else { return }
                self.didTapAnimatedCash(at: cell)
                if count >= 20 {
                    cell.isTouchEnabled = false
                }
            })
    }
    
    // MARK: - Private methods
    
    private func didTapCount(_ item: ConsumeContentsItem) -> Observable<Int> {
        return Observable.just(tapCount)
            .distinctUntilChanged()
            .map {$0 + 1}

            .take(while: {$0 <= 20})
            .do(onNext: { [weak self] (count) in
                guard let self = self else { return }
                self.tapCount = count
                self.updateItems(with: self.tapCount, for: item)
            })
    }
    
    private func updateItems(with point: Int, for item: ConsumeContentsItem) {
        AccountTransactionRealmProxy().updatePointTransactionDetailList(id: item.identity, point: point)
        CardApprovalRealmProxy().updatePointCardDetailList(appNo: item.approvalNum, point: point)
        ManualConsumeRealmProxy().updatePointManualDetailList(identity: item.identity, point: point)
    }
    
    func didTapAnimatedCash(at cell: UITableViewCell) {
        guard let selectedCell = cell as? ConsumeListTableViewCell,
            let parentView = selectedCell.superview else {return}

        UIImpactFeedbackGenerator.lightVibrate()
        
        let animationView = LottieAnimationView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.clipsToBounds = true
            $0.loopMode = .playOnce
            $0.animationSpeed = 2
            guard let path = path else { return }
            $0.animation = LottieAnimation.filepath(path)
            $0.clipsToBounds = true
            $0.isUserInteractionEnabled = false
        }
        
        parentView.addSubview(animationView)
        
        animationView.snp.makeConstraints {
            $0.centerX.equalTo(self.cashImage)
            $0.leading.equalTo(self.cashImage).offset(-25)
            $0.trailing.equalTo(self.cashImage).offset(25)
            $0.bottom.equalTo(self.cashImage.snp.top).offset(10)
            $0.height.equalTo(80)
        }

        prevAnimationiew.append(animationView)
        
        animationView.play { _ in
            animationView.removeFromSuperview()
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
}

// MARK: - Layout

extension TapToGetCashView {
    private func layout() {
        containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        cashBackgroundView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        cashBackgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        cashBackgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        cashBackgroundView.trailingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 52).isActive = true
        
        cashImage.topAnchor.constraint(equalTo: cashBackgroundView.topAnchor, constant: 12).isActive = true
        cashImage.centerXAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 36).isActive = true
        cashImage.widthAnchor.constraint(equalToConstant: 36).isActive = true
        cashImage.heightAnchor.constraint(equalTo: cashImage.widthAnchor).isActive = true
        
        cashLabel.topAnchor.constraint(equalTo: cashImage.bottomAnchor).isActive = true
        cashLabel.centerXAnchor.constraint(equalTo: cashImage.centerXAnchor).isActive = true
    }
}
