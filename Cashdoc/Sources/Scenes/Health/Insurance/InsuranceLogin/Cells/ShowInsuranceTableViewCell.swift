//
//  ShowInsuranceTableViewCell.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/11.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Foundation

class ShowInsuranceTableViewCell: UITableViewCell {
    @IBOutlet weak var insuranLeftLabel01: UILabel!
    @IBOutlet weak var insuranLeftLabel02: UILabel!
    @IBOutlet weak var insuranPriceLabel: UILabel!
    
    func drawCell(_ model: SwiftyJSONRealmObject) {
        if let getModel = model as? InsuranceJListModel {
            insuranLeftLabel01.text = getModel.HOISAMYUNG
            insuranLeftLabel02.text = getModel.SANGPUMMYUNG
            insuranPriceLabel.text = "월 \(getModel.ILHOIBOHUMRYO.commaValue)원"
        } else if let getModel = model as? InsuranceSListModel {
            insuranLeftLabel01.text = getModel.HOISAMYUNG
            insuranLeftLabel02.text = getModel.SANGPUMMYUNG
            insuranPriceLabel.text = "실손형 계약"
        }
    }
}
