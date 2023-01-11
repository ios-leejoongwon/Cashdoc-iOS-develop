//
//  MoreViewModel.swift
//  Cashdoc
//
//  Created by Taejune Jung on 03/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa
import AppTrackingTransparency

final class MoreViewModel {
    
    private let pointUseCase: PointUseCase
    private let couponUseCase: CouponUseCase
    private let navigator: MoreNavigator
    private let disposeBag = DisposeBag()
    
    init(navigator: MoreNavigator) {
        self.navigator = navigator
        self.pointUseCase = PointUseCase()
        self.couponUseCase = CouponUseCase()
    }
    
}

extension MoreViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
        let profileTrigger: Driver<Void>
        let couponTrigger: Driver<Void>
        let cashTrigger: Driver<Void>
        let inviteFriendTrigger: Driver<Bool>
        let selection: Driver<(IndexPath, [SettingType])>
    }
    struct Output {
        let error: Driver<Error>
    }
    
    func transform(input: Input) -> Output {
        let getError = PublishRelay<Error>()

        input.profileTrigger
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.pushToProfileViewController()
            })
        .disposed(by: disposeBag)
        input.couponTrigger
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.pushToCouponViewController()
            })
            .disposed(by: disposeBag)
        input.cashTrigger
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.pushToCashViewController()
            })
            .disposed(by: disposeBag)
        input.inviteFriendTrigger
            .drive(onNext: { [weak self] (isShow) in
                guard let self = self else { return }
                self.showRecommend(isShow)
            })
            .disposed(by: disposeBag)
        input.selection
            .drive(onNext: { [weak self] (indexPath, settingType) in
                guard let self = self else { return }
                let section = settingType[indexPath.section]
                switch section {
                // mydata 관련히든
//                case .myProperty:
//                    if indexPath.row == 0 {
//                        self.navigator.pushToMyPropertyViewController()
//                    }
                case .manager:
                    switch indexPath.row { 
                    case 1:
                        self.navigator.pushToLockAppViewController()
                    case 2:
                        self.navigator.pushToAlarmSettingViewController()
                    case 3:
                        if #available(iOS 14, *) {
                            if ATTrackingManager.trackingAuthorizationStatus == .authorized {
                                let cancelAction = UIAlertAction(title: "유지하기", style: .default, handler: nil)
                                let confirmAction = UIAlertAction(title: "해제하기", style: .default) { (_) -> Void in
                                    if let url = NSURL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                                    }
                                }
                                
                                GlobalDefine.shared.curNav?.alert(title: "맞춤 정보 제공 설정\n", message: "기존 금융건강 생활을 위해\n회원님께 딱! 맞는 정보를\n제공할 수 없게 됩니다.\n정말 해제 하시겠어요?", preferredStyle: .alert, actions: [confirmAction, cancelAction], textFieldHandlers: nil, completion: nil)
                            } else {
                                if let viewcon = UIStoryboard.init(name: "Popups", bundle: nil).instantiateViewController(withIdentifier: "CDTrackingPopupVC") as? CDTrackingPopupVC {
                                    viewcon.firstType = false
                                    GlobalFunction.pushVC(viewcon, animated: true)
                                }
                            }
                        } else {
                            print("not deter")
                        }
                    default:
                        break
                    }
                    
                case .serviceCenter:
                    switch indexPath.row {
                    case 0:
                        GlobalFunction.pushToWebViewController(title: "공지사항", url: API.NOTICE_URL, webType: .terms)
                    case 1:
                        MailManager.alert(from: GlobalDefine.shared.curNav ?? UIViewController())
                    case 2:
                        GlobalFunction.pushToWebViewController(title: "이용약관", url: API.CASHDOC_TERMS_URL, webType: .terms)
                    case 3:
                        GlobalFunction.pushToWebViewController(title: "개인정보처리방침", url: API.CASHDOC_PRIVACY_URL, webType: .terms)
                    default:
                        break
                    }
                     #if DEBUG || INHOUSE
                case .debugMode:
                    if indexPath.row == 0 {
                        self.navigator.pushToDebugModeViewController()
                    }
                     #endif
                }
            })
            .disposed(by: disposeBag)
        
        return Output(error: getError.asDriverOnErrorJustNever())
    }
    
    // MARK: - Private methods
    
    private func showRecommend(_ isShow: Bool) {
        if isShow {
            self.navigator.pushToInviteFriendViewController()
        } else {
            self.navigator.pushToProfileViewController()
        }
    }
    
}
