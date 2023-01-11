//
//  LuckyCashWinnerViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/06/24.
//  Copyright © 2020 Cashwalk, Inc. All rights reserved.
//

import RxSwift

final class LuckyCashWinnerViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewHeight: CGFloat = 40
    
    private var luckyCashWinners = [LuckyCashWinnerModel]() {
        didSet {
            firstWinnerView.isHidden = false
            firstWinnerView.winner = luckyCashWinners[safe: noticeIndex]
            guard luckyCashWinners.count > 1 else {return}
            secondWinnerView.winner = luckyCashWinners[safe: noticeIndex+1]
            noticeIndex += 2
            isScroll = true
            startScrollWinners()
        }
    }
    private var isFirstRequest = true
    private var isScroll = false
    private var noticeIndex = 0
    private var winnerTimer: Timer?
    private var firstViewTop: NSLayoutConstraint!
    private var secondViewTop: NSLayoutConstraint!
    private var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let firstWinnerView = LuckyCashWinnerView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = false
    }
    private let secondWinnerView = LuckyCashWinnerView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
    }
    
    // MARK: - Overridden: BaseViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        view.addSubview(firstWinnerView)
        view.addSubview(secondWinnerView)
        requestGetLuckyCashWinners()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        startScrollWinners()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        winnerTimer?.invalidate()
        winnerTimer = nil
    }
    
    // MARK: - Internal methods
    
    private func startScrollWinners() {
        guard winnerTimer == nil, luckyCashWinners.count > 1, isScroll else {return}
        winnerTimer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(startAutoScrollWinnerViews), userInfo: nil, repeats: true)
    }
    
    // MARK: - Private methods
    
    func requestGetLuckyCashWinners() {
        #if CASHWALK
        let provider = CashwalkProvider<LuckyCashService>()
        #else
        let provider = CashdocProvider<LuckyCashService>()
        #endif
        provider.CDRequest(.getWinners) { [weak self] (json) in
            guard let self = self else { return }
            do {
                let data = try json["result"].rawData()
                #if CASHWALK
                let makeModel = try [LuckyCashWinnerModel].decode(from: data)
                #else
                let makeModel = try [LuckyCashWinnerModel].decode(data: data)
                #endif

                guard makeModel.count > 0 else { return }
                self.firstWinnerView.winner = nil
                self.secondWinnerView.winner = nil
                self.luckyCashWinners = makeModel
                guard self.isFirstRequest == true else { return }
                self.isFirstRequest = false
                DispatchQueue.main.async {
                    self.layout()
                }
            } catch {
                Log.e(error.localizedDescription)
                guard self.isFirstRequest == true else {return}
                self.isFirstRequest = false
                DispatchQueue.main.async {
                    self.layout()
                }
            }
        }
    }
    
    private func setProperties() {
        view.backgroundColor = .clear
        view.clipsToBounds = true
    }
    
    // MARK: - Private selector
    
    @objc private func startAutoScrollWinnerViews() {
        noticeIndex = noticeIndex >= luckyCashWinners.count-1 ? 0 : noticeIndex+1
        if firstWinnerView.isHidden {
            firstWinnerView.isHidden = false
            
            UIView.animate(withDuration: 0.4, animations: {
                self.secondViewTop.constant = -self.viewHeight
                self.firstViewTop.constant = 0
                self.view.layoutIfNeeded()
            }, completion: { (_) in
                self.secondWinnerView.isHidden = true
                self.secondViewTop.constant = self.viewHeight
                self.secondWinnerView.winner = self.luckyCashWinners[safe: self.noticeIndex]
                self.view.layoutIfNeeded()
            })
            
        } else {
            secondWinnerView.isHidden = false
            
            UIView.animate(withDuration: 0.4, animations: {
                self.firstViewTop.constant = -self.viewHeight
                self.secondViewTop.constant = 0
                self.view.layoutIfNeeded()
            }, completion: { (_) in
                self.firstWinnerView.isHidden = true
                self.firstViewTop.constant = self.viewHeight
                self.firstWinnerView.winner = self.luckyCashWinners[safe: self.noticeIndex]
                self.view.layoutIfNeeded()
            })
        }
    }
}

// MARK: - Layout

extension LuckyCashWinnerViewController {
    
    private func layout() {
        firstWinnerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        firstWinnerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        firstWinnerView.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true
        firstViewTop = firstWinnerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        firstViewTop.isActive = true
        
        secondWinnerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        secondWinnerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        secondWinnerView.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true
        secondViewTop = secondWinnerView.topAnchor.constraint(equalTo: view.topAnchor, constant: viewHeight)
        secondViewTop.isActive = true
    }
}
