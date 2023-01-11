//
//  MainHomeModel.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/09/23.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation

enum MainHomeTypes {
    case 용돈퀴즈
    case 실비보험청구
    case 병원약국찾기
    case 건강검진조회
    case 무료적립
    case 행운룰렛
    case 친구초대
    case 어디서했니
    case 쇼핑
    case 보험조회
    case 캐시로또
    case 오분게임
    case 진료내역조회
    case 신용조회
//    case 병원이벤트
}

struct MainHomeModel {
    var menuTitle = ""
    var menuImageName = ""
    var menuLink: SimpleCompletion?
    
    static func addMainModel() -> [MainHomeModel] {
        var makeTypes: [MainHomeTypes] = [.용돈퀴즈, .캐시로또, .어디서했니, .병원약국찾기, .진료내역조회, .실비보험청구, .건강검진조회, .신용조회, .쇼핑, .친구초대]
        if UserDefaults.standard.bool(forKey: UserDefaultKey.kIsShowRecommend.rawValue) {
            makeTypes = [.용돈퀴즈, .캐시로또, .어디서했니, .행운룰렛, .오분게임, .병원약국찾기, .진료내역조회, .실비보험청구, .건강검진조회, .신용조회, .쇼핑, .친구초대]
        }
        var mainModels = [MainHomeModel]()
        var makeModel = MainHomeModel()
        
        makeTypes.forEach { (type) in
            switch type {
            case .용돈퀴즈:
                makeModel.menuTitle = "용돈퀴즈"
                makeModel.menuImageName = "icQuizBlack32"
                makeModel.menuLink = {
                    let vc = CpqListViewController()
                    GlobalFunction.pushVC(vc, animated: true)
                }
                mainModels.append(makeModel)
            case .실비보험청구:
                makeModel.menuTitle = "실비보험청구"
                makeModel.menuImageName = "icHospitalBlack32"
                makeModel.menuLink = {
                    GlobalFunction.pushToWebViewController(title: "실비보험청구", url: API.INSURANCE_CLAIM, hiddenbar: true)
                }
                mainModels.append(makeModel)
            case .병원약국찾기:
                makeModel.menuTitle = "병원/약국찾기"
                makeModel.menuImageName = "icHospitalSearchBlack32"
                makeModel.menuLink = {
                    GlobalFunction.pushToWebViewController(title: "병원/약국 찾기", url: API.MEDICAL_MAP_URL, hiddenbar: true)
                }
                mainModels.append(makeModel)
            case .건강검진조회:
                makeModel.menuTitle = "건강검진조회"
                makeModel.menuImageName = "icCheckupBlack32"
                makeModel.menuLink = {
                    HealthNavigator.pushCheckupPage()
                }
                mainModels.append(makeModel)
            case .무료적립:
                makeModel.menuTitle = "무료적립"
                makeModel.menuImageName = "icSaveBlack32"
                makeModel.menuLink = {
                    if let viewcon = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FreeSegViewController") as? FreeSegViewController {
                        GlobalFunction.pushVC(viewcon, animated: true)
                    }
                }
                mainModels.append(makeModel)
            case .행운룰렛:
                makeModel.menuTitle = "행운룰렛"
                makeModel.menuImageName = "icGameBlack32"
                makeModel.menuLink = {
                    GlobalFunction.openLuckyCash(isPush: false)
                }
                mainModels.append(makeModel)
            case .친구초대:
                if UserDefaults.standard.bool(forKey: UserDefaultKey.kIsShowRecommend.rawValue) {
                    makeModel.menuTitle = "친구초대"
                    makeModel.menuImageName = "icFriendAddBlack32"
                    makeModel.menuLink = {
                        let vc = InviteFriendViewController()
                        GlobalFunction.pushVC(vc, animated: true)
                    }
                } else {
                    makeModel.menuTitle = "계정정보"
                    makeModel.menuImageName = "icFriendAddBlack32"
                    makeModel.menuLink = {
                        let navigator = MoreNavigator(navigationController: GlobalDefine.shared.curNav ?? UINavigationController(),
                                                      parentViewController: GlobalDefine.shared.curNav ?? UIViewController())
                        let vc = ProfileViewController()
                        vc.viewModel = ProfileViewModel(navigator: navigator)
                        GlobalFunction.pushVC(vc, animated: true)
                    }
                }
                mainModels.append(makeModel)
//            case .병원이벤트:
//                makeModel.menuTitle = "병원이벤트"
//                makeModel.menuImageName = "icEvent1Black32"
//                makeModel.menuLink = {
//                    GlobalFunction.pushToWebViewController(title: "병원이벤트", url: API.YEOGIYA_DOMAIN,webType: .yeogiya)
//                }
//                mainModels.append(makeModel)
            case .어디서했니:
                makeModel.menuTitle = "어디서했니"
                makeModel.menuImageName = "icYeogiya48"
                makeModel.menuLink = {
                    GlobalFunction.pushToWebViewController(title: "어디서했니", url: API.YEOGIYA_DOMAIN, addfooter: false, webType: .yeogiya)
                }
                mainModels.append(makeModel)
            case .쇼핑:
                makeModel.menuTitle = "쇼핑"
                makeModel.menuImageName = "icShoppingBlack32"
                makeModel.menuLink = {
                    let vc = ShopViewController()
                    GlobalFunction.pushVC(vc, animated: true)
                }
                mainModels.append(makeModel)
            case .보험조회:
                makeModel.menuTitle = "보험조회"
                makeModel.menuImageName = "icInsuranceBlack32"
                makeModel.menuLink = {
                    HealthNavigator.pushInsuranPage()
                }
                mainModels.append(makeModel)
            case .캐시로또:
                makeModel.menuTitle = "캐시로또"
                makeModel.menuImageName = "icCashlottoBlack32"
                makeModel.menuLink = {
                    GlobalFunction.pushToWebViewController(title: "캐시로또", url: API.LOTTO_INVENTORY_URL, hiddenbar: true)
                }
                mainModels.append(makeModel)
            case .오분게임:
                if UserDefaults.standard.bool(forKey: UserDefaultKey.kIsShowRecommend.rawValue) {
                    makeModel.menuTitle = "5분게임"
                    makeModel.menuImageName = "ic5GameBlack32"
                    makeModel.menuLink = {
                        let vc = Game5MinutesVC()
                        GlobalFunction.pushVC(vc, animated: true)
                    }
                } else {
                    makeModel.menuTitle = "행운룰렛"
                    makeModel.menuImageName = "icGameBlack32"
                    makeModel.menuLink = {
                        GlobalFunction.openLuckyCash(isPush: false)
                    }
                }
                mainModels.append(makeModel)
            case .진료내역조회:
                makeModel.menuTitle = "진료내역조회"
                makeModel.menuImageName = "icCheckup2Black32"
                makeModel.menuLink = {
                    HealthNavigator.pushMedicHistoryPage()
                }
                mainModels.append(makeModel)
            case .신용조회:
                makeModel.menuTitle = "신용조회"
                makeModel.menuImageName = "icCreditBlack32"
                makeModel.menuLink = {
                    GlobalFunction.pushToSafariBrowser(url: API.CREDIT_JOIN_URL)
                }
                mainModels.append(makeModel)
            }
        }
        
        return mainModels
    }
}
