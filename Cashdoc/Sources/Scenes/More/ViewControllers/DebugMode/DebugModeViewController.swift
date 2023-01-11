//
//  DebugModeViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 17/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxDataSources
import RxCocoa
import RxSwift
import RealmSwift
import Zip

enum DebugModeType: Int, CaseIterable {
    case apiServer
    case accessToken
    case timeOut
    case realmUrl
    case showEventCard
    case addCertificate
    case clearInsuran
    case clearHealthHistory
    case gotoCommnity
    case testPushToken
    case testPsuhTopic
    case showADLog
    case changedMediation
    case cashLottoMuhan
    case sspList
    case execlbidPopup
    case adpidPopup
    case deleteLotto
    
    var title: String {
        switch self {
        case .apiServer:
            return "API Server"
        case .accessToken:
            return "AccessToken Copy"
        case .timeOut:
            return "스크래핑 타임아웃 설정"
        case .realmUrl:
            return "Realm URL"
        case .showEventCard:
            return "이벤트 카드 보이기"
        case .addCertificate:
            return "테스트용 공동인증서 추가하기"
        case .clearInsuran:
            return "내보험다나와 로그아웃하기"
        case .clearHealthHistory:
            return "진료내역/건강검진 클리어"
        case .gotoCommnity:
            return "커뮤니티"
        case .testPushToken:
            return "테스트 푸시 토큰"
        case .testPsuhTopic:
            return "테스트 푸시 토픽"
        case .showADLog:
            return "광고미디에이션 로그보기"
        case .changedMediation:
            return "광고미디에이션 순서변경"
        case .cashLottoMuhan:
            return "캐시로또 무한상자"
        case .sspList:
            return "스퀘어배너 리스트(서버기준)"
        case .execlbidPopup:
            return "엑셀비드 팝업"
        case .adpidPopup:
            return "애드파이 팝업"
        case .deleteLotto:
            return "로또 초기화"
        }
    }
    
    func cellForRow() -> UITableViewCell {
        switch self {
        case .apiServer:
            if let rawValue = UserDefaults.standard.string(forKey: DebugUserDefaultsKey.kDebugAPIServer.rawValue),
               let serverType = APIServer(rawValue: rawValue) {
                return getSubtitleCell(title: title, subTitle: serverType.rawValue)
            } else {
                return getSubtitleCell(title: title, subTitle: "테스트")
            }
        case .timeOut:
            let subTitle = String(format: "%ld초", SmartAIBManager.shared.timeOut)
            return getSubtitleCell(title: title, subTitle: subTitle)
        case .testPushToken:
            let subTitle = UserManager.shared.userModel?.code ?? ""
            return getSubtitleCell(title: title, subTitle: subTitle)
        case .testPsuhTopic:
            let subTitle = UserManager.shared.userGroup ?? ""
            return getSubtitleCell(title: title, subTitle: subTitle)
        default:
            return getDefaultCell(title: title)
        }
    }
    
