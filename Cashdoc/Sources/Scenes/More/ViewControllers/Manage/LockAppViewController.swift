//
//  LockAppViewController.swift
//  Cashdoc
//
//  Created by Taejune Jung on 03/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import LocalAuthentication

enum LockAppType: CaseIterable {
    case lockapp
    case mentPwd
    case changePwd
    case localAuth
    
    var title: String {
        switch self {
        case .lockapp:
            return "앱 잠금"
        case .mentPwd:
            return "비밀번호를 잊어버리셨다면 앱 삭제 후\n재 설치 해주세요."
        case .changePwd:
            return "비밀번호 변경"
        case .localAuth:
            let authContext = LAContext()
            let type = authContext.bioType()
            Log.i("Login Type : \(type)")
            switch type {
            case .touchID:
                return "Touch ID 사용"
            case .faceID:
                return "Face ID 사용"
            default:
                return "생체인증"
            }
        }
    }
}

final class LockAppViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private var viewModel: LockAppViewModel!
    private var onTrigger = PublishRelay<Bool>()
    // MARK: - UI Components
    
    private let tableView = SelfSizedTableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.estimatedRowHeight = 65
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.clipsToBounds = true
        $0.register(cellType: LockAppTableViewCell.self)
    }
    
    // MARK: - Con(De)structor
    
    init(viewModel: LockAppViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
        navigationItem.title = "앱 잠금 설정"
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
//        if parent == nil {
//            let define = GlobalDefine.shared
//            if let topVC = define.curNav?.topViewController {
//                if !topVC.isEqual(define.mainSeg) {
//                    define.curNav?.viewControllers.last?.navigationController?.setNavigationBarHidden(true, animated: false)
//                }
//            }
//        }
    }
    
    // MARK: - Binding
    
    private func bindView() {
        tableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        Observable.of(LockAppType.allCases)
            .bind(to: tableView.rx.items) { [weak self] (tv: UITableView, _, element: LockAppType) -> UITableViewCell in
                guard let self = self, let cell = tv.dequeueReusableCell(withIdentifier: "LockAppTableViewCell") as? LockAppTableViewCell else {return UITableViewCell()}
                cell.configure(with: element)
                cell.isOnTrigger.asDriverOnErrorJustNever()
                    .drive(onNext: { [weak self] isOn in
                        guard let self = self else { return }
                        if element == .lockapp {
                            self.tableView.reloadData()
                        } else {
                            self.onTrigger.accept(isOn)
                        }
                    })
                    .disposed(by: cell.disposeBag)
                
                return cell
        }
        .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let selection = tableView.rx.modelSelected(LockAppType.self)
        let onTrigger = self.onTrigger.asDriverOnErrorJustNever()
        let input = type(of: self.viewModel).Input(selection: selection.asDriverOnErrorJustNever(),
                                              onTrigger: onTrigger)
        
        _ = viewModel.transform(input: input)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
    }
    
}

// MARK: - Layout

extension LockAppViewController {
    private func layout() {
        tableView.topAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}

extension LockAppViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 72
        } else {
            return 64
        }
    }
}
