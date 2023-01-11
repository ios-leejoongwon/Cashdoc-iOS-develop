//
//  MedicDrugInfoCell.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/01/29.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation

class MedicDrugInfoCell: UITableViewCell {
    @IBOutlet weak var drugTitlelabel: UILabel!
    @IBOutlet weak var drugDetailLabel: UILabel!
    
    func drawCell(_ model: MedicIneDrugDetail, index: Int) {
        switch index {
        case 0:
            drugTitlelabel.text = "처방약품명"
            drugDetailLabel.text = makeNullText(model.PRODUCTNM)
        case 1:
            drugTitlelabel.text = "성분명"
            if let getFirst = model.INGREDIENTNMLIST.toArray().first {
                drugDetailLabel.text = getFirst.INGREDIENTNM
            }
        case 2:
            drugTitlelabel.text = "전문/일반"
            drugDetailLabel.text = makeNullText(model.SPECIALYN)
        case 3:
            drugTitlelabel.text = "단일/복합"
            drugDetailLabel.text = makeNullText(model.SINGLEYN)
        case 4:
            drugTitlelabel.text = "제조/수입사"
            drugDetailLabel.text = makeNullText(model.MAKINGCOMPANY)
        case 5:
            drugTitlelabel.text = "판매사"
            drugDetailLabel.text = makeNullText(model.SALESCOMPANY)
        case 6:
            drugTitlelabel.text = "제형"
            drugDetailLabel.text = makeNullText(model.SHAPE)
        case 7:
            drugTitlelabel.text = "투여경로"
            drugDetailLabel.text = makeNullText(model.ADMINISTERPATH)
        case 8:
            drugTitlelabel.text = "복지부분류"
            drugDetailLabel.text = makeNullText(model.MEDICINEGROUP)
        case 9:
            drugTitlelabel.text = "급여정보"
            drugDetailLabel.text = makeNullText(model.PAYINFO)
        case 10:
            drugTitlelabel.text = "ATC코드"
            drugDetailLabel.text = makeNullText(model.ATC)
        case 11:
            drugTitlelabel.text = "KPIC 약효분류"
            if let getFirst = model.KPICLIST.toArray().first {
                drugDetailLabel.text = getFirst.KPIC
            }
        case 12:
            drugTitlelabel.text = "의약품안정성\n정보"
            if let getFirst = model.DUR.toArray().first {
                var makeString = ""
                if getFirst.COMBINEDTABOO.isNotEmpty {
                    makeString.append(getFirst.COMBINEDTABOO + "\n")
                }
                if getFirst.AGETABOO.isNotEmpty {
                    makeString.append(getFirst.AGETABOO + "\n")
                }
                if getFirst.PREGNANTTABOO.isNotEmpty {
                    makeString.append(getFirst.PREGNANTTABOO + "\n")
                }
                drugDetailLabel.text = makeString
            }
        default:
            break
        }
    }
    
    private func makeNullText(_ string: String) -> String {
        if string.isEmpty {
            return "-"
        } else {
            return string
        }
    }
}
