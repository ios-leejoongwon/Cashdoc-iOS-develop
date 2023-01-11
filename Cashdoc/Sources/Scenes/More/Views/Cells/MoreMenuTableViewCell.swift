//
//  MoreMenuTableViewCell.swift
//  Cashdoc
//
//  Created by Taejune Jung on 03/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Foundation
import AppTrackingTransparency

protocol MoreMenuTableViewCellDelegate: AnyObject {
    func updateButtonAction()
}

final class MoreMenuTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    var cellDelegate: MoreMenuTableViewCellDelegate?
    var indexPath: IndexPath! {
        didSet {
            let type = SettingType.allCases[indexPath.section]
            let cell = type.cells[indexPath.row]
            let lastIndex = type.cells.count - 1
            
            titleLabel.text = cell.title
            
            if lastIndex == indexPath.row {
                if type == .serviceCenter {
                    separateView.isHidden = false
                } else {
                    separateView.isHidden = true
                }
            }
            
            self.arrowImageView.isHidden = cell.title == "맞춤 정보 제공"
        
            if cell.title == "현재 앱 버전" {
                self.arrowImageView.isHidden = true
                self.contentLabel.isHidden = false
                self.contentLabel.text = getAppVersion()
                
                if VersionCheckManager.check(with: GlobalDefine.shared.newestVersion) == .업데이트있음 {
                    self.updateButton.isHidden = false
                    self.updateButton.addTarget(self, action: #selector(clickUpdateButton), for: .touchUpInside)
                    self.subLabel.isHidden = true
                } else {
                    self.updateButton.isHidden = true
                    self.subLabel.isHidden = false
                    self.subLabel.text = "최신 버전"
                }
                
            } else if cell.title == "앱 잠금 설정" {
                self.subLabel.isHidden = false
                self.subLabel.text = UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLockApp.rawValue) ? "사용중" : "사용안함"
                self.contentLabel.isHidden = true
            } else {
                self.contentLabel.isHidden = true
                self.subLabel.isHidden = true
                self.updateButton.isHidden = true
            }
            
            self.switchView.isHidden = cell.title != "맞춤 정보 제공"
            // 광고추적허용
            if #available(iOS 14, *) {
                if ATTrackingManager.trackingAuthorizationStatus == .authorized {
                    self.switchView.isOn = true
                } else {
                    self.switchView.isOn = false
                }
            } else {
                self.switchView.isOn = true
            }
        }
    }
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    let subLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .brownishGray
        $0.isHidden = true
    }
    private let arrowImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icArrow01StyleRightGray")
        $0.contentMode = .scaleToFill
    }
    private let switchView = UISwitch().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.onTintColor = .yellowCw
    }
    private let separateView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayCw
    }
    
    let VstackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.distribution = .fill
    }
    
    let HstackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        $0.spacing = 8
        $0.distribution = .fill
    }
    
    let contentLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = .warmGrayCw
        $0.isHidden = true
    }
    
    let updateButton = UIButton().then {
        $0.IBborderWidth = 1
        $0.IBcornerRadius = 4
        $0.IBborderColor = .blueCw
        $0.setTitle("업데이트하기", for: .normal)
        $0.setTitleColor(.blueCw, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        $0.isHidden = true
    }
    
    // MARK: - Con(De)structor
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setProperties()
        self.sendSubviewToBack(self.contentView)
        self.addSubview(VstackView)
        self.VstackView.addArrangedSubview(titleLabel)
        self.VstackView.addArrangedSubview(contentLabel)
        
        self.addSubview(HstackView)
        self.HstackView.addArrangedSubview(subLabel)
        self.HstackView.addArrangedSubview(arrowImageView)
        self.HstackView.addArrangedSubview(switchView)
        self.HstackView.addArrangedSubview(updateButton)
//        self.addSubview(subLabel)
//        self.addSubview(arrowImageView)
//        self.addSubview(switchView)
        self.addSubview(separateView)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UITableViewCell
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        self.selectionStyle = .none
    }
    
    @objc func clickUpdateButton() {
        Log.al(clickUpdateButton)
        cellDelegate?.updateButtonAction()
    }
}

// MARK: - Layout

extension MoreMenuTableViewCell {
    
    private func layout() {
        
        VstackView.snp.makeConstraints { m in
            m.centerY.equalToSuperview()
            m.leading.equalToSuperview().offset(16)
        }
        
        HstackView.snp.makeConstraints { m in
            m.centerY.equalToSuperview()
            m.height.equalTo(30)
            m.trailing.equalToSuperview().offset(-24)
        }
        
        arrowImageView.snp.makeConstraints { m in
            m.width.height.equalTo(24)
        }
        
        updateButton.snp.makeConstraints { m in
            m.width.equalTo(90)
            m.height.equalTo(30)
        }
//        titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
//        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        
//        contentLabel.snp.makeConstraints { m in
//            m.leading.equalTo(titleLabel.snp.leading)
//            m.top.equalTo(titleLabel.snp.bottom)
//        }
         
//        subLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
//        subLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -63).isActive = true
//
//        arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
//        arrowImageView.widthAnchor.constraint(equalTo: arrowImageView.heightAnchor).isActive = true
//        arrowImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
//        arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
//
//        switchView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
//        switchView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        
        separateView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        separateView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        separateView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        separateView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
    }
}
