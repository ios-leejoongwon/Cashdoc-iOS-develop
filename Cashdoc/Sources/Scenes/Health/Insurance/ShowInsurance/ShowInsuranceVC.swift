//
//  ShowInsuranceVC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/10.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import SnapKit

final class ShowInsuranceVC: CashdocViewController {
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var headerNameLabel: UILabel!
    @IBOutlet weak var headerInsuCountLabel: UILabel!
    @IBOutlet weak var headerInsuTotalLabel: UILabel!
    @IBOutlet weak var getTableView: UITableView!
    @IBOutlet weak var tableFooterView: UIView!
    
    var personArray = [String]()
    var tableDataArray = [[SwiftyJSONRealmObject]]()
       
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func bindView() {
        title = "내 보험 모아보기"
        
        let getValues = InsuranListRealmProxy().getTotalAndPerson()
        personArray = getValues.personArray
        for person in personArray {
            tableDataArray.append(InsuranListRealmProxy().getList(piName: person))
        }
        if personArray.count > 0 {
            getTableView.tableFooterView = nil
        }
        
        UserManager.shared.user
            .bind { [weak self] (user) in
                guard let self = self else {return}
                self.headerNameLabel.text = "\(GlobalFunction.cut4index(user.nickname))님의\n보험현황 입니다."
                self.headerNameLabel.setLineHeight(lineHeight: 30)
        }
        .disposed(by: disposeBag)
        
        headerInsuCountLabel.text = "\(getValues.count)건"
        headerInsuCountLabel.setUnderLine()
        
        headerInsuTotalLabel.text = "\(getValues.total.commaValue)원"
    }
}

extension ShowInsuranceVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return personArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ShowInsuranceTableViewCell.reuseIdentifier, for: indexPath) as? ShowInsuranceTableViewCell {
            cell.drawCell(tableDataArray[indexPath.section][indexPath.row])
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let getModel = tableDataArray[indexPath.section][indexPath.row]
        HealthNavigator.pushShowInsuranDetail(model: getModel)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let makeHeader = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 32))
        makeHeader.backgroundColor = UIColor.fromRGB(249, 249, 249)
        let sectionLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setFontToRegular(ofSize: 12)
            $0.textColor = UIColor.fromRGB(102, 102, 102)
            $0.text = "피보험자-\(personArray[safe: section] ?? "")"
        }
        makeHeader.addSubview(sectionLabel)
        
        sectionLabel.snp.makeConstraints { (snpLabel) in
            snpLabel.left.equalTo(24)
            snpLabel.centerY.equalToSuperview()
        }
        
        return makeHeader
    }
}
