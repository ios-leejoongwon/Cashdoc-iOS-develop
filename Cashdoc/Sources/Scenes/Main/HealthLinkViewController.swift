//
//  HealthLinkViewController.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/03/06.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation
import CoreMotion

class HealthLinkViewController: CashdocViewController {
    @IBOutlet weak var mentLabel: UILabel!
    var getMainHomeViewController: MainHomeViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIBarButtonItem(title: "",
                                     style: .plain,
                                     target: self,
                                     action: #selector(closeAct))
        button.image = UIImage(named: "icCloseBlack")
        navigationItem.leftBarButtonItem = button

        let makeAttribute = NSMutableAttributedString(string: mentLabel.text ?? "")
        let range01 = (makeAttribute.string as NSString).range(of: "동작 및 피트니스")
        let range02 = (makeAttribute.string as NSString).range(of: "ON")
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = 24
        paragraph.alignment = .center
        makeAttribute.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: makeAttribute.length))
        makeAttribute.addAttributes([.foregroundColor: UIColor.blueCw], range: range01)
        makeAttribute.addAttributes([.foregroundColor: UIColor.blueCw], range: range02)
        mentLabel.attributedText = makeAttribute
    }
    
    @objc func closeAct() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func gotoSetting() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
}
