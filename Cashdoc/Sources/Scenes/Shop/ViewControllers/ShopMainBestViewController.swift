//
//  ShopMainBestViewController.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 20/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol ShopMainBestViewControllerDelegate: NSObjectProtocol {
    func shopMainBestVCDidClickedTitle(_ viewController: ShopMainBestViewController, bestItems: [ShopItemModel])
    func shopMainBestVC(_ viewController: ShopMainBestViewController, didSelect item: ShopItemModel)
}

final class ShopMainBestViewController: CashdocViewController {
    
    // MARK: - Properties
    var bestItems = BehaviorRelay<[ShopBestModel]>(value: [])
    var viewModel: ShopBestViewModel!
    
    weak var delegate: ShopMainBestViewControllerDelegate?
    
    // MARK: - UI Components
    
    private let titleButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        $0.setTitle("BEST 상품", for: .normal)
        $0.setTitleColor(.blackCw, for: .normal)
        $0.setTitleColor(.brownishGrayCw, for: .highlighted)
    }
    private let moreImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icArrow01StyleRightGray")
        $0.isHidden = true
    }
    private let flowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 24
        $0.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    }
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.register(ShopMainBestCollectionViewCell.self, forCellWithReuseIdentifier: "ShopMainBestCollectionViewCell")
    }
    
    // MARK: - Overridden: ParentClass
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Log.i("shop best")
        
        setProperties()
        view.addSubview(titleButton)
        view.addSubview(moreImageView)
        view.addSubview(collectionView)
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        bindViewModel()
        layout()
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
//        let items = collectionView.rx.items(cellIdentifier: "ShopMainBestCollectionViewCell")
        
        bestItems.asObservable()
            .bind(to: collectionView.rx.items(cellIdentifier: "ShopMainBestCollectionViewCell", cellType: ShopMainBestCollectionViewCell.self)) { _, model, cell in
                cell.configure(item: model)
            }.disposed(by: disposeBag)
        
        collectionView.rx.itemSelected.bind { (indexPath) in
            let bestItem = self.bestItems.value[indexPath.row]
            
            let item = ShopItemModel.init(title: bestItem.title, goodsId: bestItem.goodsId, price: bestItem.price, imageUrl: bestItem.imageUrl, affiliate: bestItem.affiliate, type: nil, validity: bestItem.validity, description: bestItem.description, pinNo: nil, ctrId: nil, expiredAt: nil, delay: nil)
            self.viewModel.pushShopDetailVC(item: item)
        }.disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .grayTwoCw
        view.clipsToBounds = true
    }
    
}

// MARK: - Layout

extension ShopMainBestViewController {
    
    private func layout() {
        view.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true
//        view.bottomAnchor.constraint(equalTo: titleButton.bottomAnchor).isActive = true
        
        titleButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        titleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        
        moreImageView.leadingAnchor.constraint(equalTo: titleButton.trailingAnchor, constant: 0).isActive = true
        moreImageView.centerYAnchor.constraint(equalTo: titleButton.centerYAnchor).isActive = true
        moreImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        moreImageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        collectionView.topAnchor.constraint(equalTo: titleButton.bottomAnchor, constant: 12).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 121).isActive = true
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ShopMainBestViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: collectionView.bounds.height)
    }
}
