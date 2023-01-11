//
//  ConsumeCategoryViewController.swift
//  Cashdoc
//
//  Created by Taejune Jung on 23/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import RxOptional

final class ConsumeCategoryViewController: CashdocViewController {
    
    // MARK: - Properties
    var viewModel: ConsumeCategoryViewModel!
    var item: ConsumeContentsItem!
    var category: String?
    var selectRelay = PublishRelay<(ConsumeContentsItem, String)>()
    var subCategory: String = "미분류"
    private let categoryType = PublishRelay<String>()
    
    // MARK: - UI components
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        $0.collectionViewLayout = layout
        $0.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayTwoCw
        $0.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        $0.showsVerticalScrollIndicator = false
        $0.register(cellType: ConsumeCategoryCollectionViewCell.self)
    }
    private let okButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("저장", for: .normal)
        $0.setBackgroundColor(.yellowCw, forState: .normal)
        $0.setTitleColor(.blackCw, for: .normal)
        $0.setBackgroundColor(.grayCw, forState: .disabled)
        $0.setTitleColor(.whiteCw, for: .disabled)
        $0.clipsToBounds = true
        $0.isEnabled = false
    }
    
    // MARK: - Con(De)structor
    
    init(type: String, item: ConsumeContentsItem, viewModel: ConsumeCategoryViewModel) {
        super.init(nibName: nil, bundle: nil)
        category = type
        self.item = item
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        bindView()
        bindViewModel()
        view.addSubview(collectionView)
        view.addSubview(okButton)
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.categoryType.accept(self.category ?? "기타")
    }

    // MARK: - Binding
    
    private func bindView() {
        self.collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                guard let cell = self.collectionView.cellForItem(at: index) as? ConsumeCategoryCollectionViewCell else { return }
                self.subCategory = cell.categoryTitle
                self.okButton.isEnabled = true
                cell.isSelected = true
            })
        .disposed(by: disposeBag)
        
        self.collectionView.rx.itemDeselected
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                guard let cell = self.collectionView.cellForItem(at: index) as? ConsumeCategoryCollectionViewCell else { return }
                cell.isSelected = false
            })
            .disposed(by: disposeBag)
        
        okButton.rx.tap
        .subscribe({ [weak self] _ in
            guard let self = self else { return }
            self.selectRelay.accept((self.item, self.subCategory))
        })
        .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(viewWillAppear(_:))).take(1).mapToVoid()
        let itemTrigger = self.categoryType.asDriverOnErrorJustNever()
        
        let input = type(of: self.viewModel).Input(trigger: viewWillAppear.asDriverOnErrorJustNever(),
                                              itemTrigger: itemTrigger)
        
        let output = viewModel.transform(input: input)
        
        output.section
            .drive(collectionView.rx.items(dataSource: self.dataSource()))
        .disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .grayTwoCw
        view.translatesAutoresizingMaskIntoConstraints = false
        okButton.layer.cornerRadius = 4
    }
}

// MARK: - Layout

extension ConsumeCategoryViewController {
    
    private func layout() {
        collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: okButton.topAnchor, constant: -16).isActive = true
        
        okButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        okButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        okButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        okButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
    }
}

extension ConsumeCategoryViewController {
    private func dataSource() -> RxCollectionViewSectionedReloadDataSource<ConsumeCategorySection> {
        return RxCollectionViewSectionedReloadDataSource<ConsumeCategorySection>(configureCell: { (_, cv, ip, item) in
            switch item {
            case .category(category: let category):
                let cell = cv.dequeueReusableCell(for: ip, cellType: ConsumeCategoryCollectionViewCell.self)
                cell.configure(with: category)
                return cell
            default:
                return UICollectionViewCell()
            }
        })
    }
}
