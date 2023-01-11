//
//  CDActionSheet.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/13.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Foundation

class CDActionSheet: CashdocViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var getStackView: UIStackView!
    @IBOutlet weak var getScrollView: UIScrollView!
        
    var getTitleString = "안내"
    var getIndexStrings = [String]()
    var getSubStrings = [String]()
    var getSubStringDateType = false
    var didSelectIndex: ((Int, String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setProperty()
        self.bindView()
    }
    
    func setProperty() {
        titleLabel.text = getTitleString
        if DeviceType.IS_IPHONE_X_MORE {
            getIndexStrings.append("")
        }
        
        for i in 0..<getIndexStrings.count {
            let makeButton = UIButton().then {
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.setTitle(getIndexStrings[safe: i] ?? "", for: .normal)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 16)
                $0.setTitleColor(UIColor.blackCw, for: .normal)
                $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
                $0.backgroundColor = .white
                $0.contentHorizontalAlignment = .left
                $0.tag = i
                if getIndexStrings[i].isNotEmpty {
                    $0.addTarget(self, action: #selector(indexButtonAct(_:)), for: .touchUpInside)
                }
            }
                                    
            makeButton.snp.makeConstraints {
                $0.height.equalTo(53)
            }
            
            if let getSubString = getSubStrings[safe: i] {
                _ = UILabel().then {
                    if getSubStringDateType {
                        $0.text = getSubString.convertDateFormat(beforeFormat: "yyyyMMdd", afterFormat: "yyyy.MM.dd")
                        $0.textColor = .brownishGray
                    } else {
                        $0.text = getSubString
                        $0.textColor = .blackCw
                    }
                    $0.font = UIFont.systemFont(ofSize: 14)
                    makeButton.addSubview($0)
                    $0.snp.makeConstraints { (m) in
                        m.centerY.equalToSuperview()
                        m.right.equalToSuperview().offset(-28)
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
        
        getScrollView.rx.didEndDragging.bind { [weak self] endBool in
            guard let self = self else {return}
            if !endBool, self.getScrollView.contentOffset.y < self.getStackView.frame.height {
                self.getScrollView.setContentOffset(CGPoint.zero, animated: true)
            }
        }.disposed(by: disposeBag)
        
        getScrollView.rx.didScroll.bind { [weak self] _ in
            guard let self = self else {return}
            if self.getScrollView.contentOffset == CGPoint.zero {
                self.closeAct()
            }
        }.disposed(by: disposeBag)
    }
    
    @objc func indexButtonAct(_ sender: UIButton) {
        if getSubStrings.isNotEmpty {
            self.didSelectIndex?(sender.tag, getSubStrings[safe: sender.tag] ?? "")
        } else {
            self.didSelectIndex?(sender.tag, getIndexStrings[safe: sender.tag] ?? "")
        }
        self.closeAct()
    }
    
    @IBAction func closeAct() {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}
