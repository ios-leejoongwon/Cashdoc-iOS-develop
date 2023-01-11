//
//  LinkPropertyChildViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 20/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift
import RxDataSources
import RxOptional

final class LinkPropertyChildViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private var viewModel: LinkPropertyChildViewModel!
    private var propertyType: LinkPropertyChildType!
    private let alertFetching = PublishRelay<BankInfo>()
    
    // MARK: - UI Components
    
    private let descLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .blackCw
        $0.textAlignment = .center
        $0.text = "연동 시 대출 내역이 같이 조회됩니다."
    }
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let itemSizeWidth = (ScreenSize.WIDTH / 3) - 16
        let itemSizeHeight = itemSizeWidth - 25
        layout.estimatedItemSize = CGSize(width: itemSizeWidth, height: itemSizeHeight)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        $0.collectionViewLayout = layout
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        $0.showsVerticalScrollIndicator = false
        $0.register(cellType: LinkForBankCollectionViewCell.self)
    }
    
    // MARK: - Con(De)structor
    
    init(propertyType: LinkPropertyChildType, viewModel: LinkPropertyChildViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
        self.propertyType = propertyType
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
        view.addSubview(descLabel)
        view.addSubview(collectionView)
        layout()
    }
    
    // MARK: - Binding
    
    private func bindView() {
        Observable.zip(collectionView.rx.itemSelected,
                       collectionView.rx.modelSelected(LinkForBankSectionItem.self))
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] (_, item) in
                guard let self = self else { return }
                switch item {
                case .bank(let bankInfo):
                    if !bankInfo.isLinked {
                        self.viewModel.pushToLinkPropertyLoginViewController(linkType: .하나씩연결,
                                                                             propertyType: self.propertyType,
                                                                             bankInfo: bankInfo)
                    } else {
                        self.alertFetching.accept(bankInfo)
                    }
                }
        }
        .disposed(by: disposeBag)
        
        alertFetching
            .subscribe(onNext: { [weak self] (bankInfo) in
                guard let self = self else { return }
                self.viewModel.getAlertController(vc: self)
                    .observe(on: MainScheduler.asyncInstance)
                    .subscribe(onNext: { [weak self] (isOk) in
                        guard let self = self, isOk else { return }
                        guard let type = FCode(rawValue: bankInfo.bankName)?.type else { return }
                        
                        switch type {
                        case .은행:
                            AccountListRealmProxy().delete(fCodeName: bankInfo.bankName, completion: {
                                DispatchQueue.main.async {
                                    GlobalFunction.CDPopToRootViewController(animated: true)
                                }
                                SmartAIBManager.scrapingForRefresh(vc: self.viewModel.parentViewControllerForScraping())
                            })
                        case .카드:
                            CardPaymentRealmProxy().deleteForUnLinked(fCodeName: bankInfo.bankName, completion: {
                                DispatchQueue.main.async {
                                    GlobalFunction.CDPopToRootViewController(animated: true)
                                }
                                SmartAIBManager.scrapingForRefresh(vc: self.viewModel.parentViewControllerForScraping())
                            })
                        default:
                            return
                        }
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:))).take(1).mapToVoid()
        let selection = Observable.zip(collectionView.rx.itemSelected,
                                       collectionView.rx.modelSelected(LinkForBankSectionItem.self)).map {($0.0, $0.1, self.propertyType ?? .ALL)}
    
        let trigger = Observable.of(viewWillAppear.mapToVoid(),
                                    selection.mapToVoid())
            .merge()
            .map { self.propertyType }
            .filterNil()
        
        let input = type(of: self.viewModel).Input(trigger: trigger.asDriverOnErrorJustNever())
        
        let output = viewModel.transform(input: input)
        
        output.sections
            .drive(collectionView.rx.items(dataSource: self.dataSource()))
            .disposed(by: disposeBag)
    }
    
    // MARK: - Properties
    
    private func setProperties() {
        view.backgroundColor = .grayTwoCw
        view.translatesAutoresizingMaskIntoConstraints = false
        if propertyType == .카드 {
            view.isHidden = true
        }
    }
    
}

// MARK: - RxCollectionViewSectionedReloadDataSource

extension LinkPropertyChildViewController {
    private func dataSource() -> RxCollectionViewSectionedReloadDataSource<LinkForBankSection> {
        let extractedExpr = RxCollectionViewSectionedReloadDataSource<LinkForBankSection>(configureCell: { (_, cv, ip, item) in
            switch item {
            case .bank(let bankInfo):
                let cell = cv.dequeueReusableCell(for: ip, cellType: LinkForBankCollectionViewCell.self)
                cell.configure(with: bankInfo)
                return cell
            }
        })
        return extractedExpr
    }
}

// MARK: - Layout

extension LinkPropertyChildViewController {
    private func layout() {
        descLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24).isActive = true
        descLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        descLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        collectionView.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 16).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
    }
}
