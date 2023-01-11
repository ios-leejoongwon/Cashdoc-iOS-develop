//
//  MyMedicHistoryCell.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/01/15.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation
import RxCocoa

class MyMedicHistoryCell: UITableViewCell {
    @IBOutlet weak var myIconImage: UIImageView!
    @IBOutlet weak var myLabel01: UILabel!
    @IBOutlet weak var myLabel02: UILabel!
    @IBOutlet weak var myLabel03: UILabel!
    
    var controlTap: SimpleCompletion?
    var searchCompletion: SimpleCompletion?
    
    func drawCell(_ model: MedicIneListModel, dsAmt: String, gdAmt: String) {
        let makeSplit = model.TREATMEDICALNM.split(separator: "[")
        myLabel01.text = String(makeSplit.first ?? "")
        let dsAmt = dsAmt.commaValue
        if dsAmt.isEmpty || dsAmt == "0" {
            myLabel02.text = "비용 확인 중"
        } else {
            myLabel02.text = "\(dsAmt)원"
        }
        let gdAmt = gdAmt.commaValue
        if gdAmt.isEmpty || gdAmt == "0" {
            myLabel03.text = "비용 확인 중"
        } else {
            myLabel03.text = "\(gdAmt)원"
        }
        if model.TREATTYPE == "처방조제" {
            myIconImage.image = UIImage(named: "icHealthColor2")
        } else {
            myIconImage.image = UIImage(named: "icCrossGreen")
        }
    }
    
    @IBAction func billingBtnAct(_ sender: Any) {
        controlTap?()
    }
    
    @IBAction func searchBtnAct(_ sender: UIButton) {
        searchCompletion?()
    }
}
