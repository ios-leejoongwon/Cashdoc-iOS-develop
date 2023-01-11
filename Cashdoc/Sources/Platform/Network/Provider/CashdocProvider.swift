//
//  CashdocProvider.swift
//  Cashdoc
//
//  Created by DongHeeKang on 21/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Moya
// import RxMoya
import RxSwift
import Alamofire
import SwiftyJSON

struct InviteErrorModel: Decodable {
    let error: InviteError
}

struct InviteError: Codable {
    var status: Int
    var code: Int
    var type: String
    
    init(_ json: JSON) {
        code = json["code"].intValue
        type = json["type"].stringValue
        status = json["status"].intValue
    }
}

struct CashdocErrorModel: Decodable {
    let error: CashdocError
}

struct CashdocError: Decodable {
    let code: Int
    let type: String
    let message: String
    let debug: CashdocErrorDebug?
    
    init(_ json: JSON) {
        code = json["code"].intValue
        type = json["type"].stringValue
        message = json["message"].stringValue
        
        let getStack = json["stack"].arrayValue
        var stringArray = [String]()
        for stack in getStack {
            stringArray.append(stack.stringValue)
        }
        debug = CashdocErrorDebug(stack: stringArray)
    }
}

struct CashdocErrorDebug: Decodable {
    let stack: [String]
}

final class CashdocProvider<Target: TargetType>: MoyaProvider<Target> {
    // MARK: - Class func
    
    private class func networkActivityPluginFactory() -> NetworkActivityPlugin {
        return NetworkActivityPlugin(networkActivityClosure: { (change, _) in
            DispatchQueue.main.async {
                let indicatorVisible: Bool
                switch change {
                    case .began:
                        indicatorVisible = true
                    case .ended:
                        indicatorVisible = false
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = indicatorVisible
            }
        })
    }
    
    // MARK: - Properties
    
    let disposeBag = DisposeBag()
    
    // MARK: - Con(De)structor
    
    init(stubClosure: MoyaProvider<Target>.StubClosure? = nil, plugins: [PluginType]? = nil) {
        let networkActivityPlugin = type(of: self).networkActivityPluginFactory()
        var finalPlugins = plugins ?? [PluginType]()
        finalPlugins.append(networkActivityPlugin)
        if let getStub = stubClosure {
            super.init(stubClosure: getStub, session: DefaultAlamofireManager.sharedManager, plugins: finalPlugins)
        } else {
            super.init(session: DefaultAlamofireManager.sharedManager, plugins: finalPlugins)
        }
    }
    
    // MARK: - Internal methods
    func CDRequest(_ target: Target, showLoading: Bool = false, getResultJson: @escaping (JSON) -> Void, failure: ((Error) -> Void)? = nil) {
        guard ReachabilityManager.reachability.connection != .unavailable else {
            GlobalDefine.shared.curNav?.simpleAlert(message: "인터넷 연결이 원활하지않습니다.")
            return
        }
        
        if showLoading {
            GlobalFunction.CDShowLogoLoadingView()
        }
        self.rx.request(target)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .subscribe { event in
                if showLoading {
                    GlobalFunction.CDHideLogoLoadingView()
                }
                 
                switch event {
                    case .success(let jsonAny):
                        let makeJSON = JSON(jsonAny)
                        let errorModel = CashdocError(makeJSON["error"])
                        
                        let makeDict: [String: Any] = ["01.URL": "[\(target.method.rawValue)] \(target.baseURL)\(target.path)", "02.Target": target, "03.Response": makeJSON.rawString() ?? "NO DATA"]
                        Log.d(makeDict)
                        
                        if errorModel.code != 0 {
                            let error = NSError(domain: errorModel.message,
                                                code: errorModel.code,
                                                userInfo: ["stack": errorModel.debug?.stack[safe: 0] ?? ""])
                            failure?(error)
                            self.errorFunc(error, target: target, defaultAlert: failure == nil)
                        } else {
                            getResultJson(makeJSON)
                        }
                    case .failure(let error):
                        failure?(error)
                        self.errorFunc(error, target: target, defaultAlert: failure == nil)
                }
            }.disposed(by: disposeBag)
    }
    
    func CDRequestWithoutJSON(_ target: Target, showLoading: Bool = false, getResultJson: @escaping (Any) -> Void) {
        guard ReachabilityManager.reachability.connection != .unavailable else {
            GlobalDefine.shared.curNav?.simpleAlert(message: "인터넷 연결이 원활하지않습니다.")
            return
        }
        
        if showLoading {
            GlobalFunction.CDShowLogoLoadingView()
        }
        
        self.rx.request(target)
            .filterSuccessfulStatusCodes()
            // .observe(on: ConcurrentDispatchQueueScheduler(qos: .utility)) // 크래시로 의심되어서 제거
            .subscribe { event in
                if showLoading {
                    GlobalFunction.CDHideLogoLoadingView()
                }
                Log.al("event = \(event)")
                switch event {
                    case .success:
                        let makeDict: [String: Any] = ["01.URL": "[\(target.method.rawValue)] \(target.baseURL)\(target.path)"]
                        Log.d(makeDict)
                    case .failure(let error):
                    Log.al("\(error)")
                        self.errorFunc(error, target: target)
                }
            }.disposed(by: disposeBag)
    }
    