    func didSelected(vc: DebugModeViewController) {
        switch self {
        case .apiServer:
            var actions = [UIAlertAction]()
            APIServer.allCases.forEach { (type) in
                let action = UIAlertAction(title: type.rawValue, style: .default, handler: { (_) in
                    UserDefaults.standard.set(type.rawValue, forKey: DebugUserDefaultsKey.kDebugAPIServer.rawValue)
                    LoginManager.logout()
                    // 서버변경이후 1초 뒤에 아예 앱을 꺼버린다.
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
                        exit(0)
                    })
                })
                actions.append(action)
            }
            actions.append(UIAlertAction(title: "취소", style: .cancel))
            vc.alert(message: "접속하실 서버를 선택해 주세요.", preferredStyle: .actionSheet, actions: actions)
        case .accessToken:
            Log.i("AccessToken :\n\(AccessTokenManager.accessToken)")
            UIPasteboard.general.string = AccessTokenManager.accessToken
            vc.view.makeToastWithCenter("AccesToken이 복사되었습니다.")
        case .timeOut:
            var alert: UIAlertController!
            let okAction = UIAlertAction(title: "확인", style: .default) { (_) in
                if let timeOut = alert.textFields?[0].text,
                   let intTimeOut = Int(timeOut) {
                    UserDefaults.standard.setValue(intTimeOut, forKey: DebugUserDefaultsKey.kDebugTimeOut.rawValue)
                    SmartAIBManager.shared.timeOut = intTimeOut
                }
                vc.dataReload()
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            let textFieldHandler: (UITextField) -> Void = { (textField) in
                let timeOut = UserDefaults.standard.integer(forKey: DebugUserDefaultsKey.kDebugTimeOut.rawValue)
                if timeOut > 0 {
                    textField.text = String(timeOut)
                } else {
                    textField.placeholder = "타임 아웃(초)을 입력 해주세요. ex)180"
                }
            }
            alert = vc.alert(title: "스크래핑 타임아웃 설정",
                             preferredStyle: .alert,
                             actions: [okAction, cancelAction],
                             textFieldHandlers: [textFieldHandler])
        case .realmUrl:
            guard let url = Realm.Configuration.defaultConfiguration.fileURL?.absoluteString else { return }
            let tempUrl = url.components(separatedBy: "file://")[1]
            let resultUrl = tempUrl.components(separatedBy: "default.realm")[0]
            Log.i("\(String(format: "Realm URL : \n%@", resultUrl))")
            UIPasteboard.general.string = resultUrl
            vc.view.makeToastWithCenter("Realm URL이 복사되었습니다.")
        case .showEventCard:
            let useCase = EventCardUseCase()
            
            let putFlag = useCase.putFlagToShowEventCardForDebugMode()
            
            putFlag
                .drive(onNext: { (_) in
                    Log.i("putFlag")
                })
                .dispose()
            
            vc.view.makeToastWithCenter("이벤트 카드를 노출합니다.")
        case .addCertificate:
            do {
                let fileManager = FileManager.default
                guard let path = Bundle.main.url(forResource: "NPKI", withExtension: "zip") else { return }
                
                let unzipPath = try Zip.quickUnzipFile(path)
                
                if fileManager.fileExists(atPath: unzipPath.path) {
                    do {
                        try fileManager.createDirectory(atPath: unzipPath.path,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
                    } catch {
                        Log.e("Couldn't Create Cert Directory Error : \(error.localizedDescription)")
                    }
                    vc.view.makeToastWithCenter("테스트용 공동인증서가 추가되었습니다.")
                }
            } catch {
                Log.e("Fail to unzip : \(error.localizedDescription)")
            }
        case .clearInsuran:
            InsuranListRealmProxy().rm.clear()
            UserDefaults.standard.set(false, forKey: UserDefaultKey.kIsLinked내보험다나와.rawValue)
            vc.view.makeToastWithCenter("내보험다나와 초기화 완료.")
        case .clearHealthHistory:
            MedicHistoryRealmProxy().rm.clear()
            CheckUpRealmProxy().rm.clear()
            UserDefaults.standard.set(false, forKey: UserDefaultKey.kIsLinked내진료내역_new.rawValue)
            UserDefaults.standard.set(false, forKey: UserDefaultKey.kIsLinked건강검진_new.rawValue)
            vc.view.makeToastWithCenter("진료내역/건강검진 초기화 완료.")
        case .gotoCommnity:
            GlobalFunction.pushToWebViewController(title: "커뮤니티", url: API.COMMUNITY_WEB_URL, addfooter: true)
        case .testPushToken:
            let provider = CashdocProvider<PushService>()
            let okAction = UIAlertAction(title: "확인", style: .default) { (_) in
                provider.CDRequestWithoutJSON(.pushToken(code: UserManager.shared.userModel?.code ?? "")) { (json) in
                    Log.tj(json)
                }
                vc.dataReload()
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            let textFieldHandler: (UITextField) -> Void = { (textField) in
                let timeOut = UserDefaults.standard.integer(forKey: DebugUserDefaultsKey.kDebugTimeOut.rawValue)
                if timeOut > 0 {
                    textField.text = String(timeOut)
                } else {
                    textField.placeholder = "추천인 코드 입력해줘요."
                }
            }
            vc.alert(title: "추천인 코드 입력",
                     preferredStyle: .alert,
                     actions: [okAction, cancelAction],
                     textFieldHandlers: [textFieldHandler])
        case .testPsuhTopic:
            let provider = CashdocProvider<PushService>()
            let okAction = UIAlertAction(title: "확인", style: .default) { (_) in
                provider.CDRequestWithoutJSON(.pushTopic(topic: UserManager.shared.userGroup ?? "")) { (json) in
                    Log.tj(json)
                }
                vc.dataReload()
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            let textFieldHandler: (UITextField) -> Void = { (textField) in
                let timeOut = UserDefaults.standard.integer(forKey: DebugUserDefaultsKey.kDebugTimeOut.rawValue)
                if timeOut > 0 {
                    textField.text = String(timeOut)
                } else {
                    textField.placeholder = "타임 아웃(초)을 입력 해주세요. ex)180"
                }
            }
            vc.alert(title: "스크래핑 타임아웃 설정",
                     preferredStyle: .alert,
                     actions: [okAction, cancelAction],
                     textFieldHandlers: [textFieldHandler])
        case .showADLog:
            MediactionManager.shared().showLogView()
        case .changedMediation:
            var actions = [UIAlertAction]()
            AdMediationType.allCases.forEach { (adType) in
                let title = adType.rawValue
                let action = UIAlertAction(title: title, style: .default, handler: { (_) in
                    self.updateAdMediationWithTest(adType: adType,
                                                   controller: vc)
                })
                actions.append(action)
            }
            actions.append(UIAlertAction(title: "취소", style: .cancel))
            vc.alert(message: "우선순위를 변경하실 로그를 선택해 주세요.", preferredStyle: .actionSheet, actions: actions)
        case .cashLottoMuhan:
            let muhan = UserDefaults.standard.bool(forKey: UserDefaultKey.kLottoMuhan.rawValue)
            UserDefaults.standard.set(!muhan, forKey: UserDefaultKey.kLottoMuhan.rawValue)
            
            vc.view.makeToastWithCenter("캐시로또 무한상자 : \(muhan ? "OFF" : "ON")")
        case .sspList:
            var list = ""
            for i in GlobalDefine.shared.SSPList?.order ?? [] {
                list.append(i+" ")
            }
            list.append("\n")
            list.append("[ADPIE: \(GlobalDefine.shared.SSPList?.ADPIE_Timeout ?? 1000)]")
            list.append("[EXELBID: \(GlobalDefine.shared.SSPList?.EXELBID_Timeout ?? 1000)]")
            
            let cancelAction = UIAlertAction(title: "확인", style: .cancel)
            vc.alert(title: "스퀘어배너 순서", message: list, preferredStyle: .alert, actions: [cancelAction])
        case .execlbidPopup:
            let squareBannerPopup = SquareBannerPopup(type: .EXELBID)
            GlobalDefine.shared.curNav?.present(squareBannerPopup, animated: false)
        case .adpidPopup:
            let squareBannerPopup = SquareBannerPopup(type: .ADPIE)
            GlobalDefine.shared.curNav?.present(squareBannerPopup, animated: false)
        case .deleteLotto:
            let provider = CashdocProvider<LottoService>()
            provider.CDRequest(.deleteLotto) { json in
                let result = json["result"].stringValue
                Log.al("result : \(result)")
                vc.view.makeToastWithCenter("로또 초기화 : \(result)")
            } failure: { _ in
                
                vc.view.makeToastWithCenter("deleteLotto failure")
            }
        }
    }
    
    private func updateAdMediationWithTest(adType: AdMediationType,
                                           controller: DebugModeViewController) {
        
        var alert: UIAlertController!
        let okAction = UIAlertAction(title: "확인", style: .default) { (_) in
            guard let textCount = alert.textFields?.first?.text?.count, textCount > 0 else {
                controller.view.makeToastWithCenter("하나 이상 입력해주세요.")
                return
            }
            if let adMediationStr = alert.textFields?.first?.text?.uppercased() {
                let stringTrim = adMediationStr.replacingOccurrences(of: " ", with: "")
                let adMediation = stringTrim.components(separatedBy: ",")
                if adType == .video {
                    MediactionManager.shared().setSortedList(adMediation)
                    controller.view.makeToastWithCenter("변경되었습니다.")
                } else {
                    MediactionBanner.shared().setSortedList(adMediation)
                    controller.view.makeToastWithCenter("변경되었습니다.")
                }
                
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        let adMediationTextFieldHandler: (UITextField) -> Void = { (textField) in
            textField.placeholder = "광고명 순서대로 기입 예) VUNGLE, UNITY, ADMOB"
        }
        alert = controller.alert(title: "광고 미디에이션 순서 변경",
                                 preferredStyle: .alert,
                                 actions: [okAction, cancelAction],
                                 textFieldHandlers: [adMediationTextFieldHandler])
    }
    
    private func getDefaultCell(title: String) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = title
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
        cell.textLabel?.textColor = .blueCw
        cell.textLabel?.numberOfLines = 0
        cell.selectionStyle = .none
        return cell
    }
    
    private func getSubtitleCell(title: String, subTitle: String) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = title
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
        cell.textLabel?.textColor = .blueCw
        cell.detailTextLabel?.text = subTitle
        cell.selectionStyle = .none
        return cell
    }
}

final class DebugModeViewController: CashdocViewController {
    
    private var viewModel: DebugModeViewModel!
    private let tableView = SelfSizedTableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.estimatedRowHeight = 65
        $0.rowHeight = UITableView.automaticDimension
        $0.clipsToBounds = true
        $0.register(cellType: UITableViewCell.self)
    }
    
    // MARK: - Con(De)structor
    
    init(viewModel: DebugModeViewModel) {
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
    }
    
    // MARK: - Binding
    
    private func bindView() {
        tableView.rx
            .itemSelected
            .bind(onNext: { [weak self] (ip) in
                guard let self = self, let debugType = DebugModeType(rawValue: ip.row) else { return }
                debugType.didSelected(vc: self)
            })
            .disposed(by: disposeBag)
    }
    
    func dataReload() {
        tableView.reloadData()
    }
    
    private func bindViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:))).take(1).mapToVoid()
        let input = type(of: self.viewModel).Input(trigger: viewWillAppear.asDriverOnErrorJustNever())
        
        let output = viewModel.transform(input: input)
        
        output.sections
            .drive(tableView.rx.items(dataSource: RxTableViewSectionedReloadDataSource<DebugModeSection>(configureCell: { (_, _, _, item) in
                switch item {
                case .item(let item):
                    return item.cellForRow()
                }
            })))
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
        title = "테스트 모드"
    }
    
}

// MARK: - Layout

extension DebugModeViewController {
    private func layout() {
        tableView.topAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}
