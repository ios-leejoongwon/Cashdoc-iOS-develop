//
//  FreeSegViewController.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/03/17.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation

enum FreeSegIndex: Int {
    case 용돈퀴즈 = 0
    case 추천 = 1
    case 캐시적립 = 2
}

class FreeSegViewController: CashdocViewController {
    @IBOutlet weak var segButton01: UIButton!
    @IBOutlet weak var segButton02: UIButton!
    @IBOutlet weak var segButton03: UIButton!
    @IBOutlet weak var remainCashLabel: UILabel!
    @IBOutlet weak var getScrollView: UIScrollView!
    @IBOutlet weak var segBarLeading: NSLayoutConstraint!
    @IBOutlet weak var remainCashHeight: NSLayoutConstraint!
    var isAniamtion: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "무료캐시적립"
        
        let provider = CashdocProvider<PincruxService>()
        provider.CDRequest(.getADInfo) { [weak self] json in
            DispatchQueue.main.async {
                self?.remainCashLabel.text = "\(json["ad_coin"].intValue.commaValue)캐시"
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.freeSeg = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GlobalDefine.shared.freeSeg = nil
    }
    
    private func selectSegment(_ index: FreeSegIndex) {
        segButton01.isSelected = false
        segButton02.isSelected = false
        segButton03.isSelected = false
        segButton01.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        segButton02.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        segButton03.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        switch index {
        case .용돈퀴즈:
            settingSegBar(segButton01)
        case .추천:
            settingSegBar(segButton02)
        case .캐시적립:
            settingSegBar(segButton03)
        }
        
        UIView .animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func changeSegment(_ index: MainSegIndex) {
        let index = index.rawValue
        self.getScrollView.setContentOffset(CGPoint(x: view.frame.width * CGFloat(index), y: 0), animated: true)
    }
    
    private func settingSegBar(_ sender: UIButton) {
        sender.isSelected = true
        segBarLeading.constant = CGFloat(sender.tag) * ScreenSize.WIDTH / 3
        sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    }
    
    @IBAction func changeSegmentAct(_ sender: UIButton) {
        self.getScrollView.setContentOffset(CGPoint(x: view.frame.width * CGFloat(sender.tag), y: 0), animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let viewcon = segue.destination as? CashdocWebViewController {
            if segue.identifier == "type1" {
                viewcon.urlString = API.FREE_QUIZ_URL
            } else if segue.identifier == "type2" {
                viewcon.urlString = API.FREE_PINCRUX_CARD_URL
            } else if segue.identifier == "type3" {
                viewcon.urlString = API.FREE_PINCRUX_LIST_URL
            }
        }
    }
    
    func scrollDirection(_ isUp: Bool) {
        if isAniamtion { return }
        
        if !isUp, remainCashHeight.constant == 50 {
            remainCashHeight.constant = 0
        } else if isUp, remainCashHeight.constant == 0 {
            remainCashHeight.constant = 50
        }
        
        self.isAniamtion = true
        
        UIView.animate(withDuration: 0.1, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (isEnd) in
            if isEnd {
                self.isAniamtion = false
            }
        })
    }
}

extension FreeSegViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let x = scrollView.contentOffset.x
        
        let page: Int = Int(floor((x - (pageWidth / 2)) / pageWidth) + 1)
        let makeIndex = FreeSegIndex.init(rawValue: page) ?? .용돈퀴즈
        selectSegment(makeIndex)
    }
}
