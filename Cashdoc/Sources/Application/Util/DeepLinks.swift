//
//  DeepLinks.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/03/27.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation
import CoreLocation

class DeepLinks {
    // 스키마URL처리
    class func openSchemeURL(urlstring: String, gotoMain: Bool) {
        Log.i("openSchemeURL : \(urlstring)")
        
        // 딥링크 이동하면 푸시 감지 초기화
        UserManager.shared.isPushDeepLink = nil
        
        // 로그아웃시에 이동안함
        if AccessTokenManager.accessToken == "" {
            return
        }
        
        let url = URL(string: urlstring)
        
        // 메인으로 강제로 이동할건지
        if gotoMain {
            GlobalDefine.shared.curNav?.popToRootViewController(animated: false)
        }
        
        if let urlHost = url?.host, urlHost.contains(API.YEOGIYA_DOMAIN) {
             
            guard var controllers = GlobalDefine.shared.curNav?.viewControllers else {return}
            let yeogiyaMain = CashdocWebViewController(title: "어디서했니", url: API.YEOGIYA_DOMAIN, webType: .yeogiya)
            yeogiyaMain.addfooter = false
            
            if let cashdocWeb = controllers.last as? CashdocWebViewController {
                Log.al("cashdocWeb.urlString = \(cashdocWeb.urlString)")
                if cashdocWeb.urlString != API.YEOGIYA_DOMAIN {
                    controllers.append(yeogiyaMain)
                }
            } else {
                controllers.append(yeogiyaMain)
            }
            
            let yeogiyaEvent = CashdocWebViewController(title: "어디서했니", url: urlstring, webType: .yeogiya)
            yeogiyaEvent.addfooter = true
            controllers.append(yeogiyaEvent)
            
            DispatchQueue.main.async {
                GlobalDefine.shared.curNav?.setViewControllers(controllers, animated: true)
            }
            
            return
        }
         
        // http면 그냥 웹뷰로 연결
        else if (urlstring.hasPrefix("http") && url?.host != "cashdoc.me") || (urlstring.hasPrefix("https") && url?.host != "cashdoc.me") {
            GlobalFunction.pushToWebViewController(title: "캐시닥", url: urlstring)
            return
        }
        
        // url이동 처리
        if let applink = url?.valueOf("applink") {
            DeepLinks.openApplinks(applink)
            return
        }
        
