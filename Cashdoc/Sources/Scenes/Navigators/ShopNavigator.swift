//
//  ShopNavigator.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 20/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import MessageUI
import SafariServices
import UIKit
import RxSwift

protocol ShopNavigator {
    func pushShopGoodsListVC(_ category: ShopCategoryModel)
    func pushShopDetailVC(_ item: ShopItemModel)
    func showBuyCompleteView(item: ShopBuyItemModel)
    func showNoPointView()
    func presentTextviewLink(url: URL)
    func presentBlockUserMailCompose()
    func popViewController()
    func pushShoppingAuth()
}

final class DefaultShopNavigator: ShopNavigator {
    
    // MARK: - Constants
    
    private struct Const {
        static let showCouponVC = "showCouponVC"
        static let showShoppingAuthVC = "showShoppingAuthVC"
    }
    
    // MARK: - Properties
    
    private var disposeBag = DisposeBag()
    private weak var parentViewController: UIViewController?
    
    // MARK: - Con(De)structor
    
    init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
    }
    
    // MARK: - Internal methods
    
    func pushShopGoodsListVC(_ category: ShopCategoryModel) {
        let vc = ShopGoodsListViewController()
        vc.viewModel = ShopGoodsListViewModel(navigator: self)
        vc.category = category

        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func pushShopDetailVC(_ item: ShopItemModel) {
        let vc = ShopDetailViewController()
        vc.viewModel = ShopDetailViewModel(navigator: self, useCase: .init())
        vc.item = item
 
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func showBuyCompleteView(item: ShopBuyItemModel) {
        guard let parentView = GlobalDefine.shared.curNav?.view else {return}
        
        let buyCompletePopup = ShopBuyCompleteView()
        buyCompletePopup.translatesAutoresizingMaskIntoConstraints = false
        buyCompletePopup.configure(viewModel: .init(model: item), item: item)
        
        parentView.addSubview(buyCompletePopup)
        
        buyCompletePopup.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        buyCompletePopup.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        buyCompletePopup.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
        buyCompletePopup.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
        
        buyCompletePopup.couponButtonTap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.pushCouponListViewController(isReView: true)
            }
            .disposed(by: disposeBag)
        buyCompletePopup.smsButtonTap
            .bind(onNext: { [weak self] (title) in
                guard let self = self else {return}
                self.presentMessageCompose(itemTitle: title)
            })
            .disposed(by: disposeBag)
    }
    
    func showNoPointView() {
        guard let parentView = GlobalDefine.shared.curNav?.view else {return}
//        AnalyticsManager.log(.shop_short)
        
        let popup = NoPointPopupView()
        popup.translatesAutoresizingMaskIntoConstraints = false
        
        parentView.addSubview(popup)
        popup.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        popup.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        popup.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
        popup.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
        
        popup.friendInviteButtonClickEvent
            .bind(onNext: { [weak self] (_) in
                guard let self = self else {return}
                
                self.pushToInviteFriendViewController()
            })
            .disposed(by: disposeBag)
    }
    
    func pushShoppingAuth() {
//        parentViewController.performSegue(withIdentifier: Const.showShoppingAuthVC, sender: nil)
        
        let vc = SmsAuthViewController()
        vc.viewModel = AuthViewModel(useCase: .init())
        
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func presentTextviewLink(url: URL) {
        let controller = SFSafariViewController(url: url)
//        controller.setTintColor()
        parentViewController?.present(controller, animated: true, completion: nil)
    }
    
    func presentBlockUserMailCompose() {
        guard MFMailComposeViewController.canSendMail() else {
//            let confirmAction = UIAlertAction(title: "확인", style: .default)
//            parentViewController.alert(title: "이메일 설정", message: "아이폰의 기본 이메일 설정후에 다시 시도해주세요.", preferredStyle: .alert, actions: [confirmAction])
            return
        }
        
        func getMailMessage() -> String {
            let message = """
            본문:
            
            
            
            
            
            
            = ---- 아래 내용은 수정하지 마세요 ----
            = iOS 버전: \(UIDevice.current.systemVersion)
            = 캐시워크 버전: \(getAppVersion())
            """
            return message
        }
        
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = (parentViewController as? MFMailComposeViewControllerDelegate)
        controller.setToRecipients(["cs@cashwalk.io"])
        controller.setSubject("[불편신고][아이폰]")
        controller.setMessageBody(getMailMessage(), isHTML: false)
        parentViewController?.present(controller, animated: true)
    }
    
    func popViewController() {
        parentViewController?.navigationController?.popViewController(animated: true)
    }
    
    func pushCouponListViewController(isReView: Bool) {
        let vc = CouponListViewController()
        vc.fromShopping = isReView
        vc.viewModel = CouponViewModel(parentViewController ?? UIViewController())

        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func pushToInviteFriendViewController() {
        let vc = InviteFriendViewController()
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    // MARK: - Private methods
    
    private func presentMessageCompose(itemTitle: String) {
        let text = """
        자산관리하고 \(itemTitle) 구매했어요!\n
        금융건강 주치의 캐시닥과 함께 더 큰 자산과 건강한 내일을 맞이해볼까요?\n
        \(API.WEB_CASHDOC_URL)
        """
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        activityVC.excludedActivityTypes = [.airDrop]
        parentViewController?.present(activityVC, animated: true, completion: nil)
    }
}
