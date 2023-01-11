//
//  ShowInsuranceDetailCell.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/11.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Foundation

class ShowInsuranceDetailHeader01Cell: UITableViewCell {
    @IBOutlet weak var insuranRightLabel01: UILabel!
    @IBOutlet weak var insuranRightLabel02: UILabel!
    @IBOutlet weak var insuranRightLabel03: UILabel!
    @IBOutlet weak var insuranRightLabel04: UILabel!
    @IBOutlet weak var insuranRightLabel05: UILabel!
    
    func drawCell(_ model: InsuranceJListModel) {
        insuranRightLabel01.text = model.JEUNGGWONBUNHO
        insuranRightLabel02.text = model.GYEYAKJA
        insuranRightLabel03.text = self.changeToDate(startS: model.BOJANGSIJAKIL, endS: model.BOJANGJONGRYOIL)
        insuranRightLabel04.text = model.NAPIPJOOGI
        insuranRightLabel05.text = model.NAPIPGIGAN
    }
    
    private func changeToDate(startS: String, endS: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let startDate = formatter.date(from: startS)
        let endDate = formatter.date(from: endS)
                
        formatter.dateFormat = "yyyy.MM.dd"
        let startStr = (startDate != nil) ? formatter.string(from: startDate ?? Date()) : startS
        let endStr = (endDate != nil) ? formatter.string(from: endDate ?? Date()) : endS
        
        return "\(startStr) ~ \(endStr)"
    }
}

class ShowInsuranceDetailHeader02Cell: UITableViewCell {
    @IBOutlet weak var insuranRightLabel01: UILabel!
    @IBOutlet weak var insuranRightLabel02: UILabel!

    func drawCell(_ model: InsuranceSListModel) {
        insuranRightLabel01.text = model.JEUNGGWONBUNHO
        insuranRightLabel02.text = model.GYEYAKSANGTAE
    }
}

class ShowInsuranceDetailCell: UITableViewCell {
    @IBOutlet weak var insuranLeftLabel01: UILabel!
    @IBOutlet weak var insuranLeftLabel02: UILabel!
    @IBOutlet weak var insuranLeftLabel03: UILabel!
    @IBOutlet weak var insuranLeftLabel04: UILabel!
    @IBOutlet weak var insuranLeftLabel05: UILabel!
    @IBOutlet weak var insuranLeftLabel01Height: NSLayoutConstraint!
    
    @IBOutlet weak var insuranRightLabel01: UILabel!
    @IBOutlet weak var insuranRightLabel02: UILabel!
    @IBOutlet weak var insuranRightLabel03: UILabel!
    @IBOutlet weak var insuranRightLabel04: UILabel!
    @IBOutlet weak var insuranRightLabel05: UILabel!
    
    func drawCell(_ model: SwiftyJSONRealmObject) {
        if let getModel = model as? InsuranceJDetail {
            insuranLeftLabel01.text = "회사보장명"
            insuranLeftLabel02.text = "보장구분"
            insuranLeftLabel03.text = "피보험자"
            insuranLeftLabel04.text = "보장 상태"
            insuranLeftLabel05.text = "보장 금액"
            
            insuranRightLabel01.text = getModel.HOISABOJANGMYUNG
            insuranRightLabel02.text = getModel.BOJANGGUBUN
            insuranRightLabel03.text = getModel.PIBOHUMJA
            insuranRightLabel04.text = getModel.BOJANGSANGTAE
            insuranRightLabel05.text = "\(getModel.BOJANGGEUMAEK.commaValue)원"
    
            self.layoutIfNeeded()
            insuranLeftLabel01Height.constant = insuranRightLabel01.frame.height
        } else if let getModel = model as? InsuranceSDetail {
            insuranRightLabel01.text = getModel.SILSONGUBUN
            insuranRightLabel02.text = getModel.BOJANGMYUNG
            insuranRightLabel03.text = getModel.PIBOHUMJA
            insuranRightLabel04.text = self.changeToDate(startS: getModel.BOJANGSIJAKIL, endS: getModel.BOJANGJONGRYOIL)
            insuranRightLabel05.text = "\(getModel.BOJANGGEUMAEK.commaValue)원" 
        }
    }
    
    private func changeToDate(startS: String, endS: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let startDate = formatter.date(from: startS)
        let endDate = formatter.date(from: endS)
                
        formatter.dateFormat = "yyyy.MM.dd"
        let startStr = (startDate != nil) ? formatter.string(from: startDate ?? Date()) : startS
        let endStr = (endDate != nil) ? formatter.string(from: endDate ?? Date()) : endS
        
        return "\(startStr) ~ \(endStr)"
    }
}
