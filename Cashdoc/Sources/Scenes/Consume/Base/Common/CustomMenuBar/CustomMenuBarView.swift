//
//  CustomMenuBarView.swift
//  Cashdoc
//
//  Created by Oh Sangho on 21/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

protocol CustomMenuBarViewDelegate: AnyObject {
    func didSelectedMenu(index: Int)
}

class CustomMenuBarView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: CustomMenuBarViewDelegate?
    var menuContentViews = [UIView]()
    var prevMenuContentView: UIView!
    
    private let disposeBag = DisposeBag()
    private var buttonCount: Int = 0 {
        didSet {
            self.buttonWidth = ScreenSize.WIDTH/CGFloat(buttonCount)
        }
    }
    private var buttonWidth: CGFloat = 0
    private let ratioHeight: CGFloat = 56
    private let initialSelectedTrigger = PublishRelay<IndexPath>()
    
    private var viewHeight: NSLayoutConstraint!
    private var middleSelectedLineLeading: NSLayoutConstraint!
    private var middleSelectedLineTrailing: NSLayoutConstraint!
    
    // MARK: - UI Components
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = CGSize(width: buttonWidth, height: ratioHeight - 2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        $0.collectionViewLayout = layout
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        $0.showsHorizontalScrollIndicator = false
        $0.isScrollEnabled = false
        $0.register(cellType: CustomMenuBarCollectionViewCell.self)
    }
    private let middleLine = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayCw
    }
    private let middleSelectedLine = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .blackCw
    }
    
    init(menus: [String]) {
        super.init(frame: .zero)
        
        setProperties(with: menus)
        bindView()
        bindViewModel(with: menus)
        addSubview(collectionView)
        addSubview(middleLine)
        addSubview(middleSelectedLine)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHidden: Bool {
        didSet {
            if self.isHidden {
                viewHeight.constant = 0
            } else {
                viewHeight.constant = ratioHeight
            }
        }
    }
    
    // MARK: - Binding
    
    private func bindView() {
        let itemSelected = Observable.merge(initialSelectedTrigger.asObservable(),
                                            collectionView.rx.itemSelected.asObservable())
        itemSelected
            .bind { [weak self] (ip) in
                guard let self = self else { return }
                guard let cell = self.collectionView.cellForItem(at: ip) as? CustomMenuBarCollectionViewCell else { return }
                
                cell.isSelected = true
                
                self.delegate?.didSelectedMenu(index: ip.row)
                self.animatedMiddleLine(with: ip.row)
            }
            .disposed(by: disposeBag)
        
        collectionView.rx
            .itemDeselected
            .bind { [weak self] ip in
                guard let self = self else { return }
                guard let cell = self.collectionView.cellForItem(at: ip) as? CustomMenuBarCollectionViewCell else { return }
                
                cell.isSelected = false
            }
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel(with menus: [String]) {
        Observable.just(menus)
            .bind(to: collectionView.rx.items(cellIdentifier: CustomMenuBarCollectionViewCell.reuseIdentifier, cellType: CustomMenuBarCollectionViewCell.self)) { row, element, cell in
                if row == 0 {
                    cell.isSelected = true
                }
                cell.configure(with: element)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Internal methods
    
    func initialSelectedItem(with row: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let ip = IndexPath(row: row, section: 0)
            self.collectionView.scrollToItem(at: ip, at: .centeredHorizontally, animated: false)
            self.initialSelectedTrigger.accept(ip)
        }
    }
    
    // MARK: - Private methods
    
    private func setProperties(with menus: [String]) {
        if menus.count > 0 {
            buttonCount = menus.count
        }
    }
    
    private func animatedMiddleLine(with row: Int) {
        let leadingConst = buttonWidth * CGFloat(row)
        var trailingConst = buttonWidth * CGFloat(row - (buttonCount - 1))
        if trailingConst > 0 {
            trailingConst *= -1
        }
        middleSelectedLineLeading.isActive = false
        middleSelectedLineTrailing.isActive = false
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.middleSelectedLineLeading = self.middleSelectedLine.leadingAnchor.constraint(equalTo: self.collectionView.leadingAnchor, constant: leadingConst)
            self.middleSelectedLineTrailing = self.middleSelectedLine.trailingAnchor.constraint(equalTo: self.collectionView.trailingAnchor, constant: trailingConst)
            
            self.middleSelectedLineLeading.isActive = true
            self.middleSelectedLineTrailing.isActive = true
            self.layoutIfNeeded()
        }
    }
}

// MARK: - Layout

extension CustomMenuBarView {
    private func layout() {
        viewHeight = heightAnchor.constraint(equalToConstant: ratioHeight)
        viewHeight.isActive = true
        
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: middleLine.topAnchor).isActive = true
        
        middleLine.topAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true
        middleLine.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        middleLine.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        middleLine.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        middleSelectedLine.centerYAnchor.constraint(equalTo: middleLine.centerYAnchor).isActive = true
        middleSelectedLine.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        middleSelectedLine.heightAnchor.constraint(equalToConstant: 2).isActive = true
        middleSelectedLine.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        middleSelectedLineLeading = middleSelectedLine.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor, constant: buttonWidth * 0)
        middleSelectedLineLeading.isActive = true
        var trailingConst = buttonWidth * CGFloat(buttonCount - 1)
        if trailingConst > 0 {
            trailingConst *= -1
        }
        middleSelectedLineTrailing = middleSelectedLine.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: trailingConst)
        middleSelectedLineTrailing.isActive = true
    }
}
