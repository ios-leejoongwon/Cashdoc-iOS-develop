//
//  InsuranFindSegVC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2   019/12/18.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Foundation
import SnapKit

class InsuranFindSegVC: CashdocViewController {
    @IBOutlet weak var segButton01: UIButton!
    @IBOutlet weak var segButton02: UIButton!
    @IBOutlet weak var segBarLeading: NSLayoutConstraint!
    @IBOutlet weak var getScrollView: UIScrollView!
    @IBOutlet weak var getScrollViewBottom: NSLayoutConstraint!
    var selectSegment = 0
    
    override func viewDidLoad() {
        title = "아이디/비밀번호 찾기"
        hideKeyboardWhenTappedAround()
        
        RxKeyboard.instance.visibleHeight.drive(onNext: { [weak self] keyHeight in
            guard let self = self else {return}
            self.getScrollViewBottom.constant = keyHeight
            self.view.layoutIfNeeded()
        }).disposed(by: disposeBag)
        
        if selectSegment == 1 {
            self.selectSegment(selectSegment)
            self.getScrollView.setContentOffset(CGPoint(x: view.frame.width, y: 0), animated: false)
        }
    }
    
    func selectSegment(_ index: Int) {
        switch index {
        case 0:
            segButton01.isSelected = true
            segButton02.isSelected = false
            segBarLeading.constant = 0
        case 1:
            segButton02.isSelected = true
            segButton01.isSelected = false
            segBarLeading.constant = view.frame.width / 2
        default:
            break
        }
        
        UIView .animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let viewcon = segue.destination as? InsuranContainVC {
            if segue.identifier == "type1" {
                viewcon.getType = true
            } else if segue.identifier == "type2" {
                viewcon.getType = false
            }
        }
    }
    
    @IBAction func changeSegment(_ sender: UIButton) {
        self.getScrollView.setContentOffset(CGPoint(x: view.frame.width * CGFloat(sender.tag), y: 0), animated: true)
    }
}

extension InsuranFindSegVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let x = scrollView.contentOffset.x
        
        let page: Int = Int(floor((x - (pageWidth / 2)) / pageWidth) + 1)
        selectSegment(page)
    }
}
