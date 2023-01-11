//
//  CouponViewController.swift
//  Cashdoc
//
//  Created by Taejune Jung on 03/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum AlarmSettingType: CaseIterable {
    case eventAlert
    case consumeReport
    case cardPaymentDate
    case luckyCash
    case oquiz
    
    var title: String {
        switch self {
        case .eventAlert:
            return "이벤트 및 혜택"
        case .consumeReport:
            return "소비내역 검토 알림"
        case .cardPaymentDate:
            return "카드 결제일 알림"
        case .luckyCash:
            return "행운캐시 룰렛 알림"
        case .oquiz:
            return "용돈퀴즈 알림"
        }
    }
    var description: String {
        switch self {
        case .eventAlert:
            let isOn = UserDefaults.standard.object(forKey: UserDefaultKey.kIsEventAlarmOn.rawValue) as? Bool ?? true
            guard let des = UserDefaults.standard.string(forKey: UserDefaultKey.kIsEventAlarmDate.rawValue), !des.isEmpty else { return "마케팅 정보 수신 동의" }
             
            if isOn {
                return "마케팅 정보 수신 동의 \(des)"
            } else {
                return "마케팅 정보 수신 해제 \(des)"
            }
            
        default:
            return ""
        }
    }
    
    var notificationIdentifier: NotificationIdentifier {
        switch self {
        case .consumeReport:
            return .DailyNotification1930
        case .cardPaymentDate:
            return .CardPaymentDate1200
        case .luckyCash:
            return .DailyRetention1200
        case .oquiz:
            return .Oquiz
        default:
            return .none
        }
    }
}

final class AlarmSettingViewController: CashdocViewController, UITableViewDelegate {
    
    // MARK: - Properties
    
    var viewModel: AlarmSettingViewModel!
    
//    let dataSource = RxTableViewSectionedReloadDataSource!
    
    // MARK: - UI Components
    
    private let tableView = SelfSizedTableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.estimatedRowHeight = 65
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.clipsToBounds = true
        $0.register(cellType: AlarmSettingTableViewCell.self)
    }
    
    // MARK: - Con(De)structor
    
    init(viewModel: AlarmSettingViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        bindView()
        bindViewModel()
        view.addSubview(tableView)
        layout()
    }
    
    // MARK: - Binding
    
    private func bindView() {
        Observable.of(AlarmSettingType.allCases)
            .bind(to: tableView.rx.items) { (tv: UITableView, _, element: AlarmSettingType) -> UITableViewCell in
                guard let cell = tv.dequeueReusableCell(withIdentifier: "AlarmSettingTableViewCell") as? AlarmSettingTableViewCell else {return UITableViewCell()}
                
                cell.delegate = self
                var switchOn = false
                switch element {
                case .eventAlert:
                    switchOn = UserDefaults.standard.object(forKey: UserDefaultKey.kIsEventAlarmOn.rawValue) as? Bool ?? true
                case .consumeReport:
                    switchOn = UserDefaults.standard.object(forKey: UserDefaultKey.kIsConsumeReportAlarmOn.rawValue) as? Bool ?? true
                case .cardPaymentDate:
                    switchOn = UserDefaults.standard.object(forKey: UserDefaultKey.kIsCardPaymentDateAlarmOn.rawValue) as? Bool ?? true
                case .luckyCash:
                    switchOn = UserDefaults.standard.bool(forKey: UserDefaultKey.kIsRetentionAlarmOn.rawValue)
                case .oquiz:
                    switchOn = UserDefaults.standard.bool(forKey: UserDefaultKey.kIsOnQuizPush.rawValue)
                }
                cell.configure(with: element, switchOn: switchOn, type: element)
                return cell
        }
        .disposed(by: disposeBag)
                
    }
    
    private func bindViewModel() {
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
        self.title = "알림 설정"
    }
}

extension AlarmSettingViewController: AlarmSettingDelegate {
    func clickSwitchControl() {
        Log.al("clickSwitchControl")
        self.tableView.reloadData()
    }
}
// MARK: - Layout

extension AlarmSettingViewController {
    
    private func layout() {
        tableView.topAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
}