    func request<T>(_ modelType: T.Type, token: Target, callbackQueue: DispatchQueue? = nil) -> Single<T> where T: Decodable {
        return Single<T>.create(subscribe: { [weak self] observer -> Disposable in
            let disposable = Disposables.create()
            guard let self = self else {return disposable}
            self.rx.request(token, callbackQueue: callbackQueue)
                .subscribe(onSuccess: { (response) in
                    let data = response.data
                    #if DEBUG
                    let jsonData = JSON(data)
                    let makeDict: [String: Any] = ["01.URL": "[\(token.method.rawValue)] \(token.baseURL)\(token.path)", "02.Target": token, "03.Response": jsonData.rawString() ?? "NO DATA"]
                    Log.d(makeDict)
                    #endif
                    
                    if let model = try? self.parse(CashdocErrorModel.self, data: data) {
                        let error = NSError(domain: model.error.message,
                                            code: model.error.code,
                                            userInfo: ["stack": model.error.debug?.stack[safe: 0] ?? ""])
                        self.errorFunc(error, target: token)
                        observer(.failure(error))
                    } else {
                        do {
                            switch modelType {
                                case is String.Type:
                                Log.al("170")
                                    if let model = String(data: data, encoding: .utf8) as? T {
                                        observer(.success(model))
                                    } else {
                                        observer(.failure(NSError()))
                                    }
                                case is GetCertificateInfo.Type:
                                    let model = String(data: data, encoding: .utf8)
                                    let modelArray = model?.components(separatedBy: "@")
                                    guard let url = URLComponents(string: response.request?.url?.absoluteString ?? ""),
                                          let checkAuthKey = url.queryItems?.first(where: {$0.name == "authKey"})?.value else { return }
                                    
                                    guard modelArray?[safe: 0] == checkAuthKey,
                                          let certData = modelArray?[safe: 1]?.data(using: .utf8) else {
                                        let errorModel = try self.parse(CertificateInfoResult.self, data: data)
                                        let code = errorModel.resultCode.replacingOccurrences(of: "E", with: "", options: .literal, range: nil)
                                        let error = NSError(domain: errorModel.resultMsg,
                                                            code: Int(code)!,
                                                            userInfo: nil)
                                        
                                            Log.al("191")
                                        return observer(.failure(error))}
                                    let certModel = try self.parse(modelType, data: certData)
                                    observer(.success(certModel))
                                
                                default:
                                    let model = try self.parse(modelType, data: data)
                                    observer(.success(model))
                            }
                        } catch {
//                                Log.al("202")
                            if let model = try? self.parse(InviteErrorModel.self, data: data) {
                                let error = NSError(domain: model.error.type,
                                                    code: model.error.code,
                                                    userInfo: ["stack": ""])
                                observer(.failure(error))
                            } else {
                                observer(.failure(error))
                            }
                        }
                    }
                }, onFailure: { [weak self] (error) in
                    self?.errorFunc(error, target: token)
                    observer(.failure(error))
                })
                .disposed(by: self.disposeBag)
            
            return disposable
        })
    }
    
    // MARK: - Private methods
    
