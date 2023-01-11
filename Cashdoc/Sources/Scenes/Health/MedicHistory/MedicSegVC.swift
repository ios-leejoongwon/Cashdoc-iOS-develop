//
//  MedicSegVC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/01/22.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation

class MedicSegVC: CashdocViewController {
    @IBOutlet weak var segButton01: UIButton!
    @IBOutlet weak var segButton02: UIButton!
    @IBOutlet weak var segBarLeading: NSLayoutConstraint!
    @IBOutlet weak var getScrollView: UIScrollView!
    var selName = ""
    var selectSegment = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "1년 내역"
        if selectSegment == 1 {
            self.selectSegment(selectSegment)
            self.getScrollView.setContentOffset(CGPoint(x: view.frame.width, y: 0), animated: false)
        }
        
        let getPersons = MedicHistoryRealmProxy().getPersonArray()
        if selName == getPersons.first ?? "" {
            title = "1년 내역"
        } else {
            title = "\(selName)의 1년 내역"
        }

        let button = UIBarButtonItem(title: "",
                                     style: .plain,
                                     target: self,
                                     action: #selector(closeAct))
        button.image = UIImage(named: "icCloseBlack")
        navigationItem.leftBarButtonItem = button
    }
    
    @objc func closeAct() {
        self.navigationController?.popViewController(animated: true)
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
        
        if let viewcon = segue.destination as? MedicContainVC {
            if segue.identifier == "type1" {
                viewcon.getType = true
                viewcon.selName = self.selName
            } else if segue.identifier == "type2" {
                viewcon.getType = false
                viewcon.selName = self.selName
            }
        }
    }
    
    @IBAction func changeSegment(_ sender: UIButton) {
        self.getScrollView.setContentOffset(CGPoint(x: view.frame.width * CGFloat(sender.tag), y: 0), animated: true)
    }
}

extension MedicSegVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let x = scrollView.contentOffset.x
        
        let page: Int = Int(floor((x - (pageWidth / 2)) / pageWidth) + 1)
        selectSegment(page)
    }
}
