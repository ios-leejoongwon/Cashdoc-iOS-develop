//
//  MedicDrugInfoVC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/01/29.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import SwiftyJSON

class MedicDrugInfoVC: CashdocViewController {
    @IBOutlet weak var getTableView: UITableView!
    
    var getModel: MedicIneDrugDetail = MedicIneDrugDetail(json: JSON.null)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "처방 약품 상세"
        
        getTableView.estimatedRowHeight = 44
        getTableView.rowHeight = UITableView.automaticDimension
        getTableView.contentInset = UIEdgeInsets(top: 32, left: 0, bottom: 0, right: 0)
    }
}

extension MedicDrugInfoVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 13
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MedicDrugInfoCell.reuseIdentifier, for: indexPath) as? MedicDrugInfoCell {
            cell.drawCell(getModel, index: indexPath.row)
            return cell
        } else {
            return UITableViewCell()
        }
    }
}
