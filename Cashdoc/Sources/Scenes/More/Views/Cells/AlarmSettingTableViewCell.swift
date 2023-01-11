//
//  AlarmSettingTableViewCell.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 30/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import Appboy_iOS_SDK
import SnapKit
import Then

protocol AlarmSettingDelegate: AnyObject {
    func clickSwitchControl()
}

final class AlarmSettingTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    var type: AlarmSettingType = .cardPaymentDate
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 16)
        $0.textColor = .blackCw
    }
    
    private let descLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .brownGrayCw
        $0.isHidden = true
    }
    
    private let switchControl = UISwitch().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.onTintColor = .yellowCw
    }
    private let separateView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayCw
    }
    
    var delegate: AlarmSettingDelegate?
    // MARK: - Con(De)structor
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setProperties()
        layout()
        bindView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
    // MARK: - Internal methods
    
    func configure(with item: AlarmSettingType, switchOn: Bool, type: AlarmSettingType) {
        titleLabel.text = item.title
        if item.description.isEmpty {
            descLabel.isHidden = true
        } else {
            descLabel.isHidden = false
            descLabel.text = item.description
        }
        switchControl.isOn = switchOn
        self.type = type
    }
    
    private func setProperties() {
        selectionStyle = .none
    }
    
    private func bindView() {
        switchControl.rx.controlEvent(.valueChanged)
            .bind(onNext: { [weak self] () in
                guard let self = self else { return }
                
                self.delegate?.clickSwitchControl()
                if self.type == .oquiz {
                    GlobalFunction.setQuizPush(isOn: self.switchControl.isOn)
                    return
                }
                
                Log.al("self.switchControl.isOn = \(self.switchControl.isOn)")
                if self.type == .eventAlert {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy.MM.dd"
                    formatter.timeZone = TimeZone(abbreviation: "KST")
                    let yyyymmdd = formatter.string(from: Date())
                    UserDefaults.standard.set(yyyymmdd, forKey: UserDefaultKey.kIsEventAlarmDate.rawValue)
                    UserDefaults.standard.set(self.switchControl.isOn, forKey: UserDefaultKey.kIsEventAlarmOn.rawValue)
                    self.reloadInputViews()
                    return
                }
                
                let notificationIdentifier = self.type.notificationIdentifier
                UserDefaults.standard.set(self.switchControl.isOn, forKey: notificationIdentifier.defaultsKey)
                
                switch notificationIdentifier.defaultsKey {
                case UserDefaultKey.kIsConsumeReportAlarmOn.rawValue:
                    Appboy.sharedInstance()?.user.setCustomAttributeWithKey("push_payment details", andBOOLValue: self.switchControl.isOn)
                case UserDefaultKey.kIsCardPaymentDateAlarmOn.rawValue:
                    Appboy.sharedInstance()?.user.setCustomAttributeWithKey("push_payment due date", andBOOLValue: self.switchControl.isOn)
                case UserDefaultKey.kIsRetentionAlarmOn.rawValue:
                    Appboy.sharedInstance()?.user.setCustomAttributeWithKey("push_roulette", andBOOLValue: self.switchControl.isOn)
                default:
                    break
                }
            
                if self.switchControl.isOn {
                    UserNotificationManager.shared.checkIfAlreadyAddedNotification(identifier: notificationIdentifier) { (isEmpty) in
                        if isEmpty {
                            UserNotificationManager.shared.addDailyNotification(identifier: notificationIdentifier)
                        }
                    }
                } else {
                    UserNotificationManager.shared.removeDailyNotifications([notificationIdentifier])
                }
            }).disposed(by: disposeBag)
    }
    
}

// MARK: - Layout

extension AlarmSettingTableViewCell {
    private func layout() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(switchControl)
        contentView.addSubview(separateView)
        
        let stackV = UIStackView().then {
            $0.distribution = .fill
            $0.axis = .vertical
            contentView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalToSuperview().offset(12)
                m.bottom.equalToSuperview().offset(-12)
                m.left.equalToSuperview().offset(24)
                m.right.equalTo(switchControl.snp.left)
                m.height.equalTo(41)
            }
        }
        
        stackV.addArrangedSubview(titleLabel)
        stackV.addArrangedSubview(descLabel)
//        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
//        titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
//        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24).isActive = true
//        titleLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
        
        separateView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        separateView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        separateView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        separateView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
}
