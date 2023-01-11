//
//  MedicHistoryDetailCell.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/01/29.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation

class MedicHistoryDetailSectionCell: UITableViewCell {
    // 섹션헤더 따로 뺌
}

class MedicHistoryDetailCell: UITableViewCell {
    @IBOutlet weak var drugTitleLabel: UILabel!
    @IBOutlet weak var drugDescLabel: UILabel!
    
    func drawCell(_ model: MedicIneDetail) {
        drugTitleLabel.text = model.MEDICINENM
        drugDescLabel.text = "\(model.MEDICINEEFFECT) / 투약일수\(model.ADMINISTERCNT)"
    }
}
