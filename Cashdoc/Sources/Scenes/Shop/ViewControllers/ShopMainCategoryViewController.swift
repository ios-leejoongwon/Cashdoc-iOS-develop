//
//  ShopMainCategoryViewController.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 21/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

final class ShopMainCategoryViewController: CashdocViewController {
    
    // MARK: - NSLayoutConstraints
    
    private var collectionViewHeight: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var dataSource = BehaviorRelay<[ShopCategoryModel]>(value: [])
    var viewModel: ShopCategoryViewModel!

    // MARK: - UI Components
    
    private let flowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
        $0.minimumLineSpacing = 18
        $0.minimumInteritemSpacing = 18
//        $0.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        $0.sectionInset = UIEdgeInsets(top: 22, left: 20, bottom: 0, right: 20)
    }
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.isScrollEnabled = false
        $0.register(ShopMainCategoryCollectionViewCell.self, forCellWithReuseIdentifier: "ShopMainCategoryCollectionViewCell")
    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProperties()
        bindViewModel()
        view.addSubview(collectionView)
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        layout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.collectionView.reloadData()
        self.collectionViewHeight.constant = self.collectionView.contentSize.height + 40
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        dataSource.asObservable()
            .bind(to: collectionView.rx.items(cellIdentifier: "ShopMainCategoryCollectionViewCell", cellType: ShopMainCategoryCollectionViewCell.self)) { _, model, cell in
                cell.configure(item: model)
            }.disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                self.viewModel.pushShopGoodsListVC(category: self.dataSource.value[indexPath.row])
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .whiteCw
        view.clipsToBounds = true
    }
}

// MARK: - Layout

extension ShopMainCategoryViewController {
    
    private func layout() {
        self.collectionView.backgroundColor = .white

        collectionView.reloadData()
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionViewHeight = collectionView.heightAnchor.constraint(equalToConstant: 600)
        collectionViewHeight.isActive = true
    }
    
}

// MARK: - Delegate

extension ShopMainCategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = collectionView.bounds.width
        let cellWidth = (screenWidth - 76) / 3 // compute your cell width
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
