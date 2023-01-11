//
//  ConsumeNavigator.swift
//  Cashdoc
//
//  Created by Oh Sangho on 05/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

protocol ConsumeNavigator {
    func pushToLinkPropertyViewController(isAnimated: Bool)
    func pushToDetailConsumeViewController(item: ConsumeContentsItem)
    func navigationControllerForLoading() -> UINavigationController
    func pushToConsumeCategoryViewController(item: ConsumeContentsItem)
    func pushToConsumeTypeFilterViewController(consumeType: (String, CategoryType))
    func pushToAddConsumeViewController(_ item: ConsumeContentsItem?)
    func linkAfterReloadAndPoptoRootVC(_ category: String)
    func linkAfterReloadAndPoptoVC()
    func popVC(_ item: ConsumeContentsItem)
    func addRewardFailPopupView()
    func pushToManageConsumeViewController(date: (String, String))
}

final class DefaultConsumeNavigator: ConsumeNavigator {
    
    // MARK: - Properties
    
    private let parentViewController: ConsumeViewController
    
    // MARK: - Con(De)structor
    
    init(parentViewController: ConsumeViewController) {
        self.parentViewController = parentViewController
    }
    
    // MARK: - Internal methods
    
    func pushToLinkPropertyViewController(isAnimated: Bool) {
        let vc = LinkPropertyViewController(viewModel: LinkPropertyViewModel(navigator: DefaultPropertyNavigator(parentViewController: parentViewController)))
        parentViewController.navigationController?.pushViewController(vc, animated: isAnimated)
    }
    
    func pushToDetailConsumeViewController(item: ConsumeContentsItem) {
        let vc = DetailConsumeViewController(viewModel: .init(navigator: self))
        vc.item = item
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func navigationControllerForLoading() -> UINavigationController {
        guard let navi = parentViewController.navigationController else {return .init()}
        return navi
    }
    
    func pushToConsumeCategoryViewController(item: ConsumeContentsItem) {
        let vc = ModifyConsumeCategoryViewController(viewModel: .init(navigator: self))
        let consumeOutgoingCategoryVC = ConsumeCategoryViewController(type: "지출", item: item, viewModel: .init(navigator: self))
        let consumeIncomeCategoryVC = ConsumeCategoryViewController(type: "수입", item: item, viewModel: .init(navigator: self))
        let consumeEtcCategoryVC = ConsumeCategoryViewController(type: "기타", item: item, viewModel: .init(navigator: self))
        vc.contentsItem = item
        vc.consumeOutgoingCategoryVC = consumeOutgoingCategoryVC
        vc.consumeIncomeCategoryVC = consumeIncomeCategoryVC
        vc.consumeEtcCategoryVC = consumeEtcCategoryVC
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func pushToConsumeTypeFilterViewController(consumeType: (String, CategoryType)) {
        let vc = ConsumeTypeFilterViewController(viewModel: .init(navigator: self), consumeType: consumeType)
        let incomeConsumeListViewController = ConsumeListViewController(viewModel: .init(navigator: self), consumeType: (consumeType.0, .수입))
        let outgoingConsumeListViewController = ConsumeListViewController(viewModel: .init(navigator: self), consumeType: (consumeType.0, .지출))
        let etcConsumeListViewController = ConsumeListViewController(viewModel: .init(navigator: self), consumeType: (consumeType.0, .기타))
        vc.incomeConsumeListViewController = incomeConsumeListViewController
        vc.outgoingConsumeListViewController = outgoingConsumeListViewController
        vc.etcConsumeListViewController = etcConsumeListViewController
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func pushToAddConsumeViewController(_ item: ConsumeContentsItem? = nil) {
        let storyBoard = UIStoryboard(name: "Consume", bundle: nil)
        guard let vc = storyBoard.instantiateViewController(withIdentifier: "addConsume") as? AddConsumeViewController else { return }
        vc.item = item
        vc.viewModel = AddConsumeViewModel(navigator: self)
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func linkAfterReloadAndPoptoRootVC(_ category: String) {
        parentViewController.linkAfterVC.isreloadTableView = true
        guard let naviVC = GlobalDefine.shared.curNav else { return }
        parentViewController.navigationController?.popToRootViewController(animated: true)
        naviVC.viewControllers.last?.view.makeToastWithCenter("\(category)내역이 추가되었습니다.")
    }
    
    func linkAfterReloadAndPoptoVC() {
        parentViewController.linkAfterVC.isreloadTableView = true
        guard let naviVC = GlobalDefine.shared.curNav else { return }
        parentViewController.navigationController?.popViewController(animated: true)
        naviVC.viewControllers.last?.view.makeToastWithCenter("변경되었습니다.")
    }
    
    func popVC(_ item: ConsumeContentsItem) {
        parentViewController.linkAfterVC.isreloadTableView = true
        guard let naviVC = GlobalDefine.shared.curNav else { return }
        parentViewController.navigationController?.popViewController(animated: true)
        naviVC.viewControllers.last?.view.makeToastWithCenter("\(item.category) 내역이 삭제되었습니다.")
    }

    func addRewardFailPopupView() {
        guard let window = UIApplication.shared.windows.last else { return }
        let popupView = RewardFailPopupView(frame: UIScreen.main.bounds)
        window.addSubview(popupView)
    }
    
    func pushToManageConsumeViewController(date: (String, String)) {
        let vc = ManagePropertyViewController(type: .가계부, date: date)
        GlobalFunction.pushVC(vc, animated: true)
    }
}
