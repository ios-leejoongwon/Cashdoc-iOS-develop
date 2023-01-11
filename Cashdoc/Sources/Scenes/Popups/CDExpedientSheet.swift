//
//  CDExpedientSheet.swift
//  Cashdoc
//
//  Created by Taejune Jung on 20/01/2020.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation

class CDExpedientSheet: CashdocViewController {
    @IBOutlet weak var dimButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var blankView: UIView!
    @IBOutlet weak var getStackView: UIStackView!
    @IBOutlet weak var getScrollView: UIScrollView!
        
    var getTitleString = "안내"
    var getIndexStrings = [(String, String)]()
    var didSelectIndex: ((Int, String) -> Void)?
    var previousScrollMoment: Date = Date()
    var previousScrollX: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setProperty()
        self.bindView()
    }
    
    func setProperty() {
        titleLabel.text = getTitleString
        if DeviceType.IS_IPHONE_X_MORE {
            getIndexStrings.append(("", ""))
        }
        
        for i in 0..<getIndexStrings.count {
            let makeButton = UIButton().then {
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.backgroundColor = .white
                $0.tag = i
                if getIndexStrings[i].0.isNotEmpty {
                    $0.addTarget(self, action: #selector(indexButtonAct(_:)), for: .touchUpInside)
                }
            }
            
            self.view.addSubview(makeButton)
            
            makeButton.snp.makeConstraints {
                $0.height.equalTo(64)
            }
            
            if getIndexStrings[safe: i]?.1 ?? "" == "" {
                _ = UILabel().then {
                    $0.font = UIFont.systemFont(ofSize: 16)
                    $0.textColor = .blackCw
                    $0.text = getIndexStrings[safe: i]?.0 ?? ""
                    makeButton.addSubview($0)
                    $0.snp.makeConstraints {
                        $0.centerY.equalToSuperview()
                        $0.left.equalToSuperview().offset(24)
                        $0.height.equalTo(22)
                    }
                }
            } else {
                let buttonTitleLabel = UILabel().then {
                    $0.font = UIFont.systemFont(ofSize: 16)
                    $0.textColor = .blackCw
                    $0.text = getIndexStrings[safe: i]?.0 ?? ""
                    makeButton.addSubview($0)
                    $0.snp.makeConstraints {
                        $0.top.equalToSuperview().offset(11)
                        $0.left.equalToSuperview().offset(24)
                        $0.height.equalTo(22)
                    }
                }
                
                _ = UILabel().then {
                    $0.font = UIFont.systemFont(ofSize: 12)
                    $0.textColor = .brownishGray
                    $0.text = getIndexStrings[safe: i]?.1 ?? ""
                    makeButton.addSubview($0)
                    $0.snp.makeConstraints {
                        $0.top.equalTo(buttonTitleLabel).offset(2)
                        $0.left.equalToSuperview().offset(24)
                        $0.bottom.equalToSuperview().offset(11)
                    }
                }
            }
            getStackView.addArrangedSubview(makeButton)
        }
        
        self.view.layoutIfNeeded()
    }
    
    func bindView() {
        getScrollView.setContentOffset(CGPoint(x: 0, y: getStackView.frame.height), animated: false)
        titleView.roundCornersWithLayerMask(cornerRadi: 8, corners: [.topLeft, .topRight])
        
        dimButton.rx.tap.bind { [weak self] _ in
            guard let self = self else { return }
            self.closeAct()
        }
        .disposed(by: disposeBag)
        
        blankView.rx.tapGesture().skip(1).bind { [weak self] _ in
            guard let self = self else { return }
            self.closeAct()
        }
        .disposed(by: disposeBag)
        
        getScrollView.rx.didEndDragging.bind { [weak self] _ in
            guard let self = self else {return}
            let velocity = self.getScrollView.panGestureRecognizer.velocity(in: self.getScrollView).y
            if velocity > 2000 {
                self.closeAct()
            }
        }.disposed(by: disposeBag)
        
        getScrollView.rx.contentOffset.bind { [weak self] point in
            guard let self = self else { return }
            if point.y == 0 {
                self.view.removeFromSuperview()
                self.removeFromParent()
            }
        }
        .disposed(by: disposeBag)
    }
    
    @objc func indexButtonAct(_ sender: UIButton) {
        self.didSelectIndex?(sender.tag, getIndexStrings[safe: sender.tag]?.0 ?? "")
        self.closeAct()
    }
    
    @IBAction func closeAct() {
        self.getScrollView.setContentOffset(.zero, animated: true)
    }
}
