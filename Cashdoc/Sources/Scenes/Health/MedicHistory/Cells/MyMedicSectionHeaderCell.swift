//
//  MyMedicSectionHeaderCell.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/01/16.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation

class MyMedicSectionHeaderCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    
    func drawCell(_ model: MedicIneListModel, price: Int) {
        let makeTime = self.changeToDate(model.TREATDATE)
        dateLabel.text = makeTime.date
        weekLabel.text = makeTime.week
        priceLabel.text = price.commaValue + "원"
    }
    
    private func changeToDate(_ dateString: String) -> (date: String, week: String) {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let time = dateFormatter.date(from: dateString) ?? currentDate
        if currentDate.year == time.year {
            dateFormatter.dateFormat = "MM.dd"
        } else {
            dateFormatter.dateFormat = "yyyy.MM.dd"
        }
        let changeTime = dateFormatter.string(from: time)
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.locale = Locale(identifier: "ko")
        let weekDay = dateFormatter.string(from: time)
        return (changeTime, weekDay)
    }
}