        if let quiz = url?.valueOf("quiz") {
            
            if quiz.isEmpty {
                let vc = CpqListViewController()
                GlobalFunction.pushVC(vc, animated: true)
                
            } else {
                
                guard var controllers = GlobalDefine.shared.curNav?.viewControllers else { return }
               
                let cpqlist = CpqListViewController()
                let cpqDetail = CpqDetailViewController()
                cpqDetail.quizID = quiz
                
                if controllers.last is CpqListViewController {
                    GlobalFunction.pushVC(cpqDetail, animated: true)
                } else {
                    controllers.append(cpqlist)
                    controllers.append(cpqDetail)
                    DispatchQueue.main.async {
                        GlobalDefine.shared.curNav?.setViewControllers(controllers, animated: true)
                    }
                }
            }
        } else if let shopping = url?.valueOf("shopping") {
            if shopping.isEmpty {
                let vc = ShopViewController()
                GlobalFunction.pushVC(vc, animated: true)
            } else {
                let vc = ShopDetailViewController()
                let shopNavi = DefaultShopNavigator(parentViewController: GlobalDefine.shared.mainSeg ?? UIViewController())
                vc.viewModel = ShopDetailViewModel(navigator: shopNavi, useCase: .init())
                vc.item = ShopItemModel(title: nil, goodsId: shopping, price: nil, imageUrl: nil, affiliate: nil, type: nil, validity: nil, description: nil, pinNo: nil, ctrId: nil, expiredAt: nil, delay: nil)
                GlobalFunction.pushVC(vc, animated: true)
            }
        } else if let board = url?.valueOf("board"), let pid = url?.valueOf("pid") {
            if let url = URLComponents(string: API.COMMUNITY_WEB_URL) {
                if let scheme = url.scheme, let host = url.host {
                    let baseUrl = scheme + "://" + host
                    let commUrl = baseUrl + "/" + board + "/" + pid + "?new_window=true"
                    let isLoaded: Bool = GlobalDefine.shared.mainCommunity?.isLoaded ?? false
//                    GlobalDefine.shared.mainSeg?.changeSegment(.커뮤니티, popToRoot: !isLoaded)
                    if isLoaded {
                        GlobalFunction.pushToWebViewController(title: "커뮤니티", url: commUrl, addfooter: true)
                    } else {
                        GlobalDefine.shared.mainCommunity?.communityPostsURL = commUrl
                    }
                }
            }
        } else if let openweb = url?.valueOf("openweb") {
            var makeTitle = "캐시닥"
            if let cdtitle = url?.valueOf("cdtitle"), !cdtitle.isEmpty {
                makeTitle = cdtitle
            }
            Log.al("makeTitle = \(makeTitle)")
            var hiddenValue = false
            if let hiddenbar = url?.valueOf("hiddenbar") {
                if hiddenbar == "true" {
                    hiddenValue = true
                }
            }
            
            if let type = url?.valueOf("type") {
                switch type {
                    case "weather":
                        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                        } else {
                            GlobalFunction.pushToWebViewController(title: makeTitle, url: openweb, hiddenbar: hiddenValue)
                        }
                    case "addfooter":
                        GlobalFunction.pushToWebViewController(title: makeTitle, url: openweb, addfooter: true, hiddenbar: hiddenValue)
                    
                    default:
                        GlobalFunction.pushToWebViewController(title: makeTitle, url: openweb, hiddenbar: hiddenValue)
                }
            } else {
                GlobalFunction.pushToWebViewController(title: makeTitle, url: openweb, hiddenbar: hiddenValue)
            }
            
        } else if let openbrowser = url?.valueOf("openbrowser") {
            if let url = URL(string: openbrowser) {
                UIApplication.shared.open(url, options: [:])
            }
        } else if let changetab = url?.valueOf("changetab") {
            if let makeSeg = MainSegIndex.init(rawValue: Int(changetab) ?? 0) {
                GlobalDefine.shared.mainSeg?.changeSegment(makeSeg)
            }
        } else if let sharekakao = url?.valueOf("sharekakao"),
                  let imageurl = url?.valueOf("imageurl"),
                  let linkurl = url?.valueOf("linkurl") {
            GlobalFunction.shareKakao(sharekakao, description: "", imgURL: imageurl, link: linkurl, buttonTitle: "자세히 보기")
        } else if let sendmail = url?.valueOf("sendmail"),
                  let name = url?.valueOf("name"),
                  let address = url?.valueOf("address"),
                  let separated = url?.valueOf("separated") {
            let makeArray = [sendmail, name, address, separated]
            MailManager.showMailCompose(to: GlobalDefine.shared.curNav ?? UIViewController(), sendmail: makeArray)
        } else if let sendmail = url?.valueOf("sendmail"),
                  let rank = url?.valueOf("rank") {
            let makeArray = [sendmail, rank]
            MailManager.showMailCompose(to: GlobalDefine.shared.curNav ?? UIViewController(), sendmail: makeArray)
        } else if let cashlotto = url?.valueOf("cashlotto") {
            if cashlotto == "win" {
                GlobalFunction.pushToWebViewController(title: "캐시로또", url: API.LOTTO_INVENTORY_URL + "?tab=3", hiddenbar: true)
            } else {
                GlobalFunction.pushToWebViewController(title: "캐시로또", url: API.LOTTO_INVENTORY_URL, hiddenbar: true)
            }
        } else if let image = url?.valueOf("downloadCommunity") {
            if GlobalFunction.authorizedPhotoLibrary() {
                if let imageUrl = URL(string: image) {
                    UIImageView().kf.setImage(with: imageUrl, completionHandler: { result in
                        switch result {
                            case .success(let value):
                                UIImageWriteToSavedPhotosAlbum(value.image, self, nil, nil)
                                GlobalDefine.shared.curNav?.view.makeToastWithCenter("파일 다운로드가 완료되었습니다.")
                            default:
                                return
                        }
                    })
                }
            }
        } else if let downloadFile = url?.valueOf("downloadFile") {
            guard let url = URL(string: downloadFile) else {
                GlobalDefine.shared.curNav?.view.makeToastWithCenter("URL 주소가 유효하지않습니다.")
                return
            }
            GlobalDefine.shared.uiDocumentCon = UIDocumentInteractionController()
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                let tmpURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(response?.suggestedFilename ?? "sap.pdf")
                do {
                    try data.write(to: tmpURL)
                    DispatchQueue.main.async {
                        GlobalDefine.shared.uiDocumentCon?.url = tmpURL
                        GlobalDefine.shared.uiDocumentCon?.uti = tmpURL.typeIdentifier ?? "public.data, public.content"
                        GlobalDefine.shared.uiDocumentCon?.name = tmpURL.localizedName ?? tmpURL.lastPathComponent
                        if let getView = GlobalDefine.shared.curNav?.view {
                            GlobalDefine.shared.uiDocumentCon?.presentOptionsMenu(from: getView.frame, in: getView, animated: true)
                        }
                    }
                } catch {
                    print(error)
                }
                
            }.resume()
            
        } else if let sharelink = url?.valueOf("sharelink") {
            
            let message = url?.valueOf("message") ?? ""
            let text = """
            \(message)\n\(sharelink)
            """
            let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            activityVC.excludedActivityTypes = []
            GlobalDefine.shared.curNav?.present(activityVC, animated: true, completion: nil)
        } else if url?.scheme == "inner", let applink = url?.host {
            Log.al("applink = \(applink)")
            openApplinks(applink)
        }
    }
    
    class func openApplinks(_ applink: String) {
        switch applink {
        case "luckyCash":
            GlobalFunction.openLuckyCash(isPush: false)
        case "cashdetail":
            let navigator = MoreNavigator(navigationController: GlobalDefine.shared.curNav ?? UINavigationController(),
                                          parentViewController: GlobalDefine.shared.curNav ?? UIViewController())
            let vc = CurrentCashViewController()
            vc.viewModel = CurrentCashViewModel(navigator: navigator,
                                                useCase: .init())
            GlobalFunction.pushVC(vc, animated: true)
        case "invitefriend", "recommend":
            let vc = InviteFriendViewController()
            GlobalFunction.pushVC(vc, animated: true)
        case "freecharge":
            if let viewcon = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FreeSegViewController") as? FreeSegViewController {
                GlobalFunction.pushVC(viewcon, animated: true)
            }
        case "medichistory", "treatment":
            HealthNavigator.pushMedicHistoryPage()
        case "showinsurance":
            HealthNavigator.pushInsuranPage()
        case "returnhome":
            GlobalFunction.CDPopToRootViewController(animated: false)
            GlobalDefine.shared.mainSeg?.changeSegment(.홈)
            GlobalDefine.shared.mainHome?.requestRefresh()
        case "close":
            GlobalDefine.shared.isPossibleShowPopup = true
            if let CashdocWebVC = GlobalDefine.shared.curNav?.viewControllers.last as? CashdocWebViewController {
                CashdocWebVC.popToVC()
                return
            }
            GlobalDefine.shared.curNav?.popViewController(animated: true)
        case "insuranceclaim", "insurance":
            GlobalFunction.pushToWebViewController(title: "실비보험청구", url: API.INSURANCE_CLAIM, hiddenbar: true)
        case "scrappingCheckup":
            if let viewcon = UIStoryboard.init(name: "MedicHistory", bundle: nil).instantiateViewController(withIdentifier: MedicHistoryJuminVC.reuseIdentifier) as? MedicHistoryJuminVC {
                viewcon.isCheckUp = true
                GlobalFunction.pushVC(viewcon, animated: true)
            }
        case "smsAuth":
            let vc = SmsAuthViewController()
            vc.viewModel = AuthViewModel(useCase: .init())
            GlobalFunction.pushVC(vc, animated: true)
        case "coupon":
            let vc = CouponListViewController()
            vc.viewModel = CouponViewModel.init(GlobalDefine.shared.curNav ?? UIViewController())
            GlobalDefine.shared.curNav?.popViewController(animated: false)
            GlobalFunction.pushVC(vc, animated: true)
        case "refreshPoint":
            UserManager.shared.getPoint()
        case "checkup":
            HealthNavigator.pushCheckupPage()
            
        case "yeogiya":
            let yeogiyaMain = CashdocWebViewController(title: "어디서했니", url: API.YEOGIYA_DOMAIN, webType: .yeogiya)
            yeogiyaMain.addfooter = false
            DispatchQueue.main.async {
                GlobalFunction.pushVC(yeogiyaMain, animated: true)
            }
        default:
            break
        }
    }
}
