//
//  ShowInsuranceDetailVC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/10.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import SwiftyJSON

final class ShowInsuranceDetailVC: CashdocViewController {
    @IBOutlet weak var headerLeftLabel01: UILabel!
    @IBOutlet weak var headerLeftLabel02: UILabel!
    @IBOutlet weak var headerRightLabel01: UILabel!
    @IBOutlet weak var headerRightLabel02: UILabel!
    @IBOutlet weak var getTableView: UITableView!
    
    var getJModel: InsuranceJListModel = InsuranceJListModel()
    var getSModel: InsuranceSListModel = InsuranceSListModel()
    var checkType = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func bindView() {
        title = "보험 상세"
            
        checkType = getJModel.GYEYAKJA.isNotEmpty
        
        if checkType {
            headerLeftLabel01.text = getJModel.HOISAMYUNG
            headerLeftLabel02.text = getJModel.SANGPUMMYUNG
            headerRightLabel01.text = "정액형 계약"
            headerRightLabel02.text = "\(getJModel.ILHOIBOHUMRYO.commaValue)원"
        } else {
            headerLeftLabel01.text = getSModel.HOISAMYUNG
            headerLeftLabel02.text = getSModel.SANGPUMMYUNG
            headerRightLabel01.text = "실손형 계약"
            headerRightLabel02.text = "\(getSModel.NAPIPSANGSE.count)개 보장"
        }
        
        // self.getTableView.reloadData()
    }
}

extension ShowInsuranceDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + getJModel.NAPIPSANGSE.count + getSModel.NAPIPSANGSE.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0, checkType {
            if let cell = tableView.dequeueReusableCell(withIdentifier: ShowInsuranceDetailHeader01Cell.reuseIdentifier, for: indexPath) as? ShowInsuranceDetailHeader01Cell {
                cell.drawCell(getJModel)
                return cell
            }
        }
        
        if indexPath.row == 0, !checkType {
            if let cell = tableView.dequeueReusableCell(withIdentifier: ShowInsuranceDetailHeader02Cell.reuseIdentifier, for: indexPath) as? ShowInsuranceDetailHeader02Cell {
                cell.drawCell(getSModel)
                return cell
            }
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: ShowInsuranceDetailCell.reuseIdentifier, for: indexPath) as? ShowInsuranceDetailCell {
            if checkType {
                cell.drawCell(getJModel.NAPIPSANGSE[indexPath.row - 1])
            } else {
                cell.drawCell(getSModel.NAPIPSANGSE[indexPath.row - 1])
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0, checkType {
            return 276
        } else if indexPath.row == 0, !checkType {
            return 180
        } else {
            if checkType {
                let makeDummyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 144, height: .greatestFiniteMagnitude))
                makeDummyLabel.font = UIFont.systemFont(ofSize: 14)
                makeDummyLabel.numberOfLines = 0
                let jModel = getJModel.NAPIPSANGSE[indexPath.row - 1]
                makeDummyLabel.text = jModel.HOISABOJANGMYUNG
                makeDummyLabel.sizeToFit()
                if makeDummyLabel.frame.height < 20 {
                    return 188
                } else {
                    return 168 + makeDummyLabel.frame.height
                }
            } else {
                return 188
            }
        }
    }
}