    private func errorFunc(_ error: Error, target: Target, defaultAlert: Bool = true) {
        // 중복로그인 처리 103
        if error.code == 103 && AccessTokenManager.accessToken.isNotEmpty {
            let makeAction = UIAlertAction(title: "확인", style: .default) { _ in
                // 업데이트 팝업이 있을경우에는 동작안함
                if (UIApplication.shared.keyWindow?.viewWithTag(7979)) == nil {
                    LoginManager.logout()
                }
            }
            GlobalDefine.shared.curNav?.alert(title: "중복 로그인 안내", message: "동일한 계정으로 로그인 되어\n로그아웃 합니다.", preferredStyle: .alert, actions: [makeAction])
            return
        }
        
        Log.e("01.URL : [\(target.method.rawValue)] \(target.baseURL)\(target.path)")
        Log.e("02.Network error : \(error.localizedDescription)")
        
        switch error.code {
            case 100, 210:
                GlobalDefine.shared.curNav?.simpleAlert(title: "안내", message: "존재하지 않는 추천코드입니다.")
            case 124: // UpdateClientError
                GlobalDefine.shared.curNav?.simpleAlert(title: "안내", message: "최신버전으로 업데이트 하셔야 포인트 적립이 가능합니다.")
            case 132: // 퀴즈오답
                return
            case 133:
                let toastText = "아쉽게도, 준비된 퀴즈가 종료되었습니다."
                GlobalDefine.shared.curNav?.view.makeToast(toastText, position: .bottom)
            case 136:
                let toastText = "이미 참여한 퀴즈입니다."
                GlobalDefine.shared.curNav?.view.makeToast(toastText, position: .bottom)
            case 224:
                return
            case 227: // ShopListError
                GlobalDefine.shared.curNav?.simpleAlert(title: "안내", message: "쇼핑 리스트를 불러오는 중 오류가 발생했습니다.")
            case 228:
                GlobalDefine.shared.curNav?.simpleAlert(title: "안내", message: "추천코드 입력은 1회만 가능합니다.")
            case 252:
                let toastText = "이미 참여한 퀴즈입니다."
                GlobalDefine.shared.curNav?.view.makeToast(toastText, position: .bottom)
            case 301: // AlreadyAuthError
                GlobalDefine.shared.curNav?.simpleAlert(title: "안내", message: "이미 인증된 번호입니다.\n회원탈퇴 시 7일 후에 다른계정에서 다시 인증할 수 있습니다.")
            case 322: // AuthenticationError
                GlobalDefine.shared.curNav?.simpleAlert(title: "안내", message: "그냥사용해보기로 사용중이신 경우 휴대폰 번호 인증이 필요합니다. 최초 1회만 인증하시면 계속 편하게 쇼핑을 이용하실 수 있습니다.")
            case 341: // AuthenticationError
            GlobalFunction.CDHideLogoLoadingView()
            GlobalDefine.shared.curNav?.simpleAlert(title: "안내", message: "간편인증이 완료되지 않았습니다. 앱에서 인증을 완료해주시기 바랍니다")
            case 400: // TransactionError
                GlobalDefine.shared.curNav?.simpleAlert(title: "안내", message: "일시적인 오류가 발생하였습니다. 문제가 지속되면 설정의 불편사항 신고하기로 문의 남겨주시기 바랍니다.")
            case 403: // LimitPurchaseError
                GlobalDefine.shared.curNav?.simpleAlert(title: "안내", message: "아쉽게도 오늘은 마감되었어요. 내일 다시 시도해주세요.")
            case 404: // ShopNotOpenError
                GlobalDefine.shared.curNav?.simpleAlert(title: "안내", message: "쇼핑이용 가능시간이 지났어요.\n가능시간:평일 오전10시~오후7시")
            case 605:
                GlobalDefine.shared.curNav?.view.makeToast("이미 로또를 모두 발급 받으셨어요.\n내일 다시 시도해주세요.", position: .bottom)
            case 610:
                let toastText = "출석로또가 발급안되었습니다.\n새로고침이후에 재시도 부탁드립니다."
                GlobalDefine.shared.curNav?.view.makeToast(toastText, position: .bottom)
            case 10200: // BannedUserError
                let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                let makeAction = UIAlertAction(title: "문의", style: .default) { _ in
                    MailManager.showMailCompose(to: GlobalDefine.shared.curNav ?? UIViewController(), isInquire: true)
                }
                GlobalDefine.shared.curNav?.alert(title: "계정 사용 제한 안내", message: "해당 계정은 부정사용으로 의심되어\n사용 정지되었습니다.\n부정사용에 해당되지 않는 경우 문의를 남겨주세요.", preferredStyle: .alert, actions: [cancelAction, makeAction])
            case 10201: // NoPointError
                GlobalDefine.shared.curNav?.simpleAlert(title: "안내", message: "포인트가 부족합니다.")
            case 10300: // SMSLimitError
                GlobalDefine.shared.curNav?.simpleAlert(title: "문자인증 한도가 초과되었으니 내일 다시 시도해주세요.", message: "신속한 인증을 원할 경우 앱내 불편사항 신고하기를 통해 문의해주세요.")
            case 10301: // SMSFailed
                GlobalDefine.shared.curNav?.simpleAlert(title: "안내", message: "유효하지 않은 인증번호 입니다.\n번호를 다시 확인하거나\n인증번호 다시 받기를 해주세요.")
            default:
                if defaultAlert {
                    #if DEBUG
                    GlobalFunction.CDHideLogoLoadingView()
                    GlobalDefine.shared.curNav?.simpleAlert(title: "네트워크 오류 (DEBUG)", message: error.localizedDescription)
                    #else
                    GlobalFunction.CDHideLogoLoadingView()
                    GlobalDefine.shared.curNav?.simpleAlert(title: "안내", message: "네트워크 연결 상태를 확인해주세요.")
                    #endif
                }
        }
    }
    
    private func parse<T>(_ modelType: T.Type, data: Data) throws -> T where T: Decodable {
        return try JSONDecoder().decode(modelType, from: data)
    }
}

class DefaultAlamofireManager: Alamofire.Session {
    static let sharedManager: DefaultAlamofireManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20 // as seconds, you can set your request timeout
        configuration.timeoutIntervalForResource = 20 // as seconds, you can set your resource timeout
        configuration.requestCachePolicy = .reloadIgnoringCacheData
        return DefaultAlamofireManager(configuration: configuration)
    }()
}
