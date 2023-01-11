//
//  CDRollingView.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/04/20.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation

class CDRollingView: UIView {
    var timer: Timer?
    var currentIndex = 0
    var maxIndex = 0
    var makeScrollView: UIScrollView!
    
    deinit {
        print("[👋deinit]\(String(describing: self))")
        timer?.invalidate()
        timer = nil
    }
    
    func initWithModels(_ rollModels: [InvoiceRollingModel]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.makeScrollView = UIScrollView().then {
                $0.showsVerticalScrollIndicator = false
                $0.isScrollEnabled = false
                self.addSubview($0)
                $0.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
            }
            
            let makeStackView = UIStackView().then {
                $0.axis = .vertical
                self.makeScrollView.addSubview($0)
                $0.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
            }
            
            self.maxIndex = rollModels.count
            
            for i in 0...self.maxIndex {
                _ = UILabel().then {
                    var makeI = i
                    if i == self.maxIndex {
                        makeI = 0
                    }
                    guard let getModel = rollModels[safe: makeI] else { return }
                    let makeDate = Date.init(timeIntervalSince1970: TimeInterval(getModel.createdAt))
                    let sinceString = Date.sinceNowKor(date: makeDate)
                    $0.numberOfLines = 2
                    $0.textColor = .blackTwoCw
                    $0.font = UIFont.systemFont(ofSize: 13, weight: .regular)
                    let makeAttribute = NSMutableAttributedString(string: "\(sinceString) \(getModel.name)님이 병원비\n\(getModel.amount.commaValue)원을 돌려받았습니다.")
                    let range01 = (makeAttribute.string as NSString).range(of: sinceString)
                    makeAttribute.addAttributes([.foregroundColor: UIColor.blackTwoCw], range: NSRange(location: 0, length: makeAttribute.length))
                    makeAttribute.addAttributes([.foregroundColor: UIColor.blueCw], range: range01)
                    $0.attributedText = makeAttribute
                    
                    makeStackView.addArrangedSubview($0)
                    $0.snp.makeConstraints { (make) in
                        make.height.equalTo(40)
                    }
                }
            }
            self.startTimer()
        }
    }
    
    func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(scrollAnimate), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func scrollAnimate() {
        // Log.i("rolling CurrentIndex : \(currentIndex)")
        if maxIndex == 0 {
            return
        }
        
        if makeScrollView.contentOffset == CGPoint.zero {
            self.currentIndex = 0
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.currentIndex == self.maxIndex {
                self.currentIndex = 0
                self.makeScrollView.setContentOffset(CGPoint.zero, animated: false)
            }
            self.currentIndex += 1
            self.makeScrollView.setContentOffset(CGPoint(x: 0, y: self.frame.size.height * CGFloat(self.currentIndex)), animated: true)
        }
    }
}
