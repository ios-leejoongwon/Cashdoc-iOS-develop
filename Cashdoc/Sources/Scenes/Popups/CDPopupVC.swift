//
//  CDPopupVC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/03/18.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CDPopupVC: CashdocViewController {
    
    enum PopupType {
        case lock, notice
    }
    
    var popupType: PopupType = .lock
    // NoticeModel
    var modelList: [NoticeModel]?
    private let indexSubject: BehaviorRelay<Int> = .init(value: 0)
    
    @IBOutlet weak var popupImageView: UIImageView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var backgroundButton: UIButton!
     
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc private func gotoSetting() {
        self.closeAct()
        let moreNavi = MoreNavigator(navigationController: GlobalDefine.shared.curNav ?? UINavigationController(), parentViewController: GlobalDefine.shared.curNav ?? UIViewController())
        let vc = LockAppViewController(viewModel: LockAppViewModel(navigator: moreNavi))
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    @objc private func closeAct() {
        if popupType == .lock {
            UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsLockPopupShow.rawValue)
        }
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    private func setupView() {
        switch self.popupType {
        case .lock:
            leftButton.addTarget(self, action: #selector(closeAct), for: .touchUpInside)
            rightButton.addTarget(self, action: #selector(gotoSetting), for: .touchUpInside)
            backgroundButton.addTarget(self, action: #selector(closeAct), for: .touchUpInside)
        case .notice:
            popupImageView.image = nil
            leftButton.setTitle("오늘 그만보기", for: .normal)
            rightButton.setTitle("닫기", for: .normal)
            
            guard let modelList = modelList else { return }
            
            indexSubject
                .compactMap { modelList[safe: $0] }
                .bind(onNext: { [weak self] (model) in
                    self?.configureNotice(model)
                })
                .disposed(by: disposeBag)
            
            popupImageView.rx.tapGesture(.seconds(1))
                .map { [weak self] _ in (self?.indexSubject.value ?? 0) }
                .map { modelList[safe: $0] }
                .subscribe(onNext: { [weak self] (model) in
                    guard let id = model?.id else { return }
                    self?.appendShownNotice(model)
                    self?.closeAct()
                    if let title = model?.title, let url = model?.url {
                        if url.hasPrefix("cdapp") {
                            DeepLinks.openSchemeURL(urlstring: url, gotoMain: false)
                        } else {
                            GlobalFunction.pushToWebViewController(title: title, url: url)
                        }
                    }
                    NoticeUseCase().postPopupNoticeLog(ids: [id], type: .click)
                })
                .disposed(by: disposeBag)
            
            leftButton.rx.tap(.seconds(1))
                .map { [weak self] _ in (self?.indexSubject.value ?? 0) }
                .map { modelList[safe: $0] }
                .bind(onNext: { [weak self] (model) in
                    self?.appendShownNotice(model)
                    self?.increaseIndexForChangeImage()
                })
                .disposed(by: disposeBag)
            
            rightButton.rx.tap(.seconds(1))
                .bind(onNext: { [weak self] (_) in
                    self?.increaseIndexForChangeImage()
                })
                .disposed(by: disposeBag)
            
        }
    }
    
    // MARK: - Notice Private Methods
    
    private func configureNotice(_ model: NoticeModel) {
        if let imgUrl = URL(string: model.image ?? "") {
            popupImageView.kf.setImage(with: imgUrl, completionHandler: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    self.popupImageView.contentMode = .scaleAspectFill
                    self.popupImageView.image = value.image
                    if let id = model.id {
                        NoticeUseCase().postPopupNoticeLog(ids: [id], type: .view)
                    }
                default:
                    return
                }
            })
        }
    }
    
    private func appendShownNotice(_ curModel: NoticeModel?) {
        guard let curModel = curModel else { return }
        guard let id = curModel.id else { return }
        var shownNoticeList: [ShownNoticeModel] = UserDefaultsManager.getShownNoticeList(justClose: false)
        shownNoticeList.append(ShownNoticeModel(id: id, showDate: Date()))
        if let encodeData = try? JSONEncoder().encode(shownNoticeList) {
            UserDefaults.standard.set(encodeData, forKey: UserDefaultKey.kShownPopupNoticeIds.rawValue)
        }
    }
    
    private func increaseIndexForChangeImage() {
        let count: Int = (self.modelList?.count ?? 0)-1
        
        guard indexSubject.value < count else {
            closeAct()
            return
        }
        indexSubject.accept(indexSubject.value+1)
    }
    
}
